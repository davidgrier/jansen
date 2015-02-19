;+
; NAME:
;    jansen_search
;
; PURPOSE:
;    Returns the fully qualified path to a specified file.
;
; CATEGORY:
;    Utility
;
; CALLING SEQUENCE:
;    path = jansen_search(filename)
;
; INPUT:
;    filename: String containing the name of a file to be found
;        in IDL's search path.
;
; OUTPUTS:
;    path: String containing the fully qualified path to the file.
;
; MODIFICATION HISTORY:
; 12/30/2013 Written by David G. Grier, New York University
; 02/17/2015 DGG revised for jansen
;
; Copyright (c) 2013-2015 David G. Grier
;-
function jansen_search, filename, _extra = ex

  COMPILE_OPT IDL2, HIDDEN
  
  dir = strsplit(!PATH, path_sep(/search_path), /extract)
  path = file_search(dir, filename, _extra = ex)
  return, path[0]
end
