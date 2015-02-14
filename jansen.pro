;+
; NAME:
;    jansen
;
; PURPOSE:
;    GUI for holographic video microscope, named for Zacharias Jansen
;
; CATEGORY:
;    Hardware control, holographic video microscopy
;
; CALLING SEQUENCE:
;    jansen
;
; KEYWORDS:
;    state: state of the system in the form of a dictionary
;
; COMMON BLOCKS:
;    Widget hierarchy is managed by XMANAGER, which uses common
;    blocks.
;
; SIDE EFFECTS:
;    Opens a GUI on the current display.  Controls attached hardware.
;
; MODIFICATION HISTORY:
; 02/12/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; jansen_event
;
pro jansen_event, event

  COMPILE_OPT IDL2, HIDDEN

  widget_control,  event.top,  get_uvalue = state

  if tag_names(event, /structure_name) eq 'WIDGET_BUTTON' then begin
     widget_control,  event.id, get_uvalue = uval
     case uval of
        'QUIT': begin
           state['video'].record = 0
           state['video'].play = 0
           widget_control, event.top, /destroy
        end
        else:                   ; unrecognized event
     endcase
  endif
  
end

;;;;;
;
; jansen_cleanup
;
pro jansen_cleanup, tlb

  COMPILE_OPT IDL2, HIDDEN

  widget_control, tlb, get_uvalue = state, /no_copy

  foreach key, state.keys() do begin
     if (total(obj_valid(state[key])) ne 0) then begin
        obj_destroy, state[key]
     endif
  endforeach

end

;;;;;
;
; jansen
;
pro jansen, state = state

  COMPILE_OPT IDL2

  if xregistered('jansen') then begin
     message, 'not starting: Another jansen is running already', /inf
     return
  endif

  ;;; Hardware
  state = jansen_configure()
  if state.haskey('error') then begin
     message, state['error'], /inf
     return
  endif
  dimensions = state['camera'].dimensions

  ;;; Widget layout
  wtop = widget_base(/row, title = 'Jansen', mbar = bar, tlb_frame_attr = 5)

  ;; menu bar
  jansen_menu, bar

  ;; data displays
  wdata = widget_tab(wtop)
  ;; 1. video screen
  wscreentab = widget_base(wdata, title = 'Image')               ; for WIDGET_TAB
  wscreen = widget_draw(wscreentab, graphics_level = 2, $        ; object graphics
                        xsize = dimensions[0], $                 ; sized to fit camera
                        ysize = dimensions[1], $
                        keyboard_events = state.haskey('stage')) ; keyboard moves stage

  ;; 2. control panel(s)
  wcontrol = widget_base(wtop, /column)
  wtabs = widget_tab(wcontrol)
  wrecording = jansen_recording(wtabs)

  ;; 3. logo!
;  wlogo = widget_base(wcontrol, /row)
  logo = transpose(read_png(file_dirname(routine_filepath('jansen'))+'/csmrlogosm.png'), [1, 2, 0])

  wlogo = widget_button(wcontrol, value = logo, /bitmap, $
                        uvalue = 'logo', /align_right)

  ;;; Realize widget hierarchy
  widget_control, wtop, /realize
  widget_control, wscreen, get_value = screen

  ;;; Graphics hierarchy
  imagemodel = IDLgrModel()
  imagemodel.add, state.video

  imageview = IDLgrView(viewplane_rect = [0, 0, dimensions])
  imageview.add, imagemodel

  scene = IDLgrScene()
  scene.add, imageview

  ;;; Embed graphics hierarchy in widget layout
  screen.setproperty, graphics_tree = scene

  ;;; Current state of the system
  state['screen'] = screen
  widget_control, wtop, set_uvalue = state

  ;;; Start event loop
  xmanager, 'jansen', wtop, /no_block, cleanup = 'jansen_cleanup'

  ;;; Start video
  state['video'].screen = screen
  state['video'].play = 1

end
