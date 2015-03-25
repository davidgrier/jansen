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
; KEYWORD:
;    system: Search for system files rather than IDL files.
;
; OUTPUTS:
;    path: String containing the fully qualified path to the file.
;
; MODIFICATION HISTORY:
; 12/30/2013 Written by David G. Grier, New York University
; 02/17/2015 DGG revised for jansen
; 03/20/2015 DGG implemented SYSTEM.
;
; Copyright (c) 2013-2015 David G. Grier
;-
function jansen_search, filename, $
                        system = system, $
                        _extra = ex

  COMPILE_OPT IDL2, HIDDEN
  
  search_path = (keyword_set(system)) ? getenv('PATH') : !PATH
  dir = strsplit(search_path, path_sep(/search_path), /extract)
  path = file_search(dir, filename, _extra = ex)
  return, path[0]
end
