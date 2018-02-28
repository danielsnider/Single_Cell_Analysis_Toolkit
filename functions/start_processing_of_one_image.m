function start_processing_of_one_image(app)
  % Needing when processing a new image
  function NewResultCallback(iterTable)
    app.ResultTable_for_display = iterTable;
  end


  try
    temp2 = app.CheckBox_Parallel.Value;
    app.CheckBox_Parallel.Value = false;
    temp = app.CheckBox_TestRun.Value; % COMMENT HERE PLEAS
    app.CheckBox_TestRun.Value = true;
    start_processing(app, @NewResultCallback);
    app.CheckBox_TestRun.Value = temp;
    app.CheckBox_Parallel.Value = temp2;

    % Make button visible if there are results
    if istable(app.ResultTable_for_display) && height(app.ResultTable_for_display)
      app.Button_ViewOverlaidMeasurements.Visible = 'on';
    end

    % Update Filter Tab
    if istable(app.ResultTable)
      app.NumberBeforeFiltering.Value = height(app.ResultTable);
      app.NumberAfterFiltering.Value = height(app.ResultTable);
    end

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end