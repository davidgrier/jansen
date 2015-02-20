;;;;;
;
; jansen_logo::Create
;
pro jansen_logo::Create, wtop

  COMPILE_OPT IDL2, HIDDEN

  logo = transpose(read_png(jansen_search(self.logo_file)), [1, 2, 0])
  sz = float(size(logo, /dimensions))
  scale = min(self.area/sz)
  logo = congrid(logo, scale*sz[0], scale*sz[1], 3)
  self.widget_id = widget_button(wtop, value = logo, /bitmap, uvalue = 'logo', /align_center)
end

;;;;;
;
; jansen_logo::Init()
;
function jansen_logo::Init, wtop, logo_file, area

  COMPILE_OPT IDL2, HIDDEN

  self.logo_file = logo_file
  self.area = area
  
  if ~self.Jansen_Widget::Init(wtop) then $
     return, 0B
  
  return, 1B
end

;;;;;
;
; jansen_logo__define
;
pro jansen_logo__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {Jansen_Logo, $
            inherits Jansen_Widget, $
            logo_file: '', $
            area: [0., 0.] $
           }
end
