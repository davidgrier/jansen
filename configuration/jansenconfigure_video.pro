;+
; NAME
;    jansenconfigure_video()
;
; Options:
; CAMERA:     reference to fabcamera object that will provide images
; ORDER:      flag: set to flip image vertically
; FRAMERATE:  number of images per second
;
; MODIFICATION HISTORY
; 02/12/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
function jansenconfigure_video, configuration

  COMPILE_OPT IDL2, HIDDEN

  if configuration.haskey('camera') then $
     camera = configuration['camera']
  
  if configuration.haskey('video_order') then $
     order = long(configuration['video_order'])
  
  if configuration.haskey('video_framerate') then $
     if execute('a = '+configuration['video_framerate'], 1, 1) then $
        framerate = a

  video = jansenvideo(camera = camera, order = order, $
                      framerate = framerate)

  if ~isa(video, 'jansenvideo') then $
     configuration['error'] = 'could not initialize video system'

  configuration['video'] = video
  return, 'video'
end
