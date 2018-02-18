function start_processing_of_one_image(app)

  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;


  % Needing when processing a new image
  function NewResultCallback(iterTable)
    app.ResultTable_for_display = iterTable;
  end


  %% Load Images
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
        return
      end
      % app.image(chan_num).data = imread(app.image(chan_num).path);

      multi_channel_img.ImageName = image_name;
      multi_channel_img.chans(chan_num).folder = image_dir;
      multi_channel_img.chans(chan_num).name = image_name;
      multi_channel_img.chans(chan_num).path = image_path;
      % app.image(chan_num).data = do_preprocessing(app,plate_num,chan_num,image_path);
    end
  elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')
    for chan_num=[app.plates(plate_num).channels]
      img_num = app.ExperimentDropDown.Value;
      multi_channel_img = app.ExperimentDropDown.UserData(img_num);
      % image_path = multi_channel_img.chans(chan_num).path;
      % app.image(chan_num).data = do_preprocessing(app,plate_num,chan_num,image_path);
    end
  end


  % if ~isempty(app.segment)
    % Compute all processing for this new image
    imgs_to_process = [multi_channel_img];
    current_img_number = 1;
    NumberOfImages = 1;
    is_parallel_processing = false;
    process_single_image(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,@NewResultCallback);

    % Update list of measurements in the display tab
    draw_display_measure_selection(app);

    % Update list of measurements in the analyze tab
    changed_MeasurementNames(app);
  % end
end