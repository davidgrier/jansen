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

  case tag_names(event, /structure_name) of
     'WIDGET_BUTTON': begin
        widget_control,  event.id, get_uvalue = uval
        case uval of
           'QUIT': widget_control, event.top, /destroy
           else: help, event    ; unrecognized button
        endcase
     end

     'WIDGET_TAB':              ; nothing to do

     else: help, event          ; unrecognized event
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
  wtop = widget_base(/row, title = 'Jansen', mbar = bar, tlb_frame_attr = 5, $
                     bitmap = jansen_search('jansen_logo.ico'))

  ;; menu bar
  jansen_menu, bar

  ;; Data displays
  wdatatabs = widget_tab(wtop)
  ;; 1.(a) video screen
  wscreentab = widget_base(wdatatabs, title = 'Image')               ; for WIDGET_TAB
  wscreen = widget_draw(wscreentab, frame = 1, $
                        graphics_level = 2, $                    ; object graphics
                        xsize = dimensions[0], $                 ; sized to fit camera
                        ysize = dimensions[1], $
                        keyboard_events = state.haskey('stage')) ; keyboard moves stage

  ;; 1.(b) live results?
  wdatatab = widget_base(wdatatabs, title = 'Data')
  wplot = widget_draw(wdatatab, frame = 1, $
                      graphics_level = 2, $
                      xsize = dimensions[0], $
                      ysize = dimensions[1])
  
  ;; 2. control panel(s)
  wcontrol = widget_base(wtop, /column)
  wtabs = widget_tab(wcontrol)
  wrecording = jansen_recording(wtabs, state['recording'], 'Recording')
  wcamera = jansen_settings(wtabs, state['camera'], 'Camera')
  ;; FIXME: place multiple objects on one tab:
  ;;     Perhaps argument can be an array of objects
  ;; FIXME: add functionality
  ;;  wlaser = jansen_settings(wtabs, state['imagelaser'], 'Laser')
  ;;  wstage = jansen_settings(wtabs, state['stage'], 'Stage')
  
  ;; 3. Global information
  ;;    wavelength, mpp, temperature
  winfo = jansen_info(wcontrol, state)

  ;; 4. logo!
  area = [winfo.scr_size[0], 50]
  wlogo = jansen_logo(wcontrol, 'csmrlogo.png', area)

  ;;; Realize widget hierarchy
  widget_control, wtop, /realize
  widget_control, wscreen, get_value = screen
  widget_control, wplot, get_value = plot

  ;;; Graphics hierarchy
  imagemodel = IDLgrModel()
  imagemodel.add, state['video']

  imageview = IDLgrView(viewplane_rect = [0, 0, dimensions])
  imageview.add, imagemodel

  scene = IDLgrScene()
  scene.add, imageview

  ;;; Embed graphics hierarchy in widget layout
  screen.setproperty, graphics_tree = scene

  ;;; Current state of the system
  state['screen'] = screen
  state['plot'] = plot
  widget_control, wtop, set_uvalue = state

  ;;; Start event loop
  xmanager, 'jansen', wtop, /no_block, cleanup = 'jansen_cleanup'

  ;;; Start video
  state['video'].screen = screen
  state['video'].play = 1

end
