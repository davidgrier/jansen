;-
; NAME:
;    jansen_widget
;
; PURPOSE:
;    Base class for object widgets.
;
; SUPERCLASS:
;    IDL_Object
;
; PROPERTIES:
;    [R  ] WTOP:      Widget ID of the top-level widget
;    [  S] TITLE:     Title of widget
;    [ GS] OFFSET:    [x,y] offset of widget's top-level base [pixels]
;    [ G ] SIZE:      [nx,ny] size of widget [pixels]
;    [ G ] SCR_SIZE:  [nx,ny] size of widget on screen [pixels]
;    [ G ] DRAW_SIZE: [nx,ny] size of widget's drawing area [pixels]
;    [ G ] MARGIN:    [nx,ny] margin around draw area [pixels]
;    [ G ] PAD:       [nx,ny] padding around widget [pixels]
;    [ G ] SPACE
;
; METHODS:
;    GetProperty/SetProperty
;
;    All subclasses must implement the handleEvent method.
;
; MODIFICATION HISTORY:
; 03/01/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; jansen_widget::cleanup
;
pro jansen_widget::cleanup, widget_id

  COMPILE_OPT IDL2, HIDDEN

end

;;;;;
;
; jansen_widget::create
;
pro jansen_widget::create, wtop

  COMPILE_OPT IDL2, HIDDEN

  if wtop le 0L then $
     self.widget_id = widget_base()
end

;;;;;
;
; jansen_widget::handleEvent
;
pro jansen_widget::handleEvent, event

  COMPILE_OPT IDL2, HIDDEN

end

;;;;;
;
; jansen_widget::SetProperty
;
pro jansen_widget::SetProperty, title = title, $
                                offset = offset

  COMPILE_OPT IDL2, HIDDEN

  if isa(title, 'string') then $
     widget_control, self.widget_id, tlb_set_title = title[0]

  if isa(offset, /number, /array) then $
     widget_control, self.widget_id, $
                     tlb_set_xoffset = offset[0], $
                     tlb_set_yoffset = offset[1]
end

;;;;;
;
; jansen_widget::GetProperty
;
pro jansen_widget::GetProperty, offset = offset, $
                                size = size, $
                                scr_size = scr_size, $
                                draw_size = draw_size, $
                                margin = margin, $
                                pad = pad, $
                                space = space

  COMPILE_OPT IDL2, HIDDEN

  geometry = widget_info(self.widget_id, /geometry)
  offset = [geometry.xoffset, geometry.yoffset]
  size = [geometry.xsize, geometry.ysize]
  scr_size = [geometry.scr_xsize, geometry.scr_ysize]
  draw_size = [geometry.draw_xsize, geometry.draw_ysize]
  margin = geometry.margin
  pad = [geometry.xpad, geometry.ypad]
  space = geometry.space
end

;;;;;
;
; jansen_widget::realize
;
pro jansen_widget::realize

  COMPILE_OPT IDL2, HIDDEN

  widget_control, self.widget_id, /realize
end
  
;;;;;
;
; jansen_widget::start_xmanager
;
pro jansen_widget::start_xmanager

  COMPILE_OPT IDL2, HIDDEN

  xmanager, self.name, self.widget_id, /no_block, $
            event_handler = 'jansen_object_event', $
            cleanup = 'jansen_object_cleanup'
end

;;;;;
;
; jansen_widget::Init()
;
function jansen_widget::Init, wtop

  COMPILE_OPT IDL2, HIDDEN

  if ~isa(wtop, /number, /scalar) then $
     return, 0B
;  self.name = isa(name, 'string') ? name[0] : obj_class(self)
  self.name = obj_class(self)
  if isa(title, 'string') then $
     self.title = title
  self.create, wtop
  widget_control, self.widget_id, set_uvalue = self
  widget_control, self.widget_id, event_pro = 'jansen_object_event'

  return, 1B
end

;;;;;
;
; jansen_widget__define
;
pro jansen_widget__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {jansen_widget, $
            inherits IDL_Object, $
            widget_id: 0L, $
            name: '' $
           }
end
