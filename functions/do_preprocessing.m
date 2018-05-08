function img = do_preprocess_image(app, plate_num, chan_num, img_path)
  try

    if ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Formats'})
      img = img_path; % data is already in memory here
      
    else % Read image from disk for all other formats 
      if ~exist(img_path) % If the file doesn't exist warn user
        msg = sprintf('Could not find the image file at location: %s',img_path);
        uialert(app.UIFigure,msg,'File Not Found', 'Icon','error');
        error(msg);
      end

      [filepath,name,ext] = fileparts(img_path);
      if isvalid(app.StartupLogTextArea.tx) == 1
        msg = sprintf('Loading image %s', [name ext]);
        if app.CheckBox_Parallel.Value && app.processing_running
            disp(msg)
  %         send(app.ProcessingLogQueue, msg);
        else
          app.log_processing_message(app, msg);
        end
      end

      img = imread(img_path);
    end
      
    
    % Return if no preprocessing is configured
    if sum(ismember(fields(app),'preprocess_tabgp'))==0
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
      for field_num=1:length(app.preprocess{proc_num}.fields)
        param_idx = app.preprocess{proc_num}.fields{field_num}.UserData.param_idx;
        if isfield(app.preprocess{proc_num}.fields{field_num}.UserData,'ParamOptionalCheck') && ~app.preprocess{proc_num}.fields{field_num}.UserData.ParamOptionalCheck.Value
          algo_params(param_idx) = {false};
          continue
        end
        algo_params(param_idx) = {app.preprocess{proc_num}.fields{field_num}.Value};
      end

      % Call algorithm
      algo_name = app.preprocess{proc_num}.AlgorithmDropDown.Value;

      if isvalid(app.StartupLogTextArea.tx) == 1
        preprocess_name = app.preprocess{proc_num}.tab.Title;
        msg = sprintf('%s ''%s.m''', preprocess_name, algo_name);
        if app.CheckBox_Parallel.Value && app.processing_running
          send(app.ProcessingLogQueue, msg);
        else
          app.log_processing_message(app, msg);
        end
      end

      plugin_name = app.preprocess{proc_num}.tab.Title;

      try
        img = feval(algo_name, plugin_name, proc_num, img, algo_params{:});

      % Catch Plugin Error
      catch ME
        handle_plugin_error(app,ME,'preprocess',proc_num);
      end

    end

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end