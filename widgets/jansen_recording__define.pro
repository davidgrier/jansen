;+
; NAME:
;    jansen_recording
;
; PURPOSE:
;    Control panel for recording video data.
;
; MODIFICATION HISTORY:
; 02/13/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; jansenVideo::SaveImage
;
pro jansen_recording::SaveImage, image

  COMPILE_OPT IDL2, HIDDEN

  path = file_search(self.directory, /expand_tilde, /expand_environment, /test_directory)
  
  filename = dialog_pickfile(title = 'Save Snapshot', $
                             filter = '*.png', /fix_filter, $
                             path = path, $
                             file = 'jansen_snapshot', $
                             default_extension = 'png', $
                             /write, /overwrite_prompt, $
                             resource_name = 'Jansen')
  if strlen(filename) gt 0 then $
     write_png, filename, image
end

;;;;;
;
; jansen_recording_event
;
pro jansen_recording::handleEvent, event

  COMPILE_OPT IDL2, HIDDEN

  widget_control, event.top, get_uvalue = state
  widget_control, event.id,  get_uvalue = uval

  video = state.video
  
  case uval of
     'NAME': begin
        filename = self.filename
        self.filename = event.value
        if ~self.hasvalidfilename() then $
           self.filename = filename
        widget_control, event.id, set_value = self.filename
     end
     
     'TARGET': begin
        print, event.value
     end
     
     'CONTROLS': begin
        case event.value of
           'RECORD': begin
              case self.recording of
                 0: begin               ; ... not previous recording, so start
                    if self.hasvalidfilename() then begin
                       info = get_login_info()
                       meta = {machine_name: info.machine_name, $
                               user_name: info.user_name, $
                               lambda: state.imagelaser.wavelength, $
                               mpp: state.camera.mpp}
                       self.recorder = h5video(self.directory+self.filename, $
                                               /overwrite, metadata = meta)
                       video.registercallback, 'recorder', self
                       self.framenumber = 0
                       self.recording = 1
                    endif
                 end
                 -1: self.recording = 1 ; ... paused, so unpause
                 else:                  ; ... already recording, carry on
              endcase
           end
           
           'PAUSE': self.recording *= -1 ; pause/unpause
           
           'STOP': begin                ; stop recording, close file
              if (self.recording ne 0) then begin
                 video.unregistercallback, 'recorder'
                 self.recording = 0
                 self.recorder.close
              endif
           end
           
           'SNAPSHOT': self.saveimage, video.screendata
              
           else:
        endcase
     end
     
     'HVMMODE': begin
        video.hvmmode = event.value
     end
     
     else: print, 'got', uval
  endcase
  
end

;;;;;
;
; jansen_recording::hasvalidfilename
;
function jansen_recording::hasvalidfilename

  COMPILE_OPT IDL2

  filename = self.filename
  directory = self.directory

;  if (filename.length eq 0) then $ ; IDL 8.4
  if strlen(filename) eq 0 then $
     return, 0

;  if filename.contains(path_sep()) then begin ; IDL 8.4
  if strmatch(filename, '*'+path_sep()+'*') then begin
     directory = file_dirname(filename)
     filename = file_basename(filename)
  endif

  if ~file_test(directory, /directory) then $
     file_mkdir, directory

  if ~file_test(directory, /directory, /write) then begin
     res = dialog_message('Cannot write to '+directory)
     return, 0
  endif

  directory = file_search(directory, /expand_tilde, /expand_environment, /mark_directory)
  
;  if ~filename.endswith('.h5', /fold_case) then $ ; IDL 8.4
  if ~strmatch(filename, '*.h5', /fold_case) then $
     filename += '.h5'
  
  fullname = directory + filename

  if file_test(fullname) then begin
     res = dialog_message(fullname + ' already exists. Overwrite?', $
                          /QUESTION, /DEFAULT_NO)
     if (res eq 'No') then $
        return, 0
     if ~file_test(fullname, /WRITE) then begin
        res = dialog_message('Cannot overwrite '+fullname)
        return, 0
     endif
  endif

  self.directory = directory
  self.filename = filename

  return, 1
end

;;;;;
;
; jansen_recording::Callback
;
; Update the control panel based on current recording activity
;
pro jansen_recording::Callback, video

  COMPILE_OPT IDL2, HIDDEN

  if (self.recording ge 1L) then begin
     widget_control, self.wtarget, get_value = targetnumber
     if self.framenumber lt targetnumber then begin
        self.recorder.write, (self.recording eq 1L) ? video.data : video.screendata
        self.framenumber++
     endif else begin
        video.unregistercallback, 'recorder'
        self.recording = 0L
        self.recorder.close
        self.framenumber = 0
     endelse
     widget_control, self.wframenumber, set_value = self.framenumber
  endif
end

;;;;;
;
; jansen_recording::Init()
;
; Create the widget layout and set up the callback for the
; video recording object.
;
function jansen_recording::Init, wtop

  COMPILE_OPT IDL2, HIDDEN

  self.directory = '~/data'
  self.filename = 'jansen.h5'
  
  wrecording = widget_base(wtop, /COLUMN, /GRID_LAYOUT, $
                           TITLE = 'Recording', $               ; for WIDGET_TAB
                           UVALUE = self, $                     ; for object-event handler
                           EVENT_PRO = 'jansen_object_event', $ ; same event dispatcher for all object widgets
                           RESOURCE_NAME = 'Jansen')

  wname        = cw_field(wrecording, /FRAME, /RETURN_EVENTS, $
                          VALUE = self.filename, $
                          title = 'File Name:', UVALUE = 'NAME')
  
  wtarget      = cw_field(wrecording, /FRAME, /RETURN_EVENTS, /ULONG, $
                          VALUE = 1000UL, $
                          title = '# Frames: ', UVALUE = 'TARGET')

  bvalues      = ['Record', 'Pause', 'Stop', 'Snapshot']
  wcontrols    = cw_bgroup(wrecording, bvalues, /ROW, $
                           button_uvalue = strupcase(bvalues), $
                           /FRAME, /NO_RELEASE, UVALUE = 'CONTROLS')

  wframenumber = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
                          VALUE = 0UL, $
                          title = 'Frame #:  ')                     
  wfeatures    = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
                          VALUE = 0UL, $
                          title = 'Feature #:')

  bvalues = ['Normal', 'Running', 'Sample/Hold']
  whvmmode = cw_bgroup(wrecording, bvalues, $
                       /ROW, /FRAME, $
                       LABEL_TOP = 'HVM Mode:', $
                       /EXCLUSIVE, /NO_RELEASE, $
                       SET_VALUE = 0, UVALUE = 'HVMMODE')

  self.wtarget = wtarget
  self.wframenumber = wframenumber
  self.framenumber = 0

  return, 1
end

;;;;;
;
; jansen_recording__define
;
pro jansen_recording__define, wtop

  COMPILE_OPT IDL2, HIDDEN

  struct = {Jansen_Recording, $
            recording: 0L, $
            recorder: obj_new(), $
            directory: '', $
            filename: '', $            
            wtarget: 0L, $
            framenumber: 0UL, $
            wframenumber: 0L $
           }
end

