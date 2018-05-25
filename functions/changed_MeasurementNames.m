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
      
    %% Tracking tab
    % Populate track by measurements list box
    app.TrackMeasuresListBox.Items = meas_names;
    app.TimeColumnDropDown.Items = meas_names;    
    % Automatically try to find the right measurements for the tracking tab
    if isempty(app.TrackMeasuresListBox.Value)
      auto_chosen_measure_names = meas_names(contains(lower(meas_names),'centroid'));
      app.TrackMeasuresListBox.Value = auto_chosen_measure_names;
    end
    if isempty(app.TimeColumnDropDown.Value)
      auto_chosen_time_name = meas_names(contains(lower(meas_names),'time'));
      app.TimeColumnDropDown.Value = auto_chosen_time_name{1};
    end
    
  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end
end

