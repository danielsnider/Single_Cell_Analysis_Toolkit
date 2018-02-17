function function fun(app, an_num)
  algo_name = app.analyze{an_num}.AlgorithmDropDown.Value;

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
  algo_params = {};
  for idx=1:length(app.analyze{an_num}.fields)
    if isfield(app.analyze{an_num}.fields{idx}.UserData,'ParamOptionalCheck') && ~app.analyze{an_num}.fields{idx}.UserData.ParamOptionalCheck.Value
      algo_params(length(algo_params)+1) = {false};
      continue
    end
    algo_params(length(algo_params)+1) = {app.analyze{an_num}.fields{idx}.Value};
  end

  % Call algorithm
  img = feval(algo_name, algo_params{:});


end