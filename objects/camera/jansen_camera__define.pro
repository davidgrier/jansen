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
;    ORDER
;        [IGS] flag: if set, flip image vertically
;    HFLIP
;        [IGS] flag: if set, flip image horizontally
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
; 03/15/2015 DGG Removed properties that are not actually provided by
;     the base class
;
; Copyright (c) 2013-2015 David G. Grier
;-

;;;;;
;
; jansen_camera::read()
;
; Classes that can provide hflip and order in hardware should override
; this function for greater efficiency.  
; 
function jansen_camera::read
  
  COMPILE_OPT IDL2, HIDDEN
  
  self.read
  return, rotate(temporary(*self.data), (5*self.hflip + 7*self.order) mod 10)
end

;;;;;
;
; jansen_camera::read
;
; Classes that inherit jansen_camera should override this procedure
; and either should replace the values in *self.data, as is done here,
; or else should move the pointer to a new data set, as in
; self.data = ptr_new(newimage, /no_copy)
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
                                order = order, $
                                hflip = hflip, $
                                mpp = mpp, $
                                _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.fab_object::SetProperty, _extra = re

  if isa(dimensions, /number, /array) then $
     message, 'DIMENSIONS can only be set at initialization', /inf

  if isa(exposure_time, /scalar, /number) then $
     self.exposure_time = exposure_time

  if isa(gain, /scalar, /number) then $
     self.gain = gain

  if isa(order, /scalar, /number) then $
     self.order = (order ne 0)

  if isa(hflip, /scalar, /number) then $
     self.hflip = (hflip ne 0)

  if isa(mpp, /scalar, /number) then $
     self.mpp = mpp
end

;;;;;
;
; jansen_camera::GetProperty
;
pro jansen_camera::GetProperty, data = data, $
                                dimensions = dimensions, $
                                order = order, $
                                hflip = hflip, $
                                mpp = mpp, $
                                _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.fab_object::GetProperty, _extra = re

  if arg_present(data) then $
     data = *self.data

  if arg_present(dimensions) then begin
     dimensions = size(*self.data, /dimensions)
     if n_elements(dimensions) eq 3 then $
        dimensions = dimensions[where(dimensions ne 3)]
  endif
  
  if arg_present(mpp) then $
     mpp = self.mpp

  if arg_present(order) then $
     order = self.order

  if arg_present(hflip) then $
     hflip = self.hflip
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
                              order = order, $
                              hflip = hflip, $
                              mpp = mpp, $
                              _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.fab_object::Init(_extra = re) then $
     return, 0B

  if isa(dimensions, /number, /array) then begin
     if ~total(n_elements(dimensions) eq [2, 3]) then $
        return, 0B
  endif else $
     dimensions = [640L, 480]
  
  if isa(mpp, /scalar, /number) then $
     self.mpp = float(mpp)

  if isa(order, /scalar, /number) then $
     self.order = (order ne 0)

  if isa(hflip, /scalar, /number) then $
     self.hflip = (hflip ne 0)

  self.data = ptr_new(make_array(dimensions, /byte), /no_copy)

  self.name = 'jansen_camera '
  self.description = 'Generic Camera '
  self.setpropertyattribute, 'name', sensitive = 0
  self.setpropertyattribute, 'description', sensitive = 0
  self.registerproperty, 'order', enum = ['Normal', 'Flipped']
  self.registerproperty, 'hflip', enum = ['Normal', 'Flipped']
  self.registerproperty, 'mpp', /float, hide = 1

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
            order: 0L, $
            hflip: 0L, $
            mpp: 0. $
           }
end
