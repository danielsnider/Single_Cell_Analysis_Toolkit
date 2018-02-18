function img = do_preprocess_image(app, plate_num, chan_num, img_path)
  if ~exist(img_path) % If the file doesn't exist warn user
    msg = sprintf('Could not find the image file at location: %s',img_path);
    uialert(app.UIFigure,msg,'File Not Found', 'Icon','error');
    error(msg);
  end

  [filepath,name,ext] = fileparts(img_path);
  if isvalid(app.StartupLogTextArea)
    msg = sprintf('Loading image %s', [name ext]);
    app.log_startup_message(app, msg);
  end



  img = imread(img_path);
  
  % Return if no preprocessing is configured
  if isempty(app.preprocess_tabgp)
    return
  end

  % Get name of requested channel based on the current plate
  chan_name = app.plates(plate_num).chan_names(chan_num);

  % Loop over each user configured preprocessing step, check if it applies to the requested image, if so do it
  for proc_num = 1:length(app.preprocess)
    % Check if the configured preprocessing step's channel matches the requested image channel
    proc_chan_name = app.preprocess{proc_num}.ChannelDropDown.Value;
    if ~strcmp(proc_chan_name,chan_name)
      continue % not a match, skip to next
    end

    % Create list of algorithm parameter values to be passed to the plugin
    algo_params = {};
    for idx=1:length(app.preprocess{proc_num}.fields)
      if isfield(app.preprocess{proc_num}.fields{idx}.UserData,'ParamOptionalCheck') && ~app.preprocess{proc_num}.fields{idx}.UserData.ParamOptionalCheck.Value
        algo_params(length(algo_params)+1) = {false};
        continue
      end
      algo_params(length(algo_params)+1) = {app.preprocess{proc_num}.fields{idx}.Value};
    end

    % Call algorithm
    algo_name = app.preprocess{proc_num}.AlgorithmDropDown.Value;

    if isvalid(app.StartupLogTextArea)
      msg = sprintf('Preprocessing ''%s'' with image %s', algo_name, [name ext]);
      app.log_startup_message(app, msg);
    end

    img = feval(algo_name, img, algo_params{:});

  end

end