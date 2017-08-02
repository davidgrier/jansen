;+
; NAME
;    jansen_camera_idlv4l2()
;
; PURPOSE
;    Object interface for Idlv4l2 video input.
;
; INHERITS
;    jansen_camera
;    Idlv4l2
;
; PROPERTIES
;    [IGS] GREYSCALE: boolean flag to provide greyscale images.
;
; MODIFICATION HISTORY
; 08/02/2017 DGG First implementation.
;
; Copyright (c) 2017 David G. Grier
;-

;;;;;
;
; jansen_camera_idlv4l2::Read
;
pro jansen_camera_idlv4l2::Read

  COMPILE_OPT IDL2, HIDDEN

  self.idlv4l2::read
end

;;;;;
;
; jansen_camera_idlv4l2::Read()
;
function jansen_camera_idlv4l2::Read

  COMPILE_OPT IDL2, HIDDEN

  return, self.idlv4l2::read()
end

;;;;;
;
; jansen_camera_idlv4l2::SetProperty
;
pro jansen_camera_idlv4l2::SetProperty, _extra = ex

  COMPILE_OPT IDL2, HIDDEN

  self.idlv4l2::SetProperty, _extra = ex
  self.jansen_camera::SetProperty, _extra = ex
end

;;;;;
;
; jansen_camera_idlv4l2::GetProperty
;
pro jansen_camera_idlv4l2::GetProperty, data = data, $
                                        _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(data) then $
     self.idlv4l2::GetProperty, data = data
  self.idlv4l2::GetProperty, _extra = ex
  self.jansen_camera::GetProperty, _extra = ex
end
                                   
;;;;;
;
; jansen_camera_idlv4l2::Init()
;
function jansen_camera_idlv4l2::Init, dimensions = _dimensions, $
                                      _extra = ex

  COMPILE_OPT IDL2, HIDDEN

  ;catch, error
  ;if (error ne 0L) then begin
  ;   catch, /cancel
  ;   return, 0B
  ;endif

  if ~self.idlv4l2::init(dimensions = _dimensions, _extra = ex) then $
     return, 0B

  self.idlv4l2::GetProperty, dimensions = dimensions

  if ~self.jansen_camera::init(dimensions = dimensions, _extra = ex) then $
     return, 0B

  self.name = 'jansen_camera_idlv4l2 '
  self.description = 'IDLV4L2 Camera '
  self.registerproperty, 'grayscale', /boolean
  
  return, 1B
end

;;;;;
;
; jansen_camera_idlv4l2::Cleanup
;
pro jansen_camera_idlv4l2::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.jansen_camera::Cleanup
  self.idlv4l2::Cleanup
end

;;;;;
;
; jansen_camera_idlv4l2__define
;
pro jansen_camera_idlv4l2__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {jansen_camera_idlv4l2,   $
            inherits jansen_camera, $
            inherits idlv4l2     $
           }
end
