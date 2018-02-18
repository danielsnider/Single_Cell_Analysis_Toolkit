function fun(app, an_num)
  algo_name = app.analyze{an_num}.AlgorithmDropDown.Value;
  algo_params = {};

  if ~isempty(app.ResultTable)
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
      if isfield(app.analyze{an_num}.fields{field_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.fields{field_num}.UserData.ParamOptionalCheck.Value
        algo_params(length(algo_params)+1) = {false};
        continue
      end
      algo_params(length(algo_params)+1) = {app.analyze{an_num}.fields{field_num}.Value};
    end
  end

  % Create list of measurements to be passed to the plugin
  if isfield(app.analyze{an_num},'MeasurementDropDown')
    for drop_num=1:length(app.analyze{an_num}.MeasurementDropDown)
      if isfield(app.analyze{an_num}.MeasurementDropDown{drop_num}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.MeasurementDropDown{drop_num}.UserData.ParamOptionalCheck.Value
        algo_params(length(algo_params)+1) = {false};
        continue
      end
      meas_name = app.analyze{an_num}.MeasurementDropDown{drop_num}.Value;
      meas_data = ResultTable{:,meas_name};
      algo_params(length(algo_params)+1) = {meas_data};
      algo_params(length(algo_params)+1) = {strrep(meas_name, '_', ' ')}; % replace underscores with spaces for added prettyness
    end
  end

  % Call algorithm
  feval(algo_name, algo_params{:});


end