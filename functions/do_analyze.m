function fun(app, an_num)
  try
    busy_state_change(app,'busy');

    algo_name = app.analyze{an_num}.AlgorithmDropDown.Value;
    algo_params = {};

    if ~isempty(app.ResultTable_filtered)
      ResultTable = app.ResultTable_filtered;
    elseif ~isempty(app.ResultTable)
      ResultTable = app.ResultTable;
    elseif ~isempty(app.ResultTable_for_display)
      ResultTable = app.ResultTable_for_display;
    else
      msg = sprintf('Could not do analysis because result data does not exist.');
      uialert(app.UIFigure,msg,'Result Data Not Found', 'Icon','error');
      return
    end

    % Create list of algorithm parameter values to be passed to the plugin
    if isfield(app.analyze{an_num},'fields')
      for field_num=1:length(app.analyze{an_num}.fields)
        param_idx = app.analyze{an_num}.fields{field_num}.UserData.param_idx;
        if isfield(app.analyze{an_num}.fields{field_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.fields{field_num}.UserData.ParamOptionalCheck.Value
          algo_params(param_idx) = {false};
          continue
        end
        algo_params(param_idx) = {app.analyze{an_num}.fields{field_num}.Value};
      end
    end

    % Create list of segmentation results to be passed to the plugin
    if isfield(app.analyze{an_num}, 'SegmentDropDown')
      for drop_num=1:length(app.analyze{an_num}.SegmentDropDown)
        param_idx = app.analyze{an_num}.SegmentDropDown{drop_num}.UserData.param_idx;
        if isfield(app.analyze{an_num}.SegmentDropDown{drop_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.SegmentDropDown{drop_num}.UserData.ParamOptionalCheck.Value
          algo_params(param_idx) = {false};
          continue
        end
        dep_seg_num = app.analyze{an_num}.SegmentDropDown{drop_num}.Value;
        algo_supports_3D = app.analyze{an_num}.algorithm_info.supports_3D;
        if isempty(dep_seg_num)
          input_name = app.analyze{an_num}.SegmentDropDownLabel{drop_num}.Text;
          msg = sprintf('Missing input required for the "%s" parameter to the algorithm "%s". Please see the "%s" analyze configuration tab and correct this before running the algorithm or changing the other input parameters to the algorithm.', input_name, algo_name, app.analyze{an_num}.tab.Title);
          uialert(app.UIFigure,msg,'Missing Input', 'Icon','error');
          result = [];
          return
        end
        dep_algo_name = app.segment{dep_seg_num}.AlgorithmDropDown.Value;
        segment_result = do_segmentation(app, dep_seg_num, dep_algo_name, app.image); % operate on the last loaded image in app.img
        if ~algo_supports_3D
          segment_result = segment_result.matrix; % 2D only needs/supports a matrix data structure instead of that and 3D surfaces
        end
        algo_params(param_idx) = {segment_result};
      end
    end

    % Create list of input channels to be passed to the plugin
    if isfield(app.analyze{an_num},'ChannelDropDown')
      for idx=1:length(app.analyze{an_num}.ChannelDropDown)
        param_idx = app.analyze{an_num}.ChannelDropDown{idx}.UserData.param_idx;
        if isfield(app.analyze{an_num}.ChannelDropDown{idx}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.ChannelDropDown{idx}.UserData.Value
          algo_params(param_idx) = {false};
          continue
        end
        drop_num = app.analyze{an_num}.ChannelDropDown{idx}.Value;
        chan_name = app.analyze{an_num}.ChannelDropDown{idx}.UserData.chan_names(drop_num);
        plate_num = app.PlateDropDown.Value;
        dep_chan_num = find(strcmp(app.plates(plate_num).chan_names,chan_name));
        image_data = app.image(dep_chan_num).data;
        algo_params(param_idx) = {image_data};
      end
    end

    % Create list of measurements to be passed to the plugin
    if isfield(app.analyze{an_num},'MeasurementDropDown')
      for drop_num=1:length(app.analyze{an_num}.MeasurementDropDown)
        param_idx = app.analyze{an_num}.MeasurementDropDown{drop_num}.UserData.param_idx;
        if isfield(app.analyze{an_num}.MeasurementDropDown{drop_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.MeasurementDropDown{drop_num}.UserData.ParamOptionalCheck.Value
          algo_params(param_idx) = {false};
          continue
        end
        meas = {};
        meas_name = app.analyze{an_num}.MeasurementDropDown{drop_num}.Value;
        meas.name = meas_name;
        meas.pretty_name = strrep(meas_name, '_', ' '); % replace underscores with spaces for added prettyness
        meas.data = ResultTable{:,meas_name};
        algo_params(param_idx) = {meas};
      end
    end

    % If ResultTable is needed for Analysis, Assign ResultTable to param
    if isfield(app.analyze{an_num},'ResultTableBox')
      for drop_num=1:length(app.analyze{an_num}.ResultTableBox)
        param_idx = app.analyze{an_num}.ResultTableBox{drop_num}.UserData.param_idx;
        if isfield(app.analyze{an_num}.ResultTableBox{drop_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.ResultTableBox{drop_num}.UserData.ParamOptionalCheck.Value
          algo_params(param_idx) = {false};
          continue
        end
        algo_params(param_idx) = {app.ResultTable};
      end
    end
    
    % ResultTable of the currently displayed image 
    if isfield(app.analyze{an_num},'ResultTableDisp')
      for drop_num=1:length(app.analyze{an_num}.ResultTableDisp)
        param_idx = app.analyze{an_num}.ResultTableDisp{drop_num}.UserData.param_idx;
        if isfield(app.analyze{an_num}.ResultTableDisp{drop_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.ResultTableDisp{drop_num}.UserData.ParamOptionalCheck.Value
          algo_params(param_idx) = {false};
          continue
        end
        algo_params(param_idx) = {app.ResultTable_for_display};
      end
    end
    
    % Info for well metadata
    if isfield(app.analyze{an_num},'MeasurementListBox')
      for drop_num=1:length(app.analyze{an_num}.MeasurementListBox)
        param_idx = app.analyze{an_num}.MeasurementListBox{drop_num}.UserData.param_idx;
        if isfield(app.analyze{an_num}.MeasurementListBox{drop_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.MeasurementListBox{drop_num}.UserData.ParamOptionalCheck.Value
          algo_params(param_idx) = {false};
          continue
        end
        meas = {};
        meas_name = app.analyze{an_num}.MeasurementListBox{drop_num}.Value;
        meas.name = meas_name;
        meas.pretty_name = strrep(meas_name, '_', ' '); % replace underscores with spaces for added prettyness
        meas.data = ResultTable{:,meas_name};
        algo_params(param_idx) = {meas};
      end
    end
    
    % Info for WellConditions
    if isfield(app.analyze{an_num},'WellConditionListBox')
      for drop_num=1:length(app.analyze{an_num}.WellConditionListBox)        
        if any(contains(fieldnames(app.analyze{an_num}.WellConditionListBox{drop_num}),'UserData'))
            param_idx = app.analyze{an_num}.WellConditionListBox{drop_num}.UserData.param_idx;
            if isfield(app.analyze{an_num}.WellConditionListBox{drop_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.WellConditionListBox{drop_num}.UserData.ParamOptionalCheck.Value
              algo_params(param_idx) = {false};
              continue
            end
        meas = {};
        meas = app.analyze{an_num}.WellConditionListBox{drop_num}.Value';
%         meas_name = app.analyze{an_num}.WellConditionListBox{drop_num}.Value;
%         meas.name = strrep(meas_name, '_', ' '); % replace underscores with spaces for added prettyness
%         meas.data = meas.name;
        algo_params(param_idx) = {meas};
        end
      end
    end
    
    % ------------------------------ WORK IN PROGRESS ----------------------------
    if isfield(app.analyze{an_num},'InputUITable')
        
        for drop_num=1:length(app.analyze{an_num}.InputUITable)
            app.analyze{an_num}.InputUITable{drop_num}.UserData
        
        
        end
    end
    % ----------------------------------------------------------------------------
    if isstruct(app.StartupLogTextArea)
      analyze_name = app.analyze{an_num}.tab.Title;
      msg = sprintf('%s ''%s.m''', analyze_name, algo_name);
      if app.CheckBox_Parallel.Value && app.processing_running
        send(app.ProcessingLogQueue, msg);
      else
        app.log_processing_message(app, msg);
      end
    end

    plugin_name = app.analyze{an_num}.tab.Title;

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

  try
    % Call algorithm
    feval(algo_name, plugin_name, an_num, algo_params{:});

    busy_state_change(app,'not busy');

  % Catch Plugin Error
  catch ME
    handle_plugin_error(app,ME,'analyze',an_num);
  end
end