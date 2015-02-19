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
     event.component -> SetPropertyByIdentifier, event.identifier, value
  endif
end

;;;;;
;
; jansen_settings::Create
;
pro jansen_settings::Create, wtop

  COMPILE_OPT IDL2, HIDDEN

  wid = widget_base(wtop, /COLUMN, /GRID_LAYOUT, $
                    TITLE = self.title, $
                    RESOURCE_NAME = 'JansenProperty')
  void = widget_propertysheet(wid, value = object, /frame)
  self.widget_id = wid
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

  self.object = object
  self.title = title
  return, self.Jansen_Widget::Init(wtop)
end

;;;;;
;
; jansen_settings__define
;
pro jansen_settings__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {Jansen_Settings, $
            inherits Jansen_Widget, $
            title: '', $
            object: obj_new() $
           }
end
