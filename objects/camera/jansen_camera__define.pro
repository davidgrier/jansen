;+
; NAME
;    jansen_camera()
;
; PURPOSE
;    Object interface for digital cameras
;
; INHERITS
;    jansen_object
;
; PROPERTIES
; [ G ] DATA: byte-valued array of image data
; [IG ] DIMENSIONS: [[3], w, h] dimensions of images
; [IGS] ORDER: flag: if set, flip image vertically
; [IGS] HFLIP: flag: if set, flip image horizontally
; [IGS] MPP: Magnification [micrometers/pixel]
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
function jansen_camera::read
  
  COMPILE_OPT IDL2, HIDDEN
  
  self.read
  return, *self.data
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
; If possible, inheriting classes should support hflip and order in hardware.
; 
pro jansen_camera::read

  COMPILE_OPT IDL2, HIDDEN

  dimensions = size(*self.data, /dimensions)
  *self.data = byte(255*randomu(seed, dimensions))
  if self.hflip then $
     *self.data = reverse(*self.data, 1, /overwrite)
  if self.order then $
     *self.data = reverse(*self.data, 2, /overwrite)
end

;;;;;
;
; jansen_camera::SetProperty
;
pro jansen_camera::SetProperty, dimensions = dimensions, $
                                order = order, $
                                hflip = hflip, $
                                mpp = mpp, $
                                _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.jansen_object::SetProperty, _extra = re

  if isa(dimensions, /number, /array) then $
     message, 'DIMENSIONS can only be set at initialization', /inf

  if isa(order, /scalar, /number) then $
     self.order = (order ne 0)

  if isa(hflip, /scalar, /number) then $
     self.hflip = keyword_set(hflip)

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

  self.jansen_object::GetProperty, _extra = re

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

  if ~self.jansen_object::Init(_extra = re) then $
     return, 0B

  if isa(dimensions, /number, /array) then begin
     if ~total(n_elements(dimensions) eq [2, 3]) then $
        return, 0B
  endif else $
     dimensions = [640L, 480]

  if isa(mpp, /scalar, /number) then $
     self.mpp = float(mpp)

  if isa(order, /scalar, /number) then $
     self.order = keyword_set(order)

  if isa(hflip, /scalar, /number) then $
     self.hflip = keyword_set(hflip)

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
            inherits jansen_object, $
            data: ptr_new(), $
            order: 0L, $
            hflip: 0L, $
            mpp: 0. $
           }
end
