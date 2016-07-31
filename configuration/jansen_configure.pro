;+
; NAME:
;    jansen_configure()
;
; PURPOSE:
;    Parse configuration files to assemble jansen system
;
; PROCEDURE:
;    Parses the default.xml configuration file, and then looks
;    for system-specific XML configuration files in ~/.jansen/
;
; OUTPUT:
;    Hash describing system components that were successfully
;    configured, together with error messages, if any.
;
; MODIFICATION HISTORY:
; 02/12/2015 Written by David G. Grier, New York University
; 07/29/2015 DGG Update for DVR functionality
;
; Copyright (c) 2015-2016 David G. Grier
;-
function jansen_configure

  COMPILE_OPT IDL2, HIDDEN

  ;;; Parse configuration files
  if ~(parser = fab_configurationparser()) then $
     return, dictionary('error', 'could not initialize configuration parser')

  default_configuration = 'jansen_default.xml'
  if ~(fn = jansen_search(default_configuration)) then $
     return, dictionary('error', $
                        'could not open default configuration file: ' + $
                        default_configuration)
  parser.parsefile, fn

  local_configuration = '~/.jansen/*.xml'
  filenames = file_search(local_configuration, /test_read, count = count)
  if (count gt 0) then $
     foreach filename, filenames do $
        parser.parsefile, filename

  configuration = parser.configuration
  obj_destroy, parser

  ;;; Apply configuration information to jansen subsystems
  components = list('error')
  components.add, jansen_configure_camera(configuration)
  components.add, jansen_configure_video(configuration)
  components.add, jansen_configure_dvr(configuration)
  components.add, nuconf_imagelaser(configuration)
  components.add, nuconf_stage(configuration)

  ;;; Incorporate configuration information into jansen state
  state = dictionary()
  foreach component, components do $
     if configuration.haskey(component) then $
        state[component] = configuration[component]

  return, state
end
