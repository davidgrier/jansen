;+
; NAME
;    jansen_configure_camera()
;
; Options:
; OBJECT:     name of camera object
; GREYSCALE:  flag: '1': provide greyscale images
; ORDER:      flag: '1': flips images vertically
; DIMENSIONS: [w,h]: requested dimensions of camera images
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER property
; 02/17/2015 DGG Adapted for jansen.
;
; Copyright (c) 2013-2015 David G. Grier
;-
function jansen_configure_camera, configuration

  COMPILE_OPT IDL2, HIDDEN

  camera_object = (configuration.haskey('camera_object')) ? $
                  configuration['camera_object'] : 'fabcamera'

  greyscale = (configuration.haskey('camera_greyscale')) ? $
              configuration['camera_greyscale'] eq '1' : 1

  if configuration.haskey('camera_order') then $
     order = long(configuration['camera_order'])

  if configuration.haskey('camera_hflip') then $
     hflip = long(configuration['camera_hflip'])

  mpp = (configuration.haskey('camera_mpp')) ? $
        float(configuration['camera_mpp']) : 0.

  if configuration.haskey('camera_dimensions') then $
     if execute('a = '+configuration['camera_dimensions'], 1, 1) then $
        dimensions = a

  if configuration.haskey('camera_exposure_time') then $
     exposure_time = float(configuration['camera_exposure_time'])

  if configuration.haskey('camera_gain') then $
     gain = float(configuration['camera_gain'])

  if configuration.haskey('camera_frame_rate') then $
     frame_rate = float(configuration['camera_frame_rate'])

  camera = obj_new(camera_object, greyscale = greyscale, $
                   order = order, hflip = hflip, $
                   dimensions = dimensions, mpp = mpp, $
                   exposure_time = exposure_time, $
                   gain = gain, frame_rate = frame_rate)

  if ~isa(camera, 'jansen_camera') then $
     configuration['error'] = 'could not initialize camera'

  configuration['camera'] = camera
  return, 'camera'
end
