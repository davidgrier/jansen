;+
; NAME
;    jansen_configure_video()
;
; Options:
; CAMERA:     reference to jansen_camera object that will provide images
; ORDER:      flag: set to flip image vertically
; FRAMERATE:  number of images per second
;
; MODIFICATION HISTORY
; 02/12/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
function jansen_configure_video, configuration

  COMPILE_OPT IDL2, HIDDEN

  if configuration.haskey('camera') then begin
     help, camera
     camera = configuration['camera']
  endif
  
  if configuration.haskey('video_order') then $
     order = long(configuration['video_order'])
  
  if configuration.haskey('video_frame_rate') then $
     if execute('a = '+configuration['video_frame_rate'], 1, 1) then $
        frame_rate = a

  video = jansen_video(camera = camera, order = order, $
                       frame_rate = frame_rate)

  if ~isa(video, 'jansen_video') then $
     configuration['error'] = 'could not initialize video system'

  configuration['video'] = video
  return, 'video'
end
