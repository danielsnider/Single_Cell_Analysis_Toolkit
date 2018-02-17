function fun(app)
  % Get measurement names from ResultTable of if not available from ResultTable_for_display
  if ~isempty(app.ResultTable)
    meas_names = app.ResultTable.Properties.VariableNames;
  elseif ~isempty(app.ResultTable_for_display)
    meas_names = app.ResultTable_for_display.Properties.VariableNames;
  else
    return
  end

  % Populate analyze dropdowns with measurement names 
  for an_num=1:length(app.analyze)
    if isfield(app.analyze{an_num},'MeasurementDropDown')
      for drop_num=1:length(app.analyze{an_num}.MeasurementDropDown)
        app.analyze{an_num}.MeasurementDropDown{drop_num}.Items = meas_names;
      end
    end
  end
end

