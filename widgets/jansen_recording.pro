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
pro jansen_recording, wtop

  COMPILE_OPT IDL2, HIDDEN

  wrecording = widget_base(wtop, /COLUMN)
  wname = cw_field(wrecording, title = 'Name:', $
                   /FRAME, /RETURN_EVENTS, /FOCUS_EVENTS)
  wnumber = cw_field(wrecording, title = '# Frames:', /ULONG, $
                     /FRAME, /RETURN_EVENTS, /FOCUS_EVENTS)
  bvalues = ['Record', 'Pause', 'Stop']
  wcontrols = cw_bgroup(wrecording, bvalues, /ROW, $
                        /FRAME, /NO_RELEASE)
  wframes   = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
                       title = 'Frame #:  ')                     
  wfeatures = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
                       title = 'Feature #:')

  bvalues = ['Normal', 'Running', 'Sample/Hold']
  whvmmode = cw_bgroup(wrecording, bvalues, $
                       /ROW, /FRAME, $
                       LABEL_TOP = 'HVM Mode:', $
                       /EXCLUSIVE, /NO_RELEASE, $
                       SET_VALUE = 0)
  jansen_align_column, wrecording
end
