function fun(app, an_num)
  try
    busy_state_change(app,'busy');

    algo_name = app.analyze{an_num}.AlgorithmDropDown.Value;
    algo_name_pretty = app.analyze{an_num}.AlgorithmDropDown.Items{find(strcmp(app.analyze{an_num}.AlgorithmDropDown.ItemsData,app.analyze{an_num}.AlgorithmDropDown.Value))};
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

    progressdlg_msg = sprintf('Running analysis %s', algo_name_pretty);
    app.progressdlg = uiprogressdlg(app.UIFigure,'Title','Please Wait','Message', progressdlg_msg, 'Cancelable', 'on');
    assignin('base','app_progressdlg',app.progressdlg); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way

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
      num_segments = length(app.analyze{an_num}.SegmentDropDown);
      for drop_num=1:num_segments
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
        dep_seg_name = app.segment{dep_seg_num}.Name.Value;

        app.progressdlg.Message = sprintf('%s\n%s',progressdlg_msg,sprintf('Segmenting %s...', dep_seg_name));
        app.progressdlg.Value = (0.5 / num_segments) + ((drop_num-1) / num_segments);

        if isfield(app.segment{dep_seg_num},'result') && ~isempty(app.segment{dep_seg_num}.result)
          segment_result = app.segment{dep_seg_num}.result;
        else
          % segment_result = do_segmentation(app, dep_seg_num, dep_algo_name, app.image); % operate on the last loaded image in app.img
          % IMPORTANT TODO: Handle primary segment somehow: (A) avoid this code path always (B) add primary segment handling (C-ENACTED HERE) run  process of one image
          start_processing_of_one_image(app);
          segment_result = app.segment{dep_seg_num}.result;
        end
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
        algo_params(param_idx) = {ResultTable};
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
        subsetTable = get_current_displayed_resultTable(app);
        algo_params(param_idx) = {subsetTable};
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
        meas_names = app.analyze{an_num}.MeasurementListBox{drop_num}.Value;
        meas.names = meas_names;
        meas.pretty_names = strrep(meas_names, '_', ' '); % replace underscores with spaces for added prettyness
        for meas_name = meas_names
          meas_name = meas_name{:};
          meas.(meas_name) = ResultTable{:,meas_name};
        end
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
    
    % Pass static text through Param
    if isfield(app.analyze{an_num},'static_Text')
      for drop_num=1:length(app.analyze{an_num}.static_Text)
        param_idx = app.analyze{an_num}.static_Text{drop_num}.UserData.param_idx;
        if isfield(app.analyze{an_num}.static_Text{drop_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.static_Text{drop_num}.UserData.ParamOptionalCheck.Value
          algo_params(param_idx) = {false};
          continue
        end
        meas = {};
        meas = app.analyze{an_num}.static_Text{drop_num}.Value;
        algo_params(param_idx) = {meas};
      end
    end
    
    % ------------------------------ WORK IN PROGRESS ----------------------------
    if isfield(app.analyze{an_num},'InputUITable')
        
        for drop_num=1:length(app.analyze{an_num}.InputUITable)
            param_idx = app.analyze{an_num}.InputUITable{drop_num}.UserData
            
            meas = {};
            meas = app.analyze{an_num}.InputUITable{drop_num}.Data;
            algo_params(param_idx) = {meas};
        
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
    app.progressdlg.Message = sprintf('%s...',progressdlg_msg);
    app.progressdlg.Value = 0.7;

    % Call algorithm
    function_handle = str2func(algo_name);
    num_output = nargout(function_handle);
    if num_output == 0
      feval(algo_name, plugin_name, an_num, algo_params{:});
    elseif num_output == 1
      return_data = feval(algo_name, plugin_name, an_num, algo_params{:});
      % The analzye plugin can return a table which we expect to be a superset of the current result table
      if istable(return_data)
        app.ResultTable = return_data;
        app.ResultTable_for_display = return_data;
      end
    end

    close(app.progressdlg);
    uialert(app.UIFigure,'Analysis complete.','Success', 'Icon','success');
    busy_state_change(app,'not busy');

  % Catch Plugin Error
  catch ME
    handle_plugin_error(app,ME,'analyze',an_num);
  end
end