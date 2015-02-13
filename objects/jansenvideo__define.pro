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
;    recording  [ GS]: 0: paused, not recording
;                      1: record video from camera
;                      2: record video from screen
;                      3: record video from window
;    directory  [IGS]: string: directory for recording video files.
;
; METHODS
;    GetProperty
;    SetProperty
;
;    SaveImage: Save one snapshot
;    SelectDirectory: Choose directory for recording images
;
; MODIFICATION HISTORY:
; 02/12/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; jansenVideo::handleTimerEvent
;
pro jansenVideo::handleTimerEvent, id, userdata

  COMPILE_OPT IDL2, HIDDEN

  self.timer = timer.set(self.time, self)
  data = self.camera.read()

  if (self.hvmmode ne 0) then $
     self.IDLgrImage::setproperty, $
     data = byte(128.*float(data)/self.median.get() < 255) $
  else $
     self.IDLgrImage::setproperty, data = data
  self.screen.draw

  if (self.hvmmode eq 1) || $
     ((self.hvmmode eq 2) && ~(self.median.initialized)) then $
        self.median.add, data

  case self.recording of
     1: self.recorder.write, data
     2: begin
        self.IDLgrImage::getproperty, data = data
        self.recorder.write, data
     end
     3: begin
        self.screen.getproperty, image_data = data
        self.recorder.write, data
     end
     else: if obj_valid(self.recorder) then $
        obj_destroy, self.recorder
  endcase
  
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
; jansenVideo::StartRecording
;
pro jansenVideo::StartRecording

  COMPILE_OPT IDL2, HIDDEN

  if strlen(self.filename) gt 0 then $
     self.recorder = h5video(self.filename, /overwrite)

  if ~isa(self.recorder, 'h5video') then begin
     message, 'not recording', /inf
     self.recording = 0
  endif

  ;;; update properties?
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
                              recording = recording, $
                              directory = directory, $
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

  if isa(recording, /scalar, /number) then begin
     self.recording = recording
     if (self.recording gt 0) then $
        self.startrecording
  endif

  if isa(directory, 'string') then begin
     if ~file_search(directory, /TEST_DIRECTORY, /EXPAND_TILDE) then $
        file_mkdir, directory
     dir = file_search(directory, /TEST_DIRECTORY, /EXPAND_TILDE, /TEST_WRITE)
     if dir.length gt 0 then $
        self.directory = dir $
     else $
        message, 'Could not change directory to '+directory, /inf
  endif
  
end

;;;;;
;
; jansenVideo::GetProperty
;
pro jansenVideo::GetProperty, greyscale = greyscale, $
                              camera = camera, $
                              median = median, $
                              recorder = recorder, $
                              screen = screen, $
                              framerate = framerate, $
                              playing = playing, $
                              hvmmode = hvmmode, $
                              hvmorder = hvmorder, $
                              background = background, $
                              recording = recording, $
                              directory = directory, $
                              filename = filename, $
                              width = width, $
                              height = height, $
                              _ref_extra = re
  
  COMPILE_OPT IDL2, HIDDEN

  self.camera.getproperty, _extra = re
  if isa(self.recorder, 'h5video') then $
     self.recorder.getproperty, _extra = re
  self.IDLgrImage::GetProperty, _extra = re

  if arg_present(greyscale) then $
     greyscale = self.camera.greyscale

  if arg_present(camera) then $
     camera = self.camera

  if arg_present(median) then $
     median = self.median

  if arg_present(recorder) then $
     recorder = self.recorder

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

  if arg_present(recording) then $
     recording = self.recording

  if arg_present(directory) then $
     directory = self.directory

  if arg_present(filename) then $
     filename = self.filename

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
  obj_destroy, self.recorder
end

;;;;;
;
; jansenVideo::Init()
;
function jansenVideo::Init, camera = camera, $
                            screen = screen, $
                            framerate = framerate, $
                            hvmorder = hvmorder, $
                            directory = directory, $
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

  dir = isa(directory, 'string') ? directory : '~/data'
  if ~file_search(dir, /TEST_DIRECTORY, /EXPAND_TILDE) then $
     file_mkdir, dir
  dir = file_search(dir, /TEST_DIRECTORY, /EXPAND_TILDE, /TEST_WRITE)
  if dir.length gt 0 then $
     self.directory = dir $
  else begin
     message, 'Could not set data directory to ' + self.directory
     self.directory = ''
  endelse

  self.filename = 'jansen.h5'

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
            recorder: obj_new(), $
            directory: '', $
            filename: '', $
            playing: boolean(0), $
            hvmmode: 0L, $
            hvmorder: 0L, $
            median: obj_new(), $
            bgcounter: 0L, $
            time: 0.D, $
            timer: 0L $
           }
end
