;;;;;
;
; jansen_filter::GetProperty
;
pro jansen_filter::GetProperty, data = data

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(data) then $
     data = source.data

end

;;;;;
;
; jansen_filter::SetProperty
;
pro jansen_filter::SetProperty, source = source

  COMPILE_OPT IDL2, HIDDEN

  if obj_valid(source) then $
     self.source = source

end

;;;;;
;
; jansen_filter::Init()
;
function jansen_filter::Init, source = source

  COMPILE_OPT IDL2, HIDDEN

  if obj_valid(source) then $
     self.source = source

  return, 1B
end

;;;;;
;
; jansen_filter__define
;
; Base object class for Jansen video filters
;
pro jansen_filter__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {jansen_filter, $
            inherits IDL_Object, $
            source: obj_new() $
           }
end
