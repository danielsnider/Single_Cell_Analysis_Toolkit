function changed_ZSliceDropDown(app)
  try
    % changed_RowColumnFieldTimepoint_DropDown(app);
    update_figure(app);

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end
end