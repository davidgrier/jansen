pro jansen_object_cleanup, widget_id

  COMPILE_OPT IDL2, HIDDEN

  widget_control, widget_id, get_uvalue = owidget
  owidget.cleanup, widget_id
end
