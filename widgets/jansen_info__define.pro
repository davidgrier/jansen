;;;;;
;
; jansen_info::GetProperty
;
;;;;;
;
; jansen_info::SetProperty
;

;;;;;
;
; jansen_info::Create
;
pro jansen_info::Create, wtop

  COMPILE_OPT IDL2, HIDDEN

  style = {NOEDIT: 1, FRAME: 1, COLUMN: 1,  XSIZE: 12, YSIZE: 1}
  
  winfo = widget_base(wtop, /ROW, RESOURCE_NAME = 'Jansen')

  void = cw_field(winfo, title = 'lambda [um]   ', _EXTRA = style, $
                  VALUE = string(self.wavelength, format = '(F5.3)'))
  void = cw_field(winfo, title = 'mpp [um/pixel]', _EXTRA = style, $
                  VALUE = string(self.mpp, format = '(F5.3)'))

  self.widget_id = winfo
end

;;;;;
;
; jansen_info::Init()
;
; Create the widget layout and set up the timer
; for occasional updating of properties
;
function jansen_info::Init, wtop, state

  COMPILE_OPT IDL2, HIDDEN

  self.wavelength = state.imagelaser.wavelength
  self.mpp = state.camera.mpp
  
  if ~self.Jansen_Widget::Init(wtop) then $
     return, 0B

  return, 1B
end

;;;;;
;
; jansen_info__define
;
pro jansen_info__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {Jansen_Info, $
            inherits Jansen_Widget, $
            wavelength: 0., $
            mpp: 0., $
            temperature: 0. $
           }
end
