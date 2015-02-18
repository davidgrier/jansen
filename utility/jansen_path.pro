;+
; NAME:
;    jansen_path
;
; PURPOSE:
;    Returns the current IDL search path as an array of strings
;
; CATEGORY:
;    Utility
;
; CALLING SEQUENCE:
;    path = jansen_path()
;
; OUTPUTS:
;    path: string array
;
; MODIFICATION HISTORY:
; 12/30/2013 Written by David G. Grier, New York University
; 02/17/2015 DGG revised for jansen
;
; Copyright (c) 2013-2015 David G. Grier
;-
function jansen_path

  COMPILE_OPT IDL2, HIDDEN
  
  return, strsplit(!PATH, path_sep(/search_path), /extract)
end
