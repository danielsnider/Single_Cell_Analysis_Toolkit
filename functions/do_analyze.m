function fun(app, an_num)
  try
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
        meas.name = strrep(meas_name, '_', ' '); % replace underscores with spaces for added prettyness
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
        meas.name = strrep(meas_name, '_', ' '); % replace underscores with spaces for added prettyness
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

  % Catch Plugin Error
  catch ME
    handle_plugin_error(app,ME,'analyze',an_num);
  end
end