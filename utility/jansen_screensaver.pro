;+
; NAME:
;    jansen_screensaver
;
; PURPOSE:
;    Disable and resume X-Window screensaver
;
; CALLING SEQUENCE:
;    jansen_screensaver, [/suspend, /resume]
;
; KEYWORDS:
;    SUSPEND: If set, suspend screensaver
;    RESUME: If set, resume screensaver
;
; MODIFICATION HISTORY:
; 03/26/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
pro jansen_screensaver, suspend = _suspend, $
                        resume = _resume

  COMPILE_OPT IDL2, HIDDEN

  ;; Get the X-Window id of the running Jansen process
  xwininfo = jansen_search('xwininfo', /system)
  if strlen(xwininfo) eq 0 then $
     return

  cmd = xwininfo + ' -name Jansen | grep Jansen | grep -o "0x\w*"'
  spawn, cmd, wid, err

  if strlen(wid) eq 0 then $    ; Jansen is not running
     return

  ;; Set the state of the screensaver
  xdgss = jansen_search('xdg-screensaver', /system)
  if strlen(xdgss) eq 0 then $
     return

  suspend = (isa(_suspend, /number, /scalar)) ? keyword_set(_suspend) : 1
  suspend = (isa(_resume, /number, /scalar)) ? ~keyword_set(_resume) : suspend

  cmd = xdgss + ((suspend) ? ' suspend ' : ' resume ') + wid
  spawn, cmd
end
