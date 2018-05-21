function func(app)
  primary_seg_num = app.PrimarySegmentDropDown.Value;

  if isempty(primary_seg_num) || primary_seg_num == 0 % if primary segment is None/0, skip
    app.RemoveSecondarySegments_CheckBox.Enable = false;
    app.RemovePrimarySegments_CheckBox.Enable = false;
    app.RemovePrimarySegmentsOutside.Enable = false;
  else
    app.RemoveSecondarySegments_CheckBox.Enable = true;
    app.RemovePrimarySegments_CheckBox.Enable = true;
    app.RemovePrimarySegmentsOutside.Enable = true;
  end

end