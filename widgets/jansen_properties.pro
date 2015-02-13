;+
; NAME:
;    jansen_properties
;
; PURPOSE:
;    Create a propertysheet tailored for Jansen objects
;
; NOTES:
; .Xdefaults:
; Idl*Jansen*XmLabel*background: lightyellow
;
; MODIFICATION HISTORY:
; 02/13/2015 DGG Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; Jansen_Properties_Reload
;
; Reload properties for an object that may have changed
;
pro jansen_properties_reload, s

COMPILE_OPT IDL2, HIDDEN

if ~s.haskey('propertysheet') then return

widget_control, s['propertysheet'], get_value = obj
;;; Update for any object that has time-varying properties
;;; Could include temperature, laser power.

end

;;;;;
;
; Jansen_Properties_Refresh
;
; Refresh properties that may have changed for an existing object.
; Only motion events appear to require a refresh, and these
; only affect traps and the stage.
;
; NOTE: no perceived effect if one object is being displayed but
; another calls for a refresh event.
;
pro jansen_properties_refresh, s

COMPILE_OPT IDL2, HIDDEN

if s.haskey('propertysheet') then begin
   widget_control, s['propertysheet'], get_value = obj
   if isa(obj, 'fabstage') then $
      widget_control, s['propertysheet'], /refresh_property
endif

end

;;;;;
;
; Jansen_Properties_Update
;
; Update object properties in response to user input
;
pro jansen_properties_update, event

COMPILE_OPT IDL2, HIDDEN

if (event.type eq 0) then begin
   value = widget_info(event.ID, COMPONENT = event.component, $
                       PROPERTY_VALUE = event.identifier)
   event.component->SetPropertyByIdentifier, event.identifier, value
endif
 
end
 
;;;;;
;
; Jansen_Properties_Event
;
; Handle resize events and quit button
;
pro jansen_properties_event, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.id, get_uvalue = uvalue
case uvalue of
   'REFRESH': begin
      widget_control, event.top, get_uvalue = s
      widget_control, s['propertysheet'], /refresh_property
   end

   'DONE': widget_control, event.top, /destroy
;   else: begin
;      widget_control, event.top, get_uvalue = s
;      widget_control, s['propertysheet'], SCR_XSIZE = event.x, SCR_YSIZE = event.y
;   end
endcase

end

;;;;;
;
; Jansen_Properties_Cleanup
;
pro jansen_properties_cleanup, wid

COMPILE_OPT IDL2, HIDDEN

widget_control, wid, get_uvalue = s
s.remove, 'propertysheet'
end

;;;;;
;
; Jansen_Properties
;
; The main routine
;
pro jansen_properties, jansen_event, refresh = refresh, reload = reload

COMPILE_OPT IDL2, HIDDEN

if keyword_set(refresh) then begin
   jansen_properties_refresh, jansen_event
   return
endif

if keyword_set(reload) then begin
   jansen_properties_reload, jansen_event
   return
endif

widget_control, jansen_event.top, get_uvalue = s
widget_control, jansen_event.id,  get_uvalue = uval

case uval of
   'VIDEO': obj = s['video']

   'CAMERA' : obj = s['camera']

   'RECORDER' : obj = s['recorder']

   'STAGE' : obj = s['stage']

   'ILLUMINATION': obj = s['illumination']

   'SHUTTER': obj = s['shutter']

   else: return
endcase

;;; Property sheet already realized -- display new object
if s.haskey('propertysheet') then begin
   widget_control, s['propertysheet'], set_value = obj
   return
endif

;;; Otherwise create a new property sheet
base = widget_base(title = 'Jansen Properties', $
                   /column, resource_name = 'Jansen', /tlb_size_event)

nentries = n_elements(obj)

prop = widget_propertysheet(base, value = obj, $
                            event_pro = 'jansen_properties_update', $
                            /frame)

void = widget_button(base, value = 'Refresh', uvalue = 'REFRESH')
done = widget_button(base, value = 'DONE', uvalue = 'DONE')

s['propertysheet'] = prop
widget_control, base, set_uvalue = s, /no_copy
 
; Activate the widgets.
widget_control, base, /realize
 
xmanager, 'jansen_properties', base, /no_block, $
          group_leader = jansen_event.top, $
          cleanup = 'jansen_properties_cleanup'
end
