function img_path = fun(app, chan_num)
  plate_num = app.PlateDropDown.Value;

  if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
    % Build path to current file
    img_dir = app.plates(plate_num).metadata.ImageDir;
    plate_file_num = app.plates(plate_num).plate_num; % The plate number in the filename of images
    row = app.RowDropDown.Value;
    column = app.ColumnDropDown.Value;
    field = app.FieldDropDown.Value;
    timepoint = app.TimepointDropDown.Value;
    img_path = sprintf(...
      '%s/r%02dc%02df%02dp%02d-ch%dsk%dfk1fl1.tiff',...
      img_dir,row,column,field,plate_file_num,chan_num,timepoint);

  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Formats'})
    img_data = multi_channel_img.chans(chan_num).data;
    img_path = img_data; % overloading functionality, putting data where the path to the data usually is because the data is already in memory and the path is not neccessary

  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'ZeissSplitTiffs','FlatFiles_SingleChannel'})
    img_num = app.ExperimentDropDown.Value;
    multi_channel_img = app.ExperimentDropDown.UserData(img_num);
    img_path = multi_channel_img.chans(chan_num).path;
  end
end