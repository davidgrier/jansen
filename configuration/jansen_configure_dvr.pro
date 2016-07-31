;+
; NAME
;    jansen_configure_dvr()
;
; Options:
; DIRECTORY:   string containing name of the recording directory
; FILENAME:    filename for recording video data
; COMPRESSION: Integer compression level (0 -- 9)
;
; MODIFICATION HISTORY
; 02/19/2015 Written by David G. Grier, New York University
; 07/29/2016 DGG update for DVR functionality
;
; Copyright (c) 2015-2016 David G. Grier
;-
function jansen_configure_dvr, configuration

  COMPILE_OPT IDL2, HIDDEN

  directory = '~/data'
  filename = 'jansen.h5'
  compression = 0
  
  if configuration.haskey('dvr_directory') then $
     directory = configuration['dvr_directory']

  if configuration.haskey('dvr_filename') then $
     filename = configuration['dvr_filename']

  if configuration.haskey('dvr_compression') then $
     compression = long(configuration['dvr_compression'])

  dvr = {directory: directory, $
         filename: filename, $
         compression: compression $
        }
  
  configuration['dvr'] = dvr
  return, 'dvr'
end
