function fun(app)
  try
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

    % Loop over lines of text in the filters text area and convert each line to an item in a cell array
    try

      % Do filtering
      [app.ResultTable num_filtered_rows] = do_filter(app.ResultTable, Filter);
    % Catch Application Error
    catch ME
      handle_filtering_error(app,ME);
    end

    % Update UI
    app.NumberBeforeFiltering.Value = before_height;
    app.NumberAfterFiltering.Value = height(app.ResultTable);

    % Save this value for the future so that if a user enters an invalid filter it can be reverted to
    app.FiltersTextArea.UserData.LastValue = app.FiltersTextArea.Value;



  catch ME
    handle_application_error(app,ME);
  end

end