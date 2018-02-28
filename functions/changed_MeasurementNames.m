function fun(app)
  try
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
    
    % Populate analyze listboxs with measurement names 
    for an_num=1:length(app.analyze)
      if isfield(app.analyze{an_num},'MeasurementListBox')
        for drop_num=1:length(app.analyze{an_num}.MeasurementListBox)
          app.analyze{an_num}.MeasurementListBox{drop_num}.Items = meas_names;
        end
      end
    end

    % Populate filter sort by dropdown
    app.FilterSortByDropDown.Items = meas_names;
    
  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end
end

