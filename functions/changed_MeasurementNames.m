function fun(app)
  try
    % Get measurement names and well conditions from ResultTable or if not available from ResultTable_for_display
    if ~isempty(app.ResultTable)
      meas_names = app.ResultTable.Properties.VariableNames;
      if ismember(meas_names,{'WellConditions'})
        well_conditions = unique(app.ResultTable.WellConditions,'stable');
      end
    elseif ~isempty(app.ResultTable_for_display)
      meas_names = app.ResultTable_for_display.Properties.VariableNames;
      if ismember(meas_names,{'WellConditions'})
        well_conditions = unique(app.ResultTable_for_display.WellConditions,'stable');
      end
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

     % Populate analyze listboxs with well info
    if ismember(meas_names,{'WellConditions'})
      for an_num=1:length(app.analyze)
        if isfield(app.analyze{an_num},'WellConditionListBox')
          for drop_num=1:length(app.analyze{an_num}.WellConditionListBox)
            app.analyze{an_num}.WellConditionListBox{drop_num}.Items = well_conditions;
          end
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

