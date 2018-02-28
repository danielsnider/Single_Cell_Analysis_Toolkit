function fun(app)
  % Segment1_DAPI_MeanIntensity; Segment1_DAPI_MeanIntensity >= 487.7

  try
    if ~istable(app.ResultTable) || isempty(app.ResultTable)
      uialert(app.UIFigure,'Sorry, there is no data to filter. Please use the Measure tab to create data or the Analyze tab to load data.','No Data to Filter', 'Icon','error');
      return % Do nothing if no table
    end

    Filter = struct();
    Filter.column = app.FiltersTextArea.Value;
    Filter.sort = app.FilterSortByDropDown.Value;
    before_height = height(app.ResultTable);

    % Keep first and last if not infinity
    if app.FilterKeepFirst.Value ~= inf
      Filter.first = app.FilterKeepFirst.Value;
    end
    if app.FilterKeepLast.Value ~= inf
      Filter.last = app.FilterKeepLast.Value;
    end

    try
      % Do filtering
      [app.ResultTable_filtered num_filtered_rows] = do_filter(app.ResultTable, Filter);

    % Catch Application Error
    catch ME
      handle_filtering_error(app,ME);
    end

    %% Update UI
    after_height = height(app.ResultTable_filtered);
    app.NumberBeforeFiltering.Value = before_height;
    app.NumberAfterFiltering.Value = after_height;
    % Update text for reduction counts
    if ~isempty(num_filtered_rows)
      str_num_filtered_rows = arrayfun(@num2str,num_filtered_rows,'UniformOutput', false);
      app.FilterReductionTextArea.Value = str_num_filtered_rows;
    else
      app.FilterReductionTextArea.Value = {''};
    end
    if istable(app.ResultTable_filtered)
      app.Button_ViewFilteredData.Visible = 'on';
    end

  catch ME
    handle_application_error(app,ME);
  end

end