function result = do_segmentation(app, seg_num, algo_name, imgs)
  
  try

    % Create list of algorithm parameter values to be passed to the plugin
    algo_params = {};
    for idx=1:length(app.segment{seg_num}.fields)
      if isfield(app.segment{seg_num}.fields{idx}.UserData,'ParamOptionalCheck') && ~app.segment{seg_num}.fields{idx}.UserData.ParamOptionalCheck.Value
        algo_params(length(algo_params)+1) = {false};
        continue
      end
      algo_params(length(algo_params)+1) = {app.segment{seg_num}.fields{idx}.Value};
    end

    % Create list of segmentation results to be passed to the plugin
    if isfield(app.segment{seg_num}, 'SegmentDropDown')
      for drop_num=1:length(app.segment{seg_num}.SegmentDropDown)
        if isfield(app.segment{seg_num}.SegmentDropDown{drop_num}.UserData,'ParamOptionalCheck') && ~app.segment{seg_num}.SegmentDropDown{drop_num}.UserData.ParamOptionalCheck.Value
          algo_params(length(algo_params)+1) = {false};
          continue
        end
        dep_seg_num = app.segment{seg_num}.SegmentDropDown{drop_num}.Value;
        if isempty(dep_seg_num)
          input_name = app.segment{seg_num}.SegmentLabel{drop_num}.Text;
          msg = sprintf('Missing input required for the "%s" parameter to the algorithm "%s". Please see the "%s" segment configuration tab and correct this before running the algorithm or changing the other input parameters to the algorithm.', input_name, algo_name, app.segment{seg_num}.tab.Title);
          uialert(app.UIFigure,msg,'Missing Input', 'Icon','error');
          result = [];
          return
        end
        dep_algo_name = app.segment{dep_seg_num}.AlgorithmDropDown.Value;
        segment_result = do_segmentation(app, dep_seg_num, dep_algo_name, imgs); % operate on the last loaded image in app.img
        algo_params(length(algo_params)+1) = {segment_result};
      end
    end

    % Create list of input channels to be passed to the plugin
    for idx=1:length(app.segment{seg_num}.ChannelDropDown)
      if isfield(app.segment{seg_num}.ChannelDropDown{idx}.UserData,'ParamOptionalCheck') && ~app.segment{seg_num}.ChannelDropDown{idx}.UserData.Value
        algo_params(length(algo_params)+1) = {false};
        continue
      end
      drop_num = app.segment{seg_num}.ChannelDropDown{idx}.Value;
      chan_name = app.segment{seg_num}.ChannelDropDown{idx}.UserData(drop_num);
      plate_num = app.PlateDropDown.Value;
      dep_chan_num = find(strcmp(app.plates(plate_num).chan_names,chan_name));
      image_data = imgs(dep_chan_num).data;
      algo_params(length(algo_params)+1) = {image_data};
    end

     if isvalid(app.StartupLogTextArea)
       segment_name = app.segment{seg_num}.tab.Title;
       msg = sprintf('%s ''%s.m''', segment_name, algo_name);
       app.log_startup_message(app, msg);
     end

    % Call algorithm
     result = feval(algo_name, algo_params{:});
     app.segment{seg_num}.result = result;

  catch ME
    if strfind(ME.message,'infinite recursion within the program')
      msg = 'You have configured a circular loop in your segmentation dependencies. For example, A depends on B which depends on A. This causes infinite recursion within the program and matlab has ran out of memory. Please find and remove the dependency loop in your segmentation settings.';
      uialert(app.UIFigure,msg,'Boom!', 'Icon','error');
    end
    rethrow(ME)
  end
end