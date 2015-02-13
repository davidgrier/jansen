;+
; NAME:
;    jansen_align_column
;
; PURPOSE:
;    Align the widgets in a column of widgets
;
; MODIFICATION HISTORY:
; Copied from The IDL Data Point
; https://idldatapoint.wordpress.com/2012/02/23/aligning-widgets/
;
; 02/13/2015 Adapted for Jansen by David G. Grier, New York University
;-
pro jansen_align_column, ColumnBase
  
  COMPILE_OPT IDL2, HIDDEN

  ;; The outer loop iterates over the rows in the column base.
  columnmaxwidth = 0
  child = widget_info(ColumnBase, /CHILD)
  while (widget_info(child, /VALID_ID)) do begin
     ;; Assume one widget per row
     ;; What is the screen width in pixels of this widget?
     columnmaxwidth >= (widget_info(child, /GEOMETRY)).scr_xsize
     child = widget_info(child, /SIBLING)
  endwhile

  ;; Pass 2: Set the screen width of each widget equal
  ;; to the maximum width found per column
  child = widget_info(ColumnBase, /CHILD)
  while (widget_info(child, /VALID_ID)) do begin
     widget_control, child, SCR_XSIZE = columnmaxwidth
     child = widget_info(child, /SIBLING)
  endwhile
end
