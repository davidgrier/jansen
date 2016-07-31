;+
; NAME:
;    jansen_dvr
;
; PURPOSE:
;    Control panel for recording video data.
;
; MODIFICATION HISTORY:
; 02/13/2015 Written by David G. Grier, New York University
; 07/29/2016 DGG Overhaul for flexibility
;
; Copyright (c) 2015-2016 David G. Grier
;-

;;;;;
;
; jansen_dvr::handleEvent
;
pro jansen_dvr::handleEvent, event

  COMPILE_OPT IDL2

  widget_control, event.top, get_uvalue = state
  widget_control, event.id,  get_uvalue = uval

  video = state.video
  
  case uval of
     'FILENAME': begin
        self.setfilename, event.value
        widget_control, event.id, set_value = self.filename
     end
     
     'TARGET': ; nothing to do
     
     'RECORD': begin
        case event.value of
           'RECORD': begin
              case self.state of
                 'NORMAL': begin ; ... not recording, so start
                    if ~file_test(self.filename) || $
                       (dialog_message([self.filename + ' already exists.', 'Overwrite?'], $
                                       /question, /default_no, /center) eq 'Yes') then begin
                       self.recorder = h5video(self.filename, /overwrite, $
                                               metadata = self.metadata(state))
                    endif
                    if isa(self.recorder, 'h5video') then begin
                       video.registercallback, 'dvr', self
                       self.framenumber = 0UL
                       self.state = 'RECORDING'
                    endif
                 end
                 'PAUSED': self.state = 'RECORDING' ; ... paused, so unpause
                 else:                              ; ... already recording, carry on
              endcase
           end
           
           'PAUSE': begin
              case self.state of
                 'RECORDING': self.state = 'PAUSED'
                 'PAUSED': self.state = 'RECORDING'
                 'REPLAYING': video.playing = ~video.playing
                 else:          ; nothing to do
              endcase
           end
           
           'STOP': begin        ; stop recording, close file
              video.playing = 0
              if (self.state eq 'REPLAYING') then $
                 video.camera = state.camera
              if (self.state ne 'NORMAL') then begin
                 video.unregistercallback, 'dvr'
                 self.recorder.close
              endif
              self.state = 'NORMAL'
              video.playing = 1
           end
           
           'SNAPSHOT': void = dialog_write_image(video.screendata, $
                                                 title = 'Save Snapshot', $
                                                 filename = 'jansen_snapshot.png', $
                                                 type = 'png', $
                                                 path = file_dirname(self.filename), $
                                                 /warn_exist)
           
           else:
        endcase
     end

     'REPLAY': begin
        case event.value of
           'REWIND': begin
              if (self.state eq 'REPLAYING') then begin
                 self.recorder.index = 0
                 video.playing = 0
                 self.callback, video
              endif
           end
           
           'PAUSE': begin
              case self.state of
                 'RECORDING': self.state = 'PAUSED'
                 'PAUSED': self.state = 'RECORDING'
                 'REPLAYING': video.playing = ~video.playing
                 else:          ; nothing to do
              endcase
           end

           'PLAY': begin
              if ~(self.state eq 'REPLAYING') then begin   ; start replaying
                 if (self.state eq 'RECORDING') then begin ; stop recording
                    video.unregistercallback, 'recorder'
                    self.state = 'NORMAL'
                    self.recorder.close
                 endif
                 ;; open replay file
                 self.recorder = h5video(self.filename) ; open for reading
                 if isa(self.recorder, 'h5video') then begin
                    video.camera = self.recorder
                    video.registercallback, 'recorder', self
                    self.state = 'REPLAYING'
                    video.playing = 0
                 endif
              endif
              self.recorder.stepsize = 1
              video.playing = 1
           end
           
           'FAST': begin
              if (self.state eq 'REPLAYING') then begin
                 self.recorder.stepsize *= 2
                 video.playing = 1
              endif
           end

           'STOP': begin
              video.playing = 0
              if (self.state eq 'REPLAYING') then $
                 video.camera = state.camera
              if (self.state ne 'NORMAL') then begin
                 video.unregistercallback, 'recorder'
                 self.recorder.close
              endif
              self.state = 'NORMAL'
              video.playing = 1
           end
           
           else:
        endcase
     end
     
     'HVMMODE': begin
        case event.value of
           0: video.unregisterfilter
           1: video.registerfilter, jansen_filter_median(/running, order = 4)
           2: video.registerfilter, jansen_filter_median(order = 4)
        endcase
     end
     
     else: print, 'got', uval
  endcase
  
end

;;;;;
;
; jansen_dvr::setfilename
;
; Update fully-qualified filename for saving video files
;
pro jansen_dvr::setfilename, _filename

  COMPILE_OPT IDL2

  if strlen(_filename) eq 0 then return ; nothing to do

  ;; separate fully-qualified filename, if necessary
  filename = file_basename(_filename)
  directory = strmatch(_filename, '*'+path_sep()+'*') ? $
              file_dirname(_filename) : $
              file_dirname(self.filename)

  ;; create directory, if necessary
  if ~file_test(directory, /directory) then $
     file_mkdir, directory

  ;; check that directory is writeable
  if ~file_test(directory, /directory, /write) then begin
     res = dialog_message('Cannot write to ' + directory)
     return
  endif

  ;; format directory string
  directory = file_search(directory, /expand_tilde, /expand_environment, /mark_directory)
  
  ;; check that file is writeable
  fullname = directory + filename
  if file_test(fullname) && ~file_test(fullname, /write) then begin
     res = dialog_message('Cannot overwrite ' + fullname, /center)
     return
  endif

  self.filename = fullname
end

;;;;;
;
; jansen_dvr::metadata()
;
function jansen_dvr::metadata, state

  COMPILE_OPT IDL2

  info = get_login_info()

  camera = state['camera']
  exposure_time = (camera.hasproperty('exposure_time')) ? $
                  camera.exposure_time : $
                  'unknown'

  gain = (camera.hasproperty('gain')) ? $
         camera.gain : $
         'unknown'
  
  metadata = {creator:       'jansen', $
              machine_name:  info.machine_name, $
              user_name:     info.user_name, $
              camera:        camera.name, $
              exposure_time: exposure_time, $
              gain:          gain, $
              lambda:        state.imagelaser.wavelength, $
              mpp:           camera.mpp}
  
  return, metadata
end

;;;;;
;
; jansen_dvr::Callback
;
; Update the control panel based on current recording activity
;
pro jansen_dvr::Callback, video

  COMPILE_OPT IDL2

  if (self.state eq 'RECORDING') then begin
     widget_control, self.wtgt, get_value = target
     if self.framenumber lt target then begin
        self.recorder.write, video.data
        self.framenumber++
     endif else begin
        video.unregistercallback, 'recorder'
        self.state = 'NORMAL'
        self.recorder.close
        self.framenumber = 0
     endelse
     widget_control, self.wfrn, set_value = self.framenumber    
  endif else if (self.state eq 'REPLAYING') then begin
     widget_control, self.wfrn, set_value = self.recorder.index
  endif
end

;;;;;
;
; jansen_dvr::Create
;
; Create widget hierarchy
;
pro jansen_dvr::Create, wtop

  COMPILE_OPT IDL2
  
  wrecording = widget_base(wtop, /COLUMN, /GRID_LAYOUT, $
                           TITLE = self.title, $               ; for WIDGET_TAB
                           RESOURCE_NAME = 'Jansen')

  void = cw_field(wrecording, /FRAME, /RETURN_EVENTS, $
                  VALUE = self.filename, $
                  title = 'File Name:', UVALUE = 'FILENAME')
  
  wtgt = cw_field(wrecording, /FRAME, /RETURN_EVENTS, /ULONG, $
                  VALUE = 1000UL, $
                  title = '# Frames: ', UVALUE = 'TARGET')

  bvalues = ['Record', 'Pause', 'Stop', 'Snapshot']
  void = cw_bgroup(wrecording, bvalues, /ROW, $
                   LABEL_LEFT = 'Record', $
                   button_uvalue = strupcase(bvalues), $
                   /FRAME, /NO_RELEASE, UVALUE = 'RECORD')

  bvalues = ['Rewind', 'Pause', 'Play', 'Fast', 'Stop']
  void = cw_bgroup(wrecording, bvalues, /ROW, $
                   LABEL_LEFT = 'Replay', $
                   button_uvalue = strupcase(bvalues), $
                   /FRAME, /NO_RELEASE, UVALUE = 'REPLAY')
  
  ;wframeslider = widget_slider(wrecording, /FRAME, UVALUE = 'FRAMENUMBER', $
  ;                             MINIMUM = 0, MAXIMUM = 100, SENSITIVE = 0)

  wfrn = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
                  VALUE = 0UL, $
                  title = 'Frame #:  ')
  
  ;wftn = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
  ;                VALUE = 0UL, $
  ;                title = 'Feature #:')

  bvalues = ['Normal', 'Running', 'Sample/Hold']
  void = cw_bgroup(wrecording, bvalues, $
                   /ROW, /FRAME, $
                   LABEL_LEFT = 'Mode', $
                   /EXCLUSIVE, /NO_RELEASE, $
                   SET_VALUE = 0, UVALUE = 'HVMMODE')

  self.state = 'NORMAL'
  self.wtgt = wtgt
  self.wfrn = wfrn
  self.framenumber = 0UL
  self.widget_id = wrecording
end

;;;;;
;
; jansen_dvr::Init()
;
; Create the widget layout and set up the callback for the
; video recording object.
;
function jansen_dvr::Init, wtop, configuration, title

  COMPILE_OPT IDL2

  fullname = configuration.directory + path_sep() + configuration.filename
  self.setfilename, fullname
  self.title = title
  return, self.Jansen_Widget::Init(wtop) 
end

;;;;;
;
; jansen_dvr__define
;
pro jansen_dvr__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {Jansen_DVR, $
            inherits Jansen_Widget, $
            title: '', $
            state: '', $        ; 'paused', 'recording', 'replaying'
            recorder: obj_new(), $
            filename: '', $            
            wtgt: 0L, $
            framenumber: 0UL, $
            wfrn: 0L $
           }
end

