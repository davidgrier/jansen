;+
; NAME:
;    getjansen
;
; PURPOSE:
;    Returns the base state structure of a running instance of Jansen.
;    This provides access to all of the subsystems of Jansen, including
;    objects controlling its hardware and defining its traps.
;
; CATEGORY:
;    Video microscopy, instrument control
;
; CALLING SEQUENCE:
;    s = getjansen()
;
; INPUTS:
;    None
;
; OUTPUTS:
;    s: hash() of the running system's state.
;
; COMMON BLOCKS:
;    managed: Reads data from the common block used by XMANAGER to
;       manage the widget hierarchy in Jansen.
;
; MODIFICATION HISTORY:
; 10/04/2011 Written by David G. Grier, New York University.
; 12/25/2013 DGG Updated for nufab
; 02/17/2015 DGG Updated for jansen
; 
; Copyright (c) 2011-2015 David G. Grier
;-
function getjansen

common managed, ids, names, modalList

nmanaged = n_elements(ids)
if (nmanaged lt 1) then begin
   message, 'jansen is not running', /inf
   return, hash()
endif

w = where(names eq 'jansen', ninstances)
if ninstances ne 1 then begin
   message, 'jansen is not running', /inf
   return, hash()
endif

widget_control, ids[w], get_uvalue = s

return, s
end
