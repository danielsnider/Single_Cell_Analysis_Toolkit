function fun(app)
  %% Setup
  app.ProgressSlider.Value = 0; % reset progress bar to 0
  ResultTable = [];
  count = 1;
  NumberOfImages = length(app.image_names);

  %% Loop over images performing spotting, segmentation, and measuring
  for idx=1:NumberOfImages
    %% Setup
    image_name=app.image_names{idx};
    msg = sprintf('Processing image %d of %d.',count,NumberOfImages);
    app.log_processing_message(app, msg);
    
    %% Load Image
    app.img = imread(image_name);

    % %% Perform Spotting
    % seeds = [];
    % if ~strcmp(app.SpotAlgorithmDropDown.Value, 'Off')
    %   seeds = app.spotting.Callback(app, 'Update');
    % end

    %% Perform Segmentation
    % Loop over each configured segment and execute the segmentation algorithm
    for sid=1:length(app.segments)
      app.segments{sid}.result = app.segments{sid}.Callback(app, 'Update');
    end

    %% If there are no objects in the primary segment to measure, continue to the next image
    

    %% Primary Segment Handling
    % Update subcomponent segment-ids to match the id of the primary segment that they are contained in
    NumberOfCells = 0000

    %% Perform Measurements
    if NumberOfCells > 0
      % Loop over each configured measurement and execute the measurement code
      for mid=1:length(app.measurements)
        measurement = app.measurements{mid};
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


    %% Update Progress Bar
    progress = idx/NumberOfImages
    app.ProgressSlider.Value = progress;
    count = count + 1;
  end

end