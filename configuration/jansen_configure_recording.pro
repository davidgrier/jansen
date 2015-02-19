;+
; NAME
;    jansen_configure_recording()
;
; Options:
; DIRECTORY:   string containing name of the recording directory
; FILENAME:    filename for recording video data
; COMPRESSION: Integer compression level (0 -- 9)
;
; MODIFICATION HISTORY
; 02/19/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
function jansen_configure_recording, configuration

  COMPILE_OPT IDL2, HIDDEN

  directory = ''
  filename = ''
  compression = 0
  
  if configuration.haskey('recording_directory') then $
     directory = configuration['recording_directory']

  if configuration.haskey('recording_filename') then $
     filename = configuration['recording_filename']

  if configuration.haskey('recording_compression') then $
     compression = long(configuration['recording_compression'])

  recording = {directory: directory, $
               filename: filename, $
               compression: compression $
              }
  
  configuration['recording'] = recording
  return, 'recording'
end
