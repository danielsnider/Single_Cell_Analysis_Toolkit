function start_processing_of_one_image(app)
  % Needing when processing a new image
  function NewResultCallback(iterTable)
    app.ResultTable_for_display = iterTable;
  end


  try
    % Currently selected plate number
    plate_num = app.PlateDropDown.Value;

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

        multi_channel_img.ImageName = image_name;
        multi_channel_img.chans(chan_num).folder = image_dir;
        multi_channel_img.chans(chan_num).name = image_name;
        multi_channel_img.chans(chan_num).path = image_path;
      end
    elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')
      for chan_num=[app.plates(plate_num).channels]
        img_num = app.ExperimentDropDown.Value;
        multi_channel_img = app.ExperimentDropDown.UserData(img_num);
      end
    end

    % Compute all processing for this new image
    app.image_info = multi_channel_img;
    imgs_to_process = [multi_channel_img];
    current_img_number = 1;
    NumberOfImages = 1;
    is_parallel_processing = false;
    process_single_image(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,@NewResultCallback);

    % Update list of measurements in the display tab
    draw_display_measure_selection(app);

    % Make button visible if there are results
    if istable(app.ResultTable_for_display) && height(app.ResultTable_for_display)
      app.Button_ViewOverlaidMeasurements.Visible = 'on';
    end

    % Update list of measurements in the analyze tab
    changed_MeasurementNames(app);

  % Catch Application Error
  catch ME
    % If no cause is attached to the error, this is the first place we're handling it create a uialert, add a cause, and rethrow the error
    if isempty(ME.cause)
      if isvalid(app.StartupLogTextArea)
        delete(app.StartupLogTextArea);
      end
      msg = sprintf('Sorry, an application error occured. Please check the error message in the Matlab console for any obvious problems. It is best to restart the application at this time. If the problem persists please report it in detail to: https://github.com/danielsnider/Single_Cell_Analysis_Toolkit/issues');
      uialert(app.UIFigure,msg,'Application Error', 'Icon','error');
      msgID = 'APP:ApplicationError';
      msg = msg;
      causeException = MException(msgID,msg);
      ME = addCause(ME,causeException);
      rethrow(ME)
    else
      rethrow(ME)
    end
  end

end