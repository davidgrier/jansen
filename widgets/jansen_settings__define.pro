;+
; NAME:
;    jansen_settings
;
; PURPOSE:
;    Control panel for adjusting instrument settings.
;
; MODIFICATION HISTORY:
; 02/13/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; jansen_settings::handleEvent
;
pro jansen_settings::handleEvent, event

  COMPILE_OPT IDL2, HIDDEN

  if (event.type eq 0) then begin
     value = widget_info(event.id, COMPONENT = event.component, $
                         PROPERTY_VALUE = event.identifier)
     event.component -> SetPropertyByIdentifier,  event.identifier, value
  endif
  
end

;;;;;
;
; jansen_settings::Init()
;
; Create the widget layout and set up the callback
; for adjusting instrument settings.
;
function jansen_settings::Init, wtop, object, title

  COMPILE_OPT IDL2, HIDDEN

  wsettings = widget_base(wtop, /COLUMN, /GRID_LAYOUT, $
                          TITLE = title, $                     ; for WIDGET_TAB
                          UVALUE = self, $                     ; for object-event handler
                          EVENT_PRO = 'jansen_object_event', $ ; event dispatcher
                          RESOURCE_NAME = 'JansenProperty')

  self.wprop = widget_propertysheet(wsettings, value = object, /frame)
  
  return, 1
end

;;;;;
;
; jansen_settings__define
;
pro jansen_settings__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {Jansen_Settings, $
            wprop: 0L $
           }
end
