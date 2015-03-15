;+
; NAME:
;    jansen_camera_pointgrey
;
; PURPOSE:
;    Object for acquiring and displaying images from a
;    PointGrey camera using the FlyCapture2 API.
;
; INHERITS:
;    jansen_camera
;    dgghwpointgrey
;
; REQUIREMENTS:
;    DGGhwPointGrey is defined in the idlpgr repository, which is
;    available at http://github.com/davidgrier/idlpgr
;    idlpgr provides IDL with a hardware interface to PointGrey's
;    FlyCapture2 API for controlling video cameras.  Installing
;    idlpgr therefore requires installing FlyCapture2.  See the
;    documentation in idlpgr for instructions.
;
; PROPERTIES:
;    [ G ] PROPERTIES: array of strings labeling the camera's
;       controllable properties.
;
;    All of the properties of DGGhwPointGrey are available here.
;
; METHODS:
;    All of the methods of Jansen_Camera are available here.
;
;    PropertyInfo(property): Returns anonymous structure
;        describing the chanacteristics of the named PROPERTY.
;
;    Property(name [, value]): Returns value of named property.
;        If VALUE is set, then value is written to the camera's
;        specified property.
;
; MODIFICATION HISTORY:
; 09/24/2013 Written by David G. Grier, New York University
; 01/01/2014 DGG Overhauled for new fab implementation.
; 01/27/2014 DGG First implementation of properties.
; 01/28/2014 DGG Clamp values, rather than raising an error
;    when values are out of range
; 03/04/2014 DGG Implement ORDER property
; 02/10/2015 DGG Updated PROPERTIES definition.
; 02/18/2015 DGG Added EXPOSURE_TIME property as synonym for SHUTTER.
; 03/04/2015 DGG Revised for DLM-based interface.
;
; Copyright (c) 2013-2015 David G. Grier
;-

;;;;;
;
; jansen_camera_pointgrey::RegisterProperties
;
pro jansen_camera_pointgrey::RegisterProperties

  COMPILE_OPT IDL2, HIDDEN

  self.name = 'jansen_camera_pointgrey '
  self.description = 'PointGrey Camera '

  foreach property, self.properties.keys() do begin
     info = self.propertyinfo(property)
     if ~info.present || ~info.manualSupported then $
        continue
     if info.absValSupported then $
        self.registerproperty, property, /float, $
            valid_range = [info.absmin, info.absmax] $
     else $
        self.registerproperty, property, /integer, $
            valid_range = [info.min, info.max]
  endforeach

  self.registerproperty, 'grayscale', /boolean, sensitive = 0
  
  self.setpropertyattribute, 'trigger_mode', sensitive = 0
  self.setpropertyattribute, 'trigger_delay', sensitive = 0
  self.setpropertyattribute, 'brightness', sensitive = 0
  self.setpropertyattribute, 'auto_exposure', sensitive = 0
  self.setpropertyattribute, 'frame_rate', sensitive = 0
end

;;;;;
;
; jansen_camera_pointgrey::Read
;
; Transfers a picture to the image
;
pro jansen_camera_pointgrey::Read

  COMPILE_OPT IDL2, HIDDEN

  ;;*self.data = self.dgghwpointgrey::read()
  self.data = ptr_new(self.dgghwpointgrey::read(), /no_copy)
  ;; NOTE: Is NO_COPY safe?
  if self.order then $
     *self.data = reverse(*self.data, 3 - self.grayscale, /overwrite)
end

;;;;;
;
; jansen_camera_pointgrey::SetProperty
;
; Set the camera properties
;
pro jansen_camera_pointgrey::SetProperty, exposure_time = exposure_time, $
                                          _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.dgghwpointgrey::SetProperty, _extra = re
  self.jansen_camera::SetProperty, _extra = re

  if isa(exposure_time, /number, /scalar) then $
     self.dgghwpointgrey::SetProperty, shutter = exposure_time
end

;;;;;
;
; jansen_camera_pointgrey::GetProperty
;
pro jansen_camera_pointgrey::GetProperty, data = data, $
                                          exposure_time = exposure_time, $
                                          _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.dgghwpointgrey::GetProperty, _extra = re
  self.jansen_camera::GetProperty, _extra = re

  if arg_present(data) then $
     data = *self.data

  if arg_present(exposure_time) then $
     self.dgghwpointgrey::GetProperty, shutter = exposure_time
end

;;;;;
;
; jansen_camera_pointgrey::Cleanup
;
; Close video stream
;
pro jansen_camera_pointgrey::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.dgghwpointgrey::Cleanup
  self.jansen_camera::Cleanup
end

;;;;;
;
; jansen_camera_pointgrey::Init
;
; Initialize the jansen_camera_pointgrey object:
; Open the video stream
; Load an image into the IDLgrImage object
;
function jansen_camera_pointgrey::Init, _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.jansen_camera::Init(_extra = re) then $
     return, 0B

  if ~self.dgghwpointgrey::Init(_extra = re) then $
     return, 0B
  
  self.data = ptr_new(self.dgghwpointgrey::read())
  ;; NOTE: Can we use NO_COPY safely?

  self.grayscale = (size(*self.data, /n_dimensions) eq 2)

  self.registerproperties

  return, 1B
end

;;;;;
;
; jansen_camera_pointgrey__define
;
; Define the jansen_camera_pointgrey object
;
pro jansen_camera_pointgrey__define

  COMPILE_OPT IDL2, HIDDEN
  
  struct = {jansen_camera_pointgrey, $
            inherits jansen_camera,  $
            inherits dgghwpointgrey. $
            grayscale: 0L            $
           }
end
