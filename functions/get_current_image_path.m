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
    multi_channel_img = get_current_multi_channel_image(app);
    if isempty(multi_channel_img.chans)
      % The data for the current image is not in memory so load whole series. this is needed because we only load one series at a time into memory
      %series_name = multi_channel_img.experiment;
      %series_name = app.ExperimentDropDown.Items{app.ExperimentDropDown.Value};
      %series_id = find(strcmp(app.ExperimentDropDown.Items,series_name));
      %app.ExperimentDropDown.Value = series_id;
      plate_num = app.PlateDropDown.Value;
      parse_input_structure_XYZCT_Bio_Formats(app,plate_num); % load image
      changed_FilterInput(app, plate_num);
      multi_channel_img = get_current_multi_channel_image(app);
    end
    img_data = multi_channel_img.chans(chan_num).data;
    img_path = img_data; % overloading functionality, putting data where the path to the data usually is because the data is already in memory and the path is not neccessary

  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'ZeissSplitTiffs','FlatFiles_SingleChannel','MultiChannelFiles','XYZ-Split-Bio-Formats'})
    img_num = app.ExperimentDropDown.Value;
    multi_channel_img = app.ExperimentDropDown.UserData(img_num);
    img_path = multi_channel_img.chans(chan_num).path;
  end
end