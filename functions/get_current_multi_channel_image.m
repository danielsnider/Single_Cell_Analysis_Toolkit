function multi_channel_img = fun(app)
  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
    %% Build path to current image from dropdown selections
    image_dir = app.plates(plate_num).metadata.ImageDir;
    plate_file_num = app.plates(plate_num).plate_num; % The plate number in the filename of images
    row = app.RowDropDown.Value;
    column = app.ColumnDropDown.Value;
    field = app.FieldDropDown.Value;
    timepoint = app.TimepointDropDown.Value;

    multi_channel_img = {};
    multi_channel_img.channel_nums = app.plates(plate_num).channels;
    multi_channel_img.plate_num = plate_num;
    multi_channel_img.chans = [];
    multi_channel_img.row = row;
    multi_channel_img.column = column;
    multi_channel_img.field = field;
    multi_channel_img.timepoint = timepoint;
    for chan_num=[app.plates(plate_num).channels]
      image_name = sprintf(...
        'r%02dc%02df%02dp%02d-ch%dsk%dfk1fl1.tiff',...
        row,column,field,plate_file_num,chan_num,timepoint);
      image_path = sprintf(...
        '%s/%s', image_dir,image_name);
      if ~exist(image_path) % If the file doesn't exist, reset the dropdown box values and return to avoid updating the figure
        draw_display(app);
        uialert(app.UIFigure,'Sorry, the image file you are trying to process does not exist. A bug allowed this to happen.','Bug', 'Icon','error');
        multi_channel_img = [];
        return
      end

      multi_channel_img.ImageName = image_name;
      multi_channel_img.chans(chan_num).folder = image_dir;
      multi_channel_img.chans(chan_num).name = image_name;
      multi_channel_img.chans(chan_num).path = image_path;
    end
  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'ZeissSplitTiffs','FlatFiles_SingleChannel'})
    img_num = app.ExperimentDropDown.Value;
    multi_channel_img = app.ExperimentDropDown.UserData(img_num);
  end
end