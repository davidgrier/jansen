;+
; NAME:
;    jansen_camera_PointGrey
;
; PURPOSE:
;    Object for acquiring and displaying images from a
;    PointGrey camera using the flycapture2 API.
;
; INHERITS:
;    jansen_camera
;
; PROPERTIES:
;    PROPERTIES: array of strings labeling the camera's controllable properties
;
; METHODS:
;    PropertyInfo(property): Returns anonymous structure
;        describing the chanacteristics of the named PROPERTY.
;
;    Property(name [, value]): Returns value of named property.
;        If VALUE is set, then value is written to the camera's
;        specified property.
;
; MODIFICATION HISTORY:
; 09/24/2013 Written by David G. Grier, New York University
; 01/01/2014 DGG Overhauled for new fab implementation.
; 01/27/2014 DGG First implementation of properties.
; 01/28/2014 DGG Clamp values, rather than raising an error
;    when values are out of range
; 03/04/2014 DGG Implement ORDER property
; 02/10/2015 DGG Updated PROPERTIES definition.
; 02/18/2015 DGG Added EXPOSURE_TIME property as synonym for SHUTTER.
;
; Copyright (c) 2013-2015 David G. Grier
;-

;;;;;
;
; jansen_camera_PointGrey::RegisterProperties
;
pro jansen_camera_PointGrey::RegisterProperties

  COMPILE_OPT IDL2, HIDDEN

  properties = ['brightness',    $
                'auto_exposure', $
                'sharpness',     $
                'white_balance', $
                'hue',           $
                'saturation',    $
                'gamma',         $
                'iris',          $
                'focus',         $
                'zoom',          $
                'pan',           $
                'tilt',          $
                'shutter',       $
                'gain',          $
                'trigger_mode',  $
                'trigger_delay', $
                'frame_rate',    $
                'temperature']

  indexes = indgen(n_elements(properties))
  self.properties = orderedhash(properties, indexes)

  info = self.propertyinfo('gain')
  gain = self.property('gain')

  self.name = 'jansen_camera_pointgrey '
  self.description = 'PointGrey Camera '

  foreach property, properties do begin
     info = self.propertyinfo(property)
     if ~info.present || ~info.manualSupported then $
        continue
     self.registerproperty, property, /integer, valid_range = [info.min, info.max, 1]
  endforeach

  self.setpropertyattribute, 'trigger_mode', sensitive = 0
  self.setpropertyattribute, 'trigger_delay', sensitive = 0
  self.setpropertyattribute, 'frame_rate', sensitive = 0
end

;;;;;
;
; jansen_camera_PointGrey::PropertyInfo()
;
; Get information about specified property
;
function jansen_camera_PointGrey::PropertyInfo, property, $
   error = error

  COMPILE_OPT IDL2, HIDDEN

  if (error = ~self.properties.haskey(property)) then $
     return, error

  present = 0L
  autoSupported = 0L
  manualSupported = 0L
  onOffSupported = 0L
  absValSupported = 0L
  readOutSupported = 0L
  min = 0UL
  max = 0UL
  absMin = 0.
  absMax = 0.
  error = call_external(self.dlm, 'property_info', $
                        self.properties[property], $
                        present, autoSupported, manualSupported, $
                        onOffSupported, absValSupported, readOutSupported, $
                        min, max, $
                        absMin, absMax)

  return, {present: present, $
           autoSupported: autoSupported, $
           manualSupported: manualSupported, $
           onOffSupported: onOffSupported, $
           absValSupported: absValSupported, $
           readOutSupported: readOutSupported, $
           min: min, $
           max: max, $
           absMin: absMin, $
           absMax: absMax}
end

;;;;;
;
; jansen_camera_PointGrey::Property(property, [value])
;
; Reads and writes value of specified property
;
function jansen_camera_PointGrey::Property, property, value, $
   detailed = detailed, $
   fvalue = fvalue, $
   on = on, $
   off = off, $
   auto = auto, $
   manual = manual, $
   error = error

  COMPILE_OPT IDL2, HIDDEN

  info = self.propertyinfo(property, error = error)
  if error ne 0 then begin
     message, 'Cannot retrieve property info from camera', /inf
     return, -error
  endif

  if (error = (~info.present || ~info.manualSupported)) then begin
     message, 'Cannot set '+property, /inf
     return, -error
  endif

  present = 0L
  absControl = 0L
  onePush = 0L
  onOff = 0L
  autoManualMode = 0L
  valueA = 0UL
  valueB = 0UL
  absValue = 0.

  if isa(on, /number, /scalar) then $
     onOff = ~keyword_set(on)

  if isa(off, /number, /scalar) then $
     onOff = keyword_set(off)

  if isa(auto, /number, /scalar) then $
     autoManualMode = ~keyword_set(auto)

  if isa(manual, /number, /scalar) then $
     autoManualMode = keyword_set(manual)

  if n_params() eq 2 then begin
     if keyword_set(fvalue) then begin
        absvalue = float(value) > info.absmin < info.absmax
        abscontrol = 1L
     endif else begin
        valueA = ulong(value) > info.min < info.max
     endelse
     if info.onOffSupported then $
        onOff = 1L
     autoManualMode = 0L 
     
     error = call_external(self.dlm, 'write_property', $
                           self.properties[property], $
                           absControl, onePush, onOff, autoManualMode, $
                           valueA, valueB, absValue)
     if error ne 0 then begin
        message, 'Failed to set '+property, /inf
        return, -error
     endif
  endif

  error = call_external(self.dlm, 'read_property', $
                        self.properties[property], $
                        present, absControl, onePush, onOff, autoManualMode, $
                        valueA, valueB, absValue)
  if error ne 0 then $
     return, -error

  return, keyword_set(detailed) ? $
          {present: present, $
           abscontrol: abscontrol, $
           onepush: onepush, $
           onoff: onoff, $
           automanualmode: automanualmode, $
           valuea: valuea, $
           valueb: valueb, $
           absvalue: absvalue} : $
          keyword_set(fvalue) ? absvalue : valueA

end

;;;;;
;
; jansen_camera_PointGrey::ReadRegister()
;
; Reads value from specified register
;
function jansen_camera_PointGrey::ReadRegister, address, $
   error = error

  COMPILE_OPT IDL2, HIDDEN

  if ~isa(address, 'ulong') then $
     return, 0

;address = '1A60'XUL
  value = ulong(0)
  error = call_external(self.dlm, 'read_register', address, value)
  return, value

end

;;;;;
;
; jansen_camera_PointGrey::WriteRegister()
;
; Reads value from specified register
;
pro jansen_camera_PointGrey::WriteRegister, address, value

  COMPILE_OPT IDL2, HIDDEN

  if (error = ~isa(address, 'ulong')) then $
     return


  if (error = ~isa(value, 'ulong')) then $
     return

  error = call_external(self.dlm, 'write_register', address, value)

end

;;;;;
;
; jansen_camera_PointGrey::Read
;
; Transfers a picture to the image
;
pro jansen_camera_PointGrey::Read

  COMPILE_OPT IDL2, HIDDEN

  error = call_external(self.dlm, 'read_pgr', *self.data)
  if self.order then $
     *self.data = reverse(temporary(*self.data), 2)

end

;;;;;
;
; jansen_camera_PointGrey::SetProperty
;
; Set the camera properties
;
pro jansen_camera_PointGrey::SetProperty, brightness    = brightness,    $
                                          auto_exposure = auto_exposure, $
                                          exposure_time = exposure_time, $
                                          sharpness     = sharpness,     $
                                          white_balance = white_balance, $
                                          hue           = hue,           $
                                          saturation    = saturation,    $
                                          gamma         = gamma,         $
                                          iris          = iris,          $
                                          focus         = focus,         $
                                          zoom          = zoom,          $
                                          pan           = pan,           $
                                          tilt          = tilt,          $
                                          shutter       = shutter,       $
                                          gain          = gain,          $
                                          trigger_mode  = trigger_mode,  $
                                          trigger_delay = trigger_delay, $
                                          frame_rate    = frame_rate,    $
                                          temperature   = temperature,   $
                                          hflip         = hflip,         $
                                          _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.jansen_camera::SetProperty, _extra = re

  if isa(brightness, /number, /scalar) then $
     void = self.property('brightness', brightness)

  if isa(auto_exposure, /number, /scalar) then $
     void = self.property('auto_exposure', auto_exposure)

  if isa(sharpness, /number, /scalar) then $
     void = self.property('sharpness', sharpness)

  if isa(white_balance, /number, /scalar) then $
     void = self.property('white_balance', white_balance)

  if isa(hue, /number, /scalar) then $
     void = self.property('hue', hue)

  if isa(saturation, /number, /scalar) then $
     void = self.property('saturation', saturation)

  if isa(gamma, /number, /scalar) then $
     void = self.property('gamma', gamma)

  if isa(iris, /number, /scalar) then $
     void = self.property('iris', iris)

  if isa(focus, /number, /scalar) then $
     void = self.property('focus', focus)

  if isa(zoom, /number, /scalar) then $
     void = self.property('zoom', zoom)

  if isa(pan, /number, /scalar) then $
     void = self.property('pan', pan)

  if isa(tilt, /number, /scalar) then $
     void = self.property('tilt', tilt)

  if isa(shutter, /number, /scalar) || isa(exposure_time, /number, /scalar) then $
     void = self.property('shutter', shutter)

  if isa(gain, /number, /scalar) then $
     void = self.property('gain', gain)

  if isa(trigger_mode, /number, /scalar) then $
     void = self.property('trigger_mode', trigger_mode)

  if isa(trigger_delay, /number, /scalar) then $
     void = self.property('trigger_delay', trigger_delay)

  if isa(frame_rate, /number, /scalar) then $
     void = self.property('frame_rate', frame_rate)

  if isa(temperature, /number, /scalar) then $
     void = self.property('temperature', temperature)

  if isa(gain, /number, /scalar) then $
     void = self.property('gain', gain)

  if isa(hflip, /number, /scalar) then begin
     val = '80000000'XUL + (hflip ne 0)
     self.writeregister, '1054'XUL, val
  endif

end

;;;;;
;
; jansen_camera_PointGrey::GetProperty
;
pro jansen_camera_PointGrey::GetProperty, properties    = properties,    $
                                          brightness    = brightness,    $
                                          auto_exposure = auto_exposure, $
                                          sharpness     = sharpness,     $
                                          white_balance = white_balance, $
                                          hue           = hue,           $
                                          saturation    = saturation,    $
                                          gamma         = gamma,         $
                                          iris          = iris,          $
                                          focus         = focus,         $
                                          zoom          = zoom,          $
                                          pan           = pan,           $
                                          tilt          = tilt,          $
                                          exposure_time = exposure_time, $
                                          shutter       = shutter,       $
                                          gain          = gain,          $
                                          trigger_mode  = trigger_mode,  $
                                          trigger_delay = trigger_delay, $
                                          frame_rate    = frame_rate,    $
                                          temperature   = temperature,   $
                                          hflip         = hflip,         $
                                          _ref_extra    = re

  COMPILE_OPT IDL2, HIDDEN

  self.jansen_camera::GetProperty, _extra = re

  if arg_present(properties) then $
     properties = self.properties.keys()

  if arg_present(brightness) then $
     brightness = self.property('brightness')

  if arg_present(auto_exposure) then $
     auto_exposure = self.property('auto_exposure')

  if arg_present(sharpness) then $
     sharpness = self.property('sharpness')

  if arg_present(white_balance) then $
     white_balance = self.property('white_balance')

  if arg_present(hue) then $
     hue = self.property('hue')

  if arg_present(saturation) then $
     saturation = self.property('saturation')

  if arg_present(gamma) then $
     gamma = self.property('gamma')

  if arg_present(iris) then $
     iris = self.property('iris')

  if arg_present(focus) then $
     focus = self.property('focus')

  if arg_present(zoom) then $
     zoom = self.property('zoom')

  if arg_present(pan) then $
     pan = self.property('pan')

  if arg_present(tilt) then $
     tilt = self.property('tilt')

  if arg_present(exposure_time) then $
     exposure_time = self.property('shutter')

  if arg_present(shutter) then $
     shutter = self.property('shutter')

  if arg_present(gain) then $
     gain = self.property('gain')

  if arg_present(trigger_mode) then $
     trigger_mode = self.property('trigger_mode')

  if arg_present(trigger_delay) then $
     trigger_delay = self.property('trigger_delay')

  if arg_present(frame_rate) then $
     frame_rate = self.property('frame_rate')

  if arg_present(temperature) then $
     temperature = self.property('temperature')

  if arg_present(hflip) then $
     hflip = (self.readregister('1054'XUL) and 1)

end

;;;;;
;
; jansen_camera_PointGrey::Cleanup
;
; Close video stream
;
pro jansen_camera_PointGrey::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  if (error = call_external(self.dlm, 'close_pgr')) then $
     message, 'error closing camera', /inf, noprint = ~self.debug

  self.jansen_camera::Cleanup

end

;;;;;
;
; jansen_camera_PointGrey::Init
;
; Initialize the jansen_camera_PointGrey object:
; Open the video stream
; Load an image into the IDLgrImage object
;
function jansen_camera_PointGrey::Init, hflip = hflip, $
                                        _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  ;; look for shared object library in IDL search path
  dlm = 'idlpgr.so'
  if ~(self.dlm = jansen_search(dlm, /test_executable)) then begin
     message, 'Could not find '+dlm, /inf
     return, 0B
  endif

  if ~self.jansen_camera::Init(_extra = re) then $
     return, 0B

  nx = 0
  ny = 0
  error = call_external(self.dlm, 'open_pgr', nx, ny)
  if error then $
     return, 0B

  a = bytarr(nx, ny)
  self.data = ptr_new(a)

  self.registerproperties

  if isa(hflip, /number, /scalar) then $
     self.writeregister, '1054'XUL, '80000000'XUL + (hflip ne 0)

  return, 1B
end

;;;;;
;
; jansen_camera_PointGrey__define
;
; Define the jansen_camera_PointGrey object
;
pro jansen_camera_PointGrey__define

COMPILE_OPT IDL2, HIDDEN

struct = {jansen_camera_PointGrey,  $
          inherits jansen_camera,   $
          dlm: '',              $ 
          properties: obj_new() $
         }
end