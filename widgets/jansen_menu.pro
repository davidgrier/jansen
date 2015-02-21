;+
; NAME:
;    jansen_menu
;
; PURPOSE:
;    Create the pull-down menus for jansen
;
; CALLING SEQUENCE:
;    jansen_menu, parent
;
; INPUTS:
;    parent: widget reference to a menu bar
;
; MODIFICATION HISTORY:
; 02/12/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

pro jansen_menu, bar

  COMPILE_OPT IDL2, HIDDEN

;;;
;;; FILE
;;;
  file_menu = widget_button(bar, value = 'File', /menu)
;  void = widget_button(file_menu, value = 'Save Configuration...', $
;                       event_pro = 'jansen_save')
;;; Quit should be handled by the parent
  void = widget_button(file_menu, value = 'Quit', uvalue = 'QUIT')

;;;
;;; VIDEO
;;;
;  video_menu = widget_button(bar, value = 'Video', /menu, $
;                             event_pro = 'jansen_menu_event')
;  void = widget_button(video_menu, value = 'Properties...', $
;                       event_pro = 'jansen_properties', uvalue = 'VIDEO')
;  void = widget_button(video_menu, value = 'Camera...', $
;                       event_pro = 'jansen_properties', uvalue = 'CAMERA')
;  void = widget_button(video_menu, value = 'Take Snapshot...', uvalue = 'SNAPSHOT')
;  void = widget_button(video_menu, value = 'Recording Directory...', uvalue = 'RECDIR')
;  void = widget_button(video_menu, value = 'Record', uvalue = 'RECORD')

end
