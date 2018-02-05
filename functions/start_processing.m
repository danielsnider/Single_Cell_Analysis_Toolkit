function fun(app)
  %% Setup
  app.ProgressSlider.Value = 0; % reset progress bar to 0
  ResultTable = [];
  NumberOfImages = length(app.image_names);
  images_to_process = app.image_names;

  % Collect names of all segments to measure
  all_segments_to_measure = {};
  for meas_num=1:length(app.measure)
    for param_num=1:length(app.measure{meas_num}.SegmentListbox)
      all_segments_to_measure{length(all_segments_to_measure)+1} = app.measure{meas_num}.SegmentListbox{param_num}.Value;
    end
  end
  all_segments_to_measure = unique(cat(1,all_segments_to_measure{:}));

  % Collect names of all channels to measure
  all_channels_to_measure = {};
  for meas_num=1:length(app.measure)
    for param_num=1:length(app.measure{meas_num}.ChannelListbox)
      all_channels_to_measure{length(all_channels_to_measure)+1} = app.measure{meas_num}.ChannelListbox{param_num}.Value;
    end
  end
  all_channels_to_measure = unique(cat(1,all_channels_to_measure{:}));

  %% Loop over images performing segmentation and measuring
  while images_to_process
    msg = sprintf('Processing image %d of %d.',NumberOfImages-length(images_to_process)+1,NumberOfImages);
    app.log_processing_message(app, msg);
    
    image_file = images_to_process(1);
    
    % Get plate for this image
    for plate_num=1:length(app.input_data.plates)
      if strcmp(app.input_data.plates(plate_num).ImageDir, image_file.folder)
        plate=app.input_data.plates(plate_num);
      end
    end

    % Load all image channels
    for chan_num=[plate.channels]
      % Only Operetta Image Naming Scheme is Supported
      if ~strcmp(plate.ImageNamingScheme, 'Operetta')
        errordlg(sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "Operetta".',plate.ImageNamingScheme));
      end
      % Build image path
      image_filename = image_file.name; % ex. r02c02f01p01-ch2sk1fk1fl1.tiff
      image_filename(16) = num2str(chan_num); % change the channel number
      app.image(chan_num).folder = image_file.folder;
      app.image(chan_num).name = image_filename;
      app.image(chan_num).path = [image_file.folder '\' image_filename];
      % Load Image
      app.image(chan_num).data = imread(app.image(chan_num).path);
    end

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
      % Loop over each configured measurement and execute the measurement code
      for meas_num=1:length(app.measurements)
        measurement = app.measurements{meas_num};
        msg = sprintf('Running %s...\n', measurement.name);
        app.log_processing_message(app, msg);
        Measurements = measurement.Callback(app, 'Update')

        %% BOUNDARIES EXAMPLE
        % Loop over known segments (app.measure{idx}.segments = segments = cell, nuc)
          % Get pixel boundaries

        %% REGION_PROPS EXAMPLE
        % Loop over known segments (app.measure_segments = segments = cell, nuc)
          % Take measurement per label (app.measure{idx}.metrics = area, shape)
          % Loop over known channels (app.measure_channels = channels = DAPI, SE)
            % Take measurement per channel (intensity)

        iterTable=[iterTable Measurements];
      end
      % Save result
      ResultTable = [ResultTable; iterTable];
    end

    % Remove image names from list of images to process
    for chan_num=[plate.channels]
      % If the next item in the list matches 
      if strcmp(images_to_process(1).name, app.image(chan_num).name) & strcmp(images_to_process(1).folder, app.image(chan_num).folder) % note the 1, it remains one because the list is shrinking, rather than being chan_num it would look too far ahead
        images_to_process(1) = []; % remove head of list
        continue
      end
      % Unfortunately the file wasn't the next in the list, so go looking for it and remove it
      fprintf('scanning images_to_process to remove finished file %s.\n',app.image(chan_num).name);
      for idx=1:length(images_to_process)
        if strcmp(images_to_process(idx).name, app.image(chan_num).name) & strcmp(images_to_process(idx).folder, app.image(chan_num).folder) % note the 1, it remains one because the list is shrinking, rather than being chan_num it would look too far ahead
          images_to_process(chan_num) = []; % remove from list
          continue
        end
      end
      error(sprintf('Could not find file "%s" in images_to_process to remove. Seek support.',app.image(chan_num).name))
    end

    %% Update Progress Bar
    progress = (NumberOfImages-length(images_to_process))/NumberOfImages;
    app.ProgressSlider.Value = progress;
  end

end