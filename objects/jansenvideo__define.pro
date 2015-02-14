;+
; NAME:
;    jansenvideo
;
; PURPOSE:
;    Video screen for jansen system
;
; INHERITS:
;    IDLgrImage
;    IDL_Object
;
; PROPERTIES
;    camera     [RG ]: fabcamera object that provides images
;    width      [ G ]: width of camera image
;    height     [ G ]: height of camera image
;    screen     [RG ]: IDLgrWindow on which the image is drawn
;    framerate  [IGS]: number of frames per second
;    playing    [ GS]: If set, video screen updates at framerate
;    hvmmode    [ GS]: If set, video is normalized by background image
;    background [ G ]: Background image for hvmmode
;
; METHODS
;    GetProperty
;    SetProperty
;
; MODIFICATION HISTORY:
; 02/12/2015 Written by David G. Grier, New York University
; 02/14/2015 remove all recording elements.  Recording will be
;    handled by callbacks.
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; jansenVideo::registerCallback
;
pro jansenVideo::registerCallback, name, object

  COMPILE_OPT IDL2, HIDDEN

  if obj_valid(object) && isa(name, 'string') then $
     self.callbacks[name] = object
end

;;;;;
;
; jansenVideo::unregisterCallback
;
pro jansenVideo::unregisterCallback, name

  COMPILE_OPT IDL2, HIDDEN

  if self.callbacks.haskey(name) then $
     self.callbacks.remove, name
end

;;;;;
;
; jansenVideo::handleCallbacks
;
pro jansenVideo::handleCallbacks

  COMPILE_OPT IDL2, HIDDEN

  foreach object, self.callbacks do $
     call_method, 'callback', object, self

end

;;;;;
;
; jansenVideo::handleTimerEvent
;
pro jansenVideo::handleTimerEvent, id, userdata

  COMPILE_OPT IDL2, HIDDEN

  self.timer = timer.set(self.time, self)
  data = self.camera.read()

  self.IDLgrImage::SetProperty, data = (self.hvmmode eq 0) ? $
                                       data : $
                                       byte(128.*float(data)/self.median.get() < 255)
  self.screen.draw

  if (self.hvmmode eq 1) || $
     ((self.hvmmode eq 2) && ~(self.median.initialized)) then $
        self.median.add, data

  self.handleCallbacks
end

;;;;;
;
; jansenVideo::SaveImage
;
pro jansenVideo::SaveImage, filename

  COMPILE_OPT IDL2, HIDDEN

  if ~isa(filename, 'string') then $
     filename = dialog_pickfile(title = 'Jansen Save Snapshot', $
                                filter = '*.png', /fix_filter, $
                                directory = self.directory, $
                                file = 'jansen_snapshot', $
                                default_extension = 'png', $
                                /write, /overwrite_prompt, $
                                resource_name = 'Jansen')
  if strlen(filename) gt 0 then begin
     self.IDLgrImage::GetProperty, data = snapshot
     write_png, filename, snapshot
  endif
end

;;;;;
;
; jansenVideo::SetProperty
;
pro jansenVideo::SetProperty, greyscale = greyscale, $
                              playing =  playing, $
                              hvmmode = hvmmode, $
                              hvmorder = hvmorder, $
                              screen = screen, $
                              framerate = framerate, $
                              _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.camera.setproperty, greyscale = greyscale, _extra = re
  self.IDLgrImage::SetProperty, _extra = re

  if isa(screen, 'IDLgrWindow') then $
     self.screen = screen

  if isa(playing) then begin
     self.playing = keyword_set(playing)
     ok = timer.cancel(self.timer)
     if self.playing && isa(self.screen) then $
        self.timer = timer.set(self.time, self)
  endif

  if isa(hvmmode, /number, /scalar) then $
     self.hvmmode = (long(hvmmode) > 0) < 2

  if isa(hvmorder, /number, /scalar) then $
     self.median.order = hvmorder
      
  if isa(framerate, /scalar, /number) then $
     self.time = 1./double(abs(framerate))

end

;;;;;
;
; jansenVideo::GetProperty
;
pro jansenVideo::GetProperty, greyscale = greyscale, $
                              camera = camera, $
                              median = median, $
                              screen = screen, $
                              framerate = framerate, $
                              playing = playing, $
                              hvmmode = hvmmode, $
                              hvmorder = hvmorder, $
                              background = background, $
                              width = width, $
                              height = height, $
                              _ref_extra = re
  
  COMPILE_OPT IDL2, HIDDEN

  self.camera.getproperty, _extra = re
  self.IDLgrImage::GetProperty, _extra = re

  if arg_present(greyscale) then $
     greyscale = self.camera.greyscale

  if arg_present(camera) then $
     camera = self.camera

  if arg_present(median) then $
     median = self.median

  if arg_present(screen) then $
     screen = self.screen

  if arg_present(framerate) then $
     framerate = 1./self.time

  if arg_present(playing) then $
     playing = self.playing

  if arg_present(hvmmode) then $
     hvmmode = self.hvmmode

  if arg_present(hvmorder) then $
     hvmorder = self.median.order

  if arg_present(background) then $
     background = self.median.get()

  if arg_present(width) then $
     width = (self.camera.dimensions)[0]

  if arg_present(height) then $
     height = (self.camera.dimensions)[1]
end

;;;;;
;
; jansenVideo::Cleanup
;
pro jansenVideo::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  obj_destroy, self.camera
end

;;;;;
;
; jansenVideo::Init()
;
function jansenVideo::Init, camera = camera, $
                            screen = screen, $
                            framerate = framerate, $
                            hvmorder = hvmorder, $
                            _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if isa(camera, 'fabcamera') then $
     self.camera = camera $
  else $
     return, 0B

  imagedata = self.camera.read()

  if isa(screen, 'IDLgrWindow') then $
     self.screen = screen

  if ~self.IDLgrImage::Init(imagedata, _extra = re) then $
     return, 0B

  order = isa(hvmorder, /number, /scalar) ? (hvmorder > 0) < 10 : 3
  self.median = numedian(order = order, data = imagedata)

  self.time = (isa(framerate, /scalar, /number)) ? $
              1./double(abs(framerate)) : 1./29.97D

  self.callbacks = hash()

  self.name = 'jansenvideo '
  self.description = 'Video Image '
  self.registerproperty, 'name', /string, /hide
  self.registerproperty, 'description', /string
  self.registerproperty, 'playing', /boolean
  self.registerproperty, 'framerate', /float
  self.registerproperty, 'order', enum = ['Normal', 'Flipped']
  self.registerproperty, 'hvmmode', enum = ['Off', 'Running', 'Sample-Hold']
  self.registerproperty, 'hvmorder', /integer, valid_range = [0, 10, 1]
  self.registerproperty, 'recording', $
     enum = ['Paused', 'From Camera', 'From Screen', 'From Window']
  self.registerproperty, 'directory', /string
  self.registerproperty, 'filename', /string
  self.registerproperty, 'greyscale', /boolean, sensitive = 0
  self.registerproperty, 'width', /integer, sensitive = 0
  self.registerproperty, 'height', /integer, sensitive = 0

  return, 1B
end

;;;;;
;
; jansenVideo__define
;
pro jansenVideo__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {jansenVideo, $
            inherits IDLgrImage, $
            inherits IDL_Object, $
            camera: obj_new(), $
            screen: obj_new(), $
            recording: 0L, $
            playing: boolean(0), $
            hvmmode: 0L, $
            hvmorder: 0L, $
            median: obj_new(), $
            bgcounter: 0L, $
            time: 0.D, $
            timer: 0L, $
            callback: obj_new(), $
            callbacks: obj_new() $
           }
end
