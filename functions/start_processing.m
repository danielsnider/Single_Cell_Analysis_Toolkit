function fun(app)
  % app.seeds = {};
  % app.seeds(1).name = 'Nucleus';
  % app.seeds(1).value = [10 10; 10 15; 15 15; 15 20; 20 20];

  % app.labels{idx}
  % app.seeds{idx}
  % app.measurements{idx}


  app.ProgressSlider.Value = 0; % reset progress bar to 0
  ResultTable = [];
  count = 1;
  NumberOfImages = length(app.image_names);
  % Loop over images performing spotting, segmentation, and measuring
  for idx=1:NumberOfImages
    image_name=app.image_names{idx};
    msg = sprintf('Processing image %d of %d.',count,NumberOfImages);
    app.log_processing_message(app, msg);
    % app.ProcessingLogTextArea.Value = sprintf('%s\n%s',...
      % char(app.ProcessingLogTextArea.Value),msg)
    % Load image
    app.img = imread(image_name);
    % Perform spotting
    seeds = [];
    if ~strcmp(app.SpotAlgorithmDropDown.Value, 'Off')
      seeds = app.spotting.Callback(app, 'Update');
    end
    % Perform Segmentation
    % Perform Measurements
    % Save result
    ResultTable = [ResultTable; seeds];
    si = size(ResultTable)
    count = count + 1;
    % Update Progress Bar
    progress = idx/NumberOfImages
    app.ProgressSlider.Value = progress;
  end

end