function fun(app)
  %% Setup
  app.ProgressSlider.Value = 0; % reset progress bar to 0
  ResultTable = [];
  images_to_process = [];

  % Get image names that weren't filtered from all plates
  imgs_to_process = [];
  for plate_num=1:length(app.plates)
    plate=app.plates(plate_num);
    num_channels = length(plate.channels);

    for img_num=1:num_channels:length(app.plates(plate_num).img_files_subset)
      multi_channel_img = {};
      multi_channel_img.channel_nums = plate.channels;
      multi_channel_img.plate_num = plate_num;
      multi_channel_img.chans = [];
      image_file = app.plates(plate_num).img_files_subset(img_num);
      multi_channel_img.row = image_file.row{:};
      multi_channel_img.column = image_file.column{:};
      multi_channel_img.field = image_file.field{:};
      multi_channel_img.timepoint = image_file.timepoint{:};
      multi_channel_img.ImageName = image_file.name;
      for chan_num=[plate.channels]
        image_filename = image_file.name; % ex. r02c02f01p01-ch2sk1fk1fl1.tiff
        if ~strcmp(plate.metadata.ImageNamingScheme, 'Operetta')
          msg = sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "Operetta". Aborting.',plate.metadata.ImageNamingScheme);
          uialert(app.UIFigure,msg,'Unkown image naming scheme', 'Icon','error');
          error(msg);
        end
        image_filename(16) = num2str(chan_num); % change the channel number
        multi_channel_img.chans(chan_num).folder = image_file.folder;
        multi_channel_img.chans(chan_num).name = image_filename;
        multi_channel_img.chans(chan_num).path = [image_file.folder '\' image_filename];
      end
      imgs_to_process = [imgs_to_process; multi_channel_img];
    end
  end

  NumberOfImages = length(imgs_to_process);

  %% Loop over images performing segmentation and measuring
  for current_img_number=1:NumberOfImages
  % while length(images_to_process)
    msg = sprintf('Processing image %d of %d.',current_img_number,NumberOfImages);
    app.log_processing_message(app, msg);
    
    image_file = imgs_to_process(current_img_number);
    plate_num = image_file.plate_num;

    % Load all image channels
    app.image = [];
    for chan_num=[image_file.channel_nums]
      % Only Operetta Image Naming Scheme is Supported
      if ~strcmp(plate.metadata.ImageNamingScheme, 'Operetta')
        msg = sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "Operetta".',plate.metadata.ImageNamingScheme);
        uialert(app.UIFigure,msg,'Unkown image naming scheme', 'Icon','error');
      end
      % Load Image
      app.image(chan_num).data = imread(image_file.chans(chan_num).path);
    end

    % Update the image that is selected in the display tab
    app.PlateDropDown.Value = plate_num;
    draw_display_image_selection(app);
    % app.ExperimentDropDown.Value = experiment;
    app.RowDropDown.Value = image_file.row;
    app.ColumnDropDown.Value = image_file.column;
    app.FieldDropDown.Value = image_file.field;
    app.TimepointDropDown.Value = image_file.timepoint;

    %% Perform Segmentation
    % Loop over each configured segment and execute the segmentation algorithm
    for seg_num=1:length(app.segment)
      app.segment{seg_num}.result = app.segment{seg_num}.do_segmentation(app, 'Update');
    end

    %% Primary Segment Handling
    % Update subcomponent segment-ids to match the id of the primary segment that they are and must be contained in
    primary_seg_num = app.PrimarySegmentDropDown.Value;
    primary_seg_data = app.segment{primary_seg_num}.result;
    primary_seg_data = bwlabel(primary_seg_data); % Make sure the data is labelled properly
    app.segment{primary_seg_num}.result = primary_seg_data;
    NumberOfCells = max(primary_seg_data(:));
    % Loop over non-primary segment results and properly set the pixel values to be what is found in the region of the primary id
    if NumberOfCells > 0
      for seg_num=1:length(app.segment)
        if seg_num==primary_seg_num % skip primary segment, only operate on subcomponents
          continue
        end
        sub_seg_data = app.segment{seg_num}.result;
        new_sub_seg_data = zeros(size(sub_seg_data));
        % Loop over each segment in the primary segment and update the subcomponent value
        for primary_seg_id=1:NumberOfCells
          % Set the subcomponent single segment value to be equal to the primary segment where the primary segment and subcomponent overlay.
          new_sub_seg_data(primary_seg_data==primary_seg_id) = primary_seg_id;
          new_sub_seg_data(sub_seg_data==0)=0;
        end
        app.segment{seg_num}.result = new_sub_seg_data;
      end
    end

    %% Perform Measurements
    if NumberOfCells > 0
      iterTable = table();
      % Loop over each configured measurement and execute the measurement code
      for meas_num=1:length(app.measure)
        algo_name = app.measure{meas_num}.AlgorithmDropDown.Value;
        msg = sprintf('Running %s...\n', algo_name);
        app.log_processing_message(app, msg);
        MeasureTable = do_measurement(app, plate, meas_num, algo_name);
        % Remove duplicate columns, keep the column that got there first
        new_col_names = MeasureTable.Properties.VariableNames(~ismember(MeasureTable.Properties.VariableNames,iterTable.Properties.VariableNames));
        MeasureTable = MeasureTable(:,new_col_names);
        % Store new measurements
        iterTable=[iterTable MeasureTable];
      end

      % Add X and Y coordinates for each primary label
      stats = regionprops(primary_seg_data,'centroid');
      centroids = cat(1, stats.Centroid);
      iterTable.x_coord = floor(centroids(:,1));
      iterTable.y_coord = floor(centroids(:,2));

      % Add UUID for each row
      iterTable(:,'ID') = uuid_array(height(iterTable))';

      % Add Plate Metadata
      for col_name=fields(plate.metadata)'
        col_value = plate.metadata.(col_name{:});
        if strcmp(col_name,'Name')
          col_name = 'PlateName'; % change this name to be less ambigious
        end
        iterTable(:,col_name) = {col_value}; % Add metada
      end

      % Add Image Metadata
      for col_name=fields(image_file)'
        col_value = image_file.(col_name{:});
        skip_names = {'channel_nums','chans'};
        if ismember(col_name,skip_names)
          continue % skip some info
        end
        if strcmp(col_name,'name')
          col_name = 'ImageName'; % change this name to be less ambigious
        end
        iterTable(:,col_name) = {col_value}; % Add metada
      end

      % Resolve missing table columns, they must all be present in both tables before combining
      if ~isempty(ResultTable)
          iterTablecolmissing = setdiff(ResultTable.Properties.VariableNames, iterTable.Properties.VariableNames);
          ResultTablecolmissing = setdiff(iterTable.Properties.VariableNames, ResultTable.Properties.VariableNames);
          iterTable = [iterTable array2table(nan(height(iterTable), numel(iterTablecolmissing)), 'VariableNames', iterTablecolmissing)];
          ResultTable = [ResultTable array2table(nan(height(ResultTable), numel(ResultTablecolmissing)), 'VariableNames', ResultTablecolmissing)];
      end

      % Save result
      ResultTable = [iterTable; ResultTable];
    end

    %% Update Progress Bar
    progress = current_img_number/NumberOfImages;
    app.ProgressSlider.Value = progress;
  end
  app.log_processing_message(app, 'DONE.');

  app.ResultTable = ResultTable;
  % Update list of measurements in the display tab
  draw_display_measure_selection(app);

end