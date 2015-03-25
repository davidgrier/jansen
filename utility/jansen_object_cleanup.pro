;+
; NAME:
;    jansen_object_cleanup
;
; PURPOSE:
;    Utility routine for jansen_widget objects
;
; MODIFICATION HISTORY:
; 03/01/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
pro jansen_object_cleanup, widget_id

  COMPILE_OPT IDL2, HIDDEN

  widget_control, widget_id, get_uvalue = owidget
  owidget.cleanup, widget_id
end
