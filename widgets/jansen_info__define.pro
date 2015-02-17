;;;;;
;
; jansen_info::Init()
;
; Create the widget layout and set up the timer
; for occasional updating of properties
;
function jansen_info::Init, wtop, state

  COMPILE_OPT IDL2, HIDDEN

  style = {NOEDIT: 1, FRAME: 1, COLUMN: 1,  XSIZE: 12, YSIZE: 1}
  
  winfo = widget_base(wtop, /ROW, RESOURCE_NAME = 'Jansen')

  void = cw_field(winfo, title = 'lambda [um]   ', _EXTRA = style, $
                  VALUE = string(state.imagelaser.wavelength, format = '(F5.3)'))
  void = cw_field(winfo, title = 'mpp [um/pixel]', _EXTRA = style, $
                  VALUE = string(state.camera.mpp, format = '(F5.3)'))
  return, 1B
end

;;;;;
;
; jansen_info__define
;
pro jansen_info__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {Jansen_Info, $
            temperature: 0. $
           }
end
