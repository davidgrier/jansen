;+
; NAME:
;    jansen_video
;
; PURPOSE:
;    Video source for jansen system.  This object periodically
;    requests an image from an attached camera and displays that image
;    on an attached screen.
;
;    Optionally runs the image through a filter before displaying.
;
;    Maintains a list of callback functions that are called every
;    time an image is acquired.
;
; INHERITS:
;    IDLgrImage
;    IDL_Object
;
; PROPERTIES:
;    camera     [RG ]: jansen_camera object that provides images
;    width      [ G ]: width of camera image
;    height     [ G ]: height of camera image
;    screen     [RG ]: IDLgrWindow on which the image is drawn
;    framerate  [IGS]: number of frames per second
;    playing    [ GS]: If set, update video screen at framerate
;    hvmmode    [ GS]: If set, video is normalized by background image
;    background [ G ]: Background image for hvmmode
;
; CALLBACKS:
;    
; METHODS:
;    GetProperty
;    SetProperty
;
;    RegisterCallback, name, object
;        Register a callback method that will be called each time
;        an image is acquired.
;        INPUTS:
;            NAME: A string containing the name by which the callback
;                will be referred.
;            OBJECT: Object reference to the object that will handle
;                the callback.  The object must implement the
;                OBJECT::CALLBACK, obj
;                method, taking the jansen_video object as its
;                argument.
;
;    UnregisterCallback, name
;        Remove the named callback from the list of callbacks.
;
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
; jansen_video::registerCallback
;
pro jansen_video::registerCallback, name, object

  COMPILE_OPT IDL2, HIDDEN

  if obj_valid(object) && isa(name, 'string') then $
     self.callbacks[name] = object
end

;;;;;
;
; jansen_video::unregisterCallback
;
pro jansen_video::unregisterCallback, name

  COMPILE_OPT IDL2, HIDDEN

  if self.callbacks.haskey(name) then $
     self.callbacks.remove, name
end

;;;;;
;
; jansen_video::handleCallbacks
;
pro jansen_video::handleCallbacks

  COMPILE_OPT IDL2, HIDDEN

  foreach object, self.callbacks do $
     call_method, 'callback', object, self

end

;;;;;
;
; jansen_video::handleTimerEvent
;
pro jansen_video::handleTimerEvent, id, userdata

  COMPILE_OPT IDL2, HIDDEN

  self.timer = timer.set(self.time, self)
  data = self.camera.read()

  ;;; use filters to transform data
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
; jansen_video::SetProperty
;
pro jansen_video::SetProperty, camera = camera, $
                               playing =  playing, $
                               hvmmode = hvmmode, $
                               hvmorder = hvmorder, $
                               screen = screen, $
                               framerate = framerate, $
                               _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if obj_valid(camera) then $
     self.camera = camera
  
  self.camera.setproperty, _extra = re
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
; jansen_video::GetProperty
;
pro jansen_video::GetProperty, data = data, $
                               screendata = screendata, $
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

  if arg_present(data) then $
     data = self.camera.data

  if arg_present(screendata) then $
     self.IDLgrImage::GetProperty, data = screendata
  
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
; jansen_video::Cleanup
;
pro jansen_video::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  obj_destroy, self.camera
end

;;;;;
;
; jansen_video::Init()
;
function jansen_video::Init, camera = camera, $
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
  self.registerproperty, 'hvmmode', enum = ['Off', 'Running', 'Sample-Hold']
  self.registerproperty, 'hvmorder', /integer, valid_range = [0, 10, 1]
  self.registerproperty, 'width', /integer, sensitive = 0
  self.registerproperty, 'height', /integer, sensitive = 0

  return, 1B
end

;;;;;
;
; jansen_video__define
;
pro jansen_video__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {jansen_video, $
            inherits IDLgrImage, $
            inherits IDL_Object, $
            camera: obj_new(), $
            screen: obj_new(), $
            playing: 0L, $
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
