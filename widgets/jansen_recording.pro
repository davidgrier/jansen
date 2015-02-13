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
pro jansen_recording_event, event

  COMPILE_OPT IDL2, HIDDEN

  widget_control, event.top, get_uvalue = state
  widget_control, event.id,  get_uvalue = uval

  video = state.video

  case uval of
     'NAME': begin
        filename = event.value
        if filename.length gt 0 then begin
           filename = filepath(filename, root_dir = video.directory)
           if ~file_test(filename) || $
              dialog_message(filename + ' already exists. Overwrite?', $
                             /QUESTION, /DEFAULT_NO) then begin
              video.filename = filename
           endif else $
              widget_control, event.id, set_value = video.filename
        endif
     end
     
     'NUMBER': begin
        state['number'] = event.value
     end
     
     'CONTROLS': begin
        case event.value of
           0: video.recording = 1 ; record from camera
           1: video.recording = 4 ; pause
           2: video.recording = 0 ; stop, close file
           else:
        endcase
        print, video.recording
     end
     
     'HVMMODE': begin
        video.hvmmode = event.value
     end
     
     else: print, 'got', uval
  endcase
  
end


pro jansen_recording, wtop, video

  COMPILE_OPT IDL2, HIDDEN

  wrecording = widget_base(wtop, /COLUMN, /GRID_LAYOUT, $
                           EVENT_PRO = 'jansen_recording_event', $
                           RESOURCE_NAME = 'Jansen')
;  wname     = cw_filesel(wrecording, /FRAME, $
;                         FILTER = '*.h5', /FIX_FILTER, $
;                         PATH = video.directory, $
;                         /WARN_EXIST, UVALUE = 'NAME', $
;                         FILENAME = video.filename)
  wname     = cw_field(wrecording, /FRAME, /RETURN_EVENTS, $
                       VALUE = video.filename, $
                       title = 'File Name:', UVALUE = 'NAME')
  
  wnumber   = cw_field(wrecording, /FRAME, /RETURN_EVENTS, /ULONG, $
                       VALUE = 0UL, $
                       title = '# Frames: ', UVALUE = 'NUMBER')

  bvalues   = ['Record', 'Pause', 'Stop']
  wcontrols = cw_bgroup(wrecording, bvalues, /ROW, $
                        /FRAME, /NO_RELEASE, UVALUE = 'CONTROLS')

  wframes   = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
                       VALUE = 0UL, $
                       title = 'Frame #:  ')                     
  wfeatures = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
                       VALUE = 0UL, $
                       title = 'Feature #:')

  bvalues = ['Normal', 'Running', 'Sample/Hold']
  whvmmode = cw_bgroup(wrecording, bvalues, $
                       /ROW, /FRAME, $
                       LABEL_TOP = 'HVM Mode:', $
                       /EXCLUSIVE, /NO_RELEASE, $
                       SET_VALUE = video.hvmmode, UVALUE = 'HVMMODE')

end
