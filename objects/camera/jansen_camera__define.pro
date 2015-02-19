;+
; NAME
;    jansen_camera()
;
; PURPOSE
;    Object interface for digital cameras
;
; INHERITS
;    fab_object
;
; PROPERTIES
;    DATA
;        [ G ] byte-valued array of image data
;    DIMENSIONS
;        [IG ] [w,h,[3]] dimensions of images
;    EXPOSURE_TIME
;        [IGS] exposure time of camera
;    GAIN
;        [IGS] gain of camera
;    ORDER
;        [IGS] flag: if set, flip image vertically
;    HFLIP
;        [IGS] flag: if set, flip image horizontally
;    GREYSCALE
;        [IG ] flag: If set deliver greyscale images
;    MPP
;        [IGS] Magnification [micrometers/pixel]
;
; METHODS
;    READ()
;        Reads image and returns resulting DATA
;
;    READ
;        Read image into DATA
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER property.
; 04/06/2014 DGG Enum values for ORDER and HFLIP.
; 02/18/2015 DGG Added EXPOSURE_TIME and GAIN properties
;
; Copyright (c) 2013-2015 David G. Grier
;-

;;;;;
;
; jansen_camera::read()
;
function jansen_camera::read
  
  COMPILE_OPT IDL2, HIDDEN
  
  self.read
  data = *self.data
  return, data
end

;;;;;
;
; jansen_camera::read
;
pro jansen_camera::read

  COMPILE_OPT IDL2, HIDDEN

  dimensions = size(*self.data, /dimensions)
  *self.data = byte(255*randomu(seed, dimensions))

end

;;;;;
;
; jansen_camera::SetProperty
;
pro jansen_camera::SetProperty, dimensions = dimensions, $
                                exposure_time = exposure_time, $
                                gain = gain, $
                                greyscale = greyscale, $
                                order = order, $
                                hflip = hflip, $
                                mpp = mpp, $
                                debug = debug, $
                                _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.fab_object::SetProperty, _extra = re

  if isa(dimensions, /number, /array) then $
     message, 'DIMENSIONS can only be set at initialization', /inf

  if isa(exposure_time, /scalar, /number) then $
     self.exposure_time = exposure_time

  if isa(gain, /scalar, /number) then $
     self.gain = gain

  if isa(greyscale, /scalar, /number) then $
     message, 'GREYSCALE can only be set at initialization', /inf

  if isa(order, /scalar, /number) then $
     self.order = (order ne 0)

  if isa(hflip, /scalar, /number) then $
     self.hflip = (hflip ne 0)

  if isa(mpp, /scalar, /number) then $
     self.mpp = mpp

  if isa(debug, /scalar, /number) then $
     self.debug = debug

end

;;;;;
;
; jansen_camera::GetProperty
;
pro jansen_camera::GetProperty, data = data, $
                                dimensions = dimensions, $
                                exposure_time = exposure_time, $
                                gain = gain, $
                                greyscale = greyscale, $
                                order = order, $
                                hflip = hflip, $
                                mpp = mpp, $
                                debug = debug, $
                                _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.fab_object::GetProperty, _extra = re

  if arg_present(data) then $
     data = *self.data

  if arg_present(dimensions) then $
     dimensions = size(*self.data, /dimensions)

  if arg_present(mpp) then $
     mpp = self.mpp

  if arg_present(exposure_time) then $
     exposure_time = self.exposure_time

  if arg_present(gain) then $
     gain = self.gain

  if arg_present(greyscale) then $
     greyscale = self.greyscale

  if arg_present(order) then $
     order = self.order

  if arg_present(hflip) then $
     hflip = self.hflip

  if arg_present(debug) then $
     debug = self.debug

end
                            
;;;;;
;
; jansen_camera::Cleanup
;
pro jansen_camera::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  ptr_free, self.data

end

;;;;;
;
; jansen_camera::Init()
;
; Should be overriden by specific camera implementation
;
function jansen_camera::Init, dimensions = dimensions, $
                              exposure_time = exposure_time, $
                              gain = gain, $
                              greyscale = greyscale, $
                              order = order, $
                              hflip = hflip, $
                              mpp = mpp, $
                              debug = debug, $
                              _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.fab_object::Init(_extra = re) then $
     return, 0B

  self.debug = keyword_set(debug)

  if isa(dimensions, /number, /array) then begin
     if ~total(n_elements(dimensions) eq [2, 3]) then $
        return, 0B
  endif else $
     dimensions = [640L, 480]
  
  if isa(exposure_time, /scalar, /number) then $
     self.exposure_time = exposure_time
  
  if isa(gain, /scalar, /number) then $
     self.gain = gain

  if isa(mpp, /scalar, /number) then $
     self.mpp = float(mpp)

  if isa(order, /scalar, /number) then $
     self.order = (order ne 0)

  if isa(hflip, /scalar, /number) then $
     self.hflip = (hflip ne 0)

  self.data = ptr_new(make_array(dimensions, /byte), /no_copy)

  self.greyscale = n_elements(dimensions) eq 2

  self.name = 'jansen_camera '
  self.description = 'Generic Camera '
  self.setpropertyattribute, 'name', sensitive = 0
  self.setpropertyattribute, 'description', sensitive = 0
  self.registerproperty, 'order', enum = ['Normal', 'Flipped']
  self.registerproperty, 'hflip', enum = ['Normal', 'Flipped']
  self.registerproperty, 'exposure_time', /float, sensitive = 0
  self.registerproperty, 'gain', /float, sensitive = 0
  self.registerproperty, 'greyscale', /boolean, sensitive = 0
  self.registerproperty, 'mpp', /float, sensitive = 0
  self.setpropertyattribute, 'mpp', hide = (self.mpp eq 0)

  return, 1B
end

;;;;;
;
; jansen_camera__define
;
pro jansen_camera__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {jansen_camera, $
            inherits fab_object, $
            data: ptr_new(), $
            exposure_time: 0., $
            gain: 0., $
            greyscale: 0L, $
            order: 0L, $
            hflip: 0L, $
            mpp: 0., $
            debug: 0L $
           }
end
