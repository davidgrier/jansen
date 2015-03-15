;+
; NAME
;    jansen_camera_opencv()
;
; PURPOSE
;    Object interface for OpenCV video input.
;
; INHERITS
;    jansen_camera
;
; PROPERTIES
;    DLM    [ G ]
;        file specification of object library.
;
;    NUMBER [IG ]
;        index of OpenCV camera.
;        Default: 0
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER property.
; 04/06/2014 DGG Implemented HFLIP property.
; 02/17/2015 DGG Adapted for jansen.
;
; Copyright (c) 2013-2015 David G. Grier
;-

;;;;;
;
; jansen_camera_opencv::Read
;
pro jansen_camera_opencv::Read, geometry = geometry

  COMPILE_OPT IDL2, HIDDEN

  self.data = ptr_new(self.dgghwvideo::read(), /no_copy)
  *self.data = rotate(temporary(*self.data), (5*self.hflip + 7*self.order) mod 10)
end

;;;;;
;
; jansen_camera_opencv::SetProperty
;
pro jansen_camera_opencv::SetProperty, _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  self.dgghwvideo::SetProperty, _extra = ex
  self.jansen_camera::SetProperty, _extra = ex
end

;;;;;
;
; jansen_camera_opencv::GetProperty
;
pro jansen_camera_opencv::GetProperty, _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  self.dgghwvideo::GetProperty, _extra = ex
  self.jansen_camera::GetProperty, _extra = ex
end
                                   
;;;;;
;
; jansen_camera_opencv::Init()
;
function jansen_camera_opencv::Init, _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  catch, error
  if (error ne 0L) then begin
     catch, /cancel
     return, 0B
  endif

  if ~self.dgghwvideo::init(_extra = re) then $
     return, 0B
  
  if ~self.jansen_camera::init(_extra = re) then $
     return, 0B

  self.data = ptr_new(self.dgghwvideo::read(), /no_copy)

  self.name = 'jansen_camera_opencv '
  self.description = 'OpenCV Camera '
  
  return, 1B
end

;;;;;
;
; jansen_camera_opencv::Cleanup
;
pro jansen_camera_opencv::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.jansen_camera::Cleanup
  self.dgghwvideo::Cleanup
end

;;;;;
;
; jansen_camera_opencv__define
;
pro jansen_camera_opencv__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {jansen_camera_opencv, $
            inherits dgghwvideo, $
            inherits jansen_camera $
           }
end
