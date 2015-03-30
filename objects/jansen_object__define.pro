;+
; NAME:
;    jansen_object
;
; PURPOSE:
;    Base class for components of the jansen system.
;
; INHERITS:
;    IDL_Object
;    IDLitComponent
;
; PROPERTIES:
; [ G ] ALL: ordered hash of all properties and their values
; [ G ] ADJUSTABLE: ordered hash of all adjustable properties,
;        and their values
;
; METHODS:
;    jansen_object::HasProperty(property)
;        Determine whether or not the jansen_object has a named property.
;        INPUT:
;            property: string or string array of property names
;        OUTPUT:
;            * 1 if the object has the named property and 0 otherwise.
;            * array of 1's and 0's if the input is an array of names.
;             
;    jansen_object::GetProperty

;    See documentation oof IDLitComponent and WIDGET_PROPERTYSHEET
;    to expose properties for property sheets.
;
; MODIFICATION HISTORY:
; 12/15/2013 Written by David G. Grier, New York University
; 03/29/2014 DGG Added documentation.
; 02/15/2015 DGG Added HasProperty method.
; 03/24/2015 DGG Updated for jansen
;
; Copyright (c) 2013-2015 David G. Grier
;-
;;;;;
;
; jansen_object::HasProperty()
;
function jansen_object::HasProperty, property

  COMPILE_OPT IDL2, HIDDEN

  if isa(property, 'string') then $
     return, self.queryproperty(property)

  return, 0
end

;;;;;
;
; jansen_object::GetProperty
;
pro jansen_object::GetProperty, all = all, $
                                adjustable = adjustable, $
                                _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN
  
  self.IDLitComponent::GetProperty, _extra = re

  if arg_present(all) then begin
     all = orderedhash()
     properties = self.queryproperty()
     foreach property, properties do begin
        self.getpropertyattribute, property, hide = h
        if ~h then begin
           if self.getpropertybyidentifier(property, value) then $
              all[property] = value $
           else $
              all[property] = 'not set'
        endif
     endforeach
   endif

   if arg_present(adjustable) then begin
      adjustable = orderedhash()
      properties = self.queryproperty()
      foreach property, properties do begin
         self.getpropertyattribute, property, sensitive = s, hide = h
         if s and ~h then begin
            if self.getpropertybyidentifier(property, value) then $
               adjustable[property] = value $
            else $
               adjustable[property] = 'not set'
         endif
      endforeach
   endif
end

;;;;
;
; jansen_object::Cleanup
;
pro jansen_object::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.IDLitComponent::Cleanup
end

;;;;;
;
; jansen_object::Init()
;
function jansen_object::Init, _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.IDLitComponent::Init(_extra = re) then $
     return, 0B

  self.name = 'jansen_object '
  self.description = 'Object '

  return, 1B
end

;;;;;
;
; jansen_object__define
;
pro jansen_object__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {jansen_object,           $
            inherits IDLitComponent, $
            inherits IDL_Object      $
           }
end
