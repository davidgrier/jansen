;+
; NAME:
;    Jansen_Filter_Median
;
; PURPOSE:
;    Median filter for the Jansen video system
;
; SUPERCLASSES:
;    Jansen_Filter
;
; PROPERTIES:
;    [I S] SOURCE: Object reference to source of images
;    [ G ] DATA: Median filtered image from source.
;    [IGS] ORDER: Order of the filter
;        Default: 3
;    [IGS] RUNNING: Flag: If set, performing running median
;
; METHODS:
;    GetProperty
;    SetProperty
;
; NOTES:
;    Should handle color images: median on each channel
;
; MODIFICATION HISTORY:
; 03/15/2015 Written by David G. Grier, New York University
;
; Copyright (c) David G. Grier
;-
;;;;;
;
; jansen_filter_median::GetProperty
;
pro jansen_filter_median::GetProperty, data = data, $
                                       order = order, $
                                       running = running

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(data) then begin
     data = self.source.data
     if self.running || ~self.median.initialized then $
        self.median.add, data
     data = byte(128.*float(data)/self.median.get())
  endif

  if arg_present(order) then $
     order = self.order

  if arg_present(running) then $
     running = self.running
end

;;;;;
;
; jansen_filter_median::SetProperty
;
pro jansen_filter_median::SetProperty, source = source, $
                                       order = order, $
                                       running = running
  COMPILE_OPT IDL2, HIDDEN

  if obj_valid(source) then begin
     self.source = source
     obj_destroy, self.median
     self.median = numedian(order = self.order, data = self.source.data)
  endif

  if isa(order, /number, /scalar) then begin
     self.order = long(order) > 3
     self.median.order = self.order
  endif

  if isa(running, /number, /scalar) then $
     self.running = keyword_set(running)
  
end

;;;;;
;
; jansen_filter_median::Init()
;
function jansen_filter_median::Init, source = source, $
                                     order = order, $
                                     running = running

  COMPILE_OPT IDL2, HIDDEN

  if ~self.jansen_filter::Init(source = source) then $
     return, 0B
  
  self.order = isa(order, /number, /scalar) ? long(order) > 3L : 3L

  if isa(self.source) then $
     self.median = numedian(order = self.order, data = self.source.data)

  self.running = keyword_set(running)

  return, 1B
end

;;;;;
;
; jansen_filter_median__define
;
; Running median filter image normalization for Jansen
;
pro jansen_filter_median__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {jansen_filter_median, $
            inherits jansen_filter, $
            median: obj_new(), $
            order: 0L, $
            running: 0L $
           }
end
