function subsetTable = fun(app)
  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;
  PlateName = app.plates(plate_num).metadata.Name;
  subsetTable = table();

  if any(ismember(fields(app),'ResultTable_for_display')) && istable(app.ResultTable_for_display)
    if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
      % Currently selected image is uniquely identified by row, column, field, and timepoint
      row = app.RowDropDown.Value;
      column = app.ColumnDropDown.Value;
      field = app.FieldDropDown.Value;
      timepoint = app.TimepointDropDown.Value;
      selector = ismember(app.ResultTable_for_display.row,row) & ismember(app.ResultTable_for_display.column,column) & ismember(app.ResultTable_for_display.field,field) & ismember(app.ResultTable_for_display.timepoint,timepoint) & ismember(app.ResultTable_for_display.PlateName,PlateName);
    elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')
      % Currently selected image is uniquely identified by the first part of the filename
      img_num = app.ExperimentDropDown.Value;
      filepart1 = app.plates(plate_num).img_files_subset(img_num).filepart1;
      selector = ismember(app.ResultTable_for_display.filepart1,filepart1);
    elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'FlatFiles_SingleChannel','MultiChannelFiles','XYZ-Split-Bio-Formats'})
      img_num = app.ExperimentDropDown.Value;
      ImageName = app.plates(plate_num).img_files_subset(img_num).ImageName;
      selector = ismember(app.ResultTable_for_display.ImageName,ImageName);
    elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Formats'})
      timepoint = app.TimepointDropDown.Value;
      ImageName = app.ExperimentDropDown.Items{app.ExperimentDropDown.Value};
      selector1 = ismember(app.ResultTable_for_display.ImageName,ImageName);
      selector2 = ismember(app.ResultTable_for_display.timepoint,timepoint);
      selector = selector1 & selector2;
    end
  end
  subsetTable = app.ResultTable_for_display(selector,:);
end