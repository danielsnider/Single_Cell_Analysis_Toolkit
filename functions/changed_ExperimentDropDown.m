function fun(app)
  try
    % Display log
%     app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
% app.StartupLogTextArea = txt_update;
    pause(0.1); % enough time for the log text area to appear on screen

    prev_fig = get(groot,'CurrentFigure'); % Save current figure
    
    plate_num = app.PlateDropDown.Value;
    if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
      % Dencode row and col positions of this experiment from a complex number because we stored it this way because matlab won't allow two seperate values per DataItem
      row_num = abs(real(app.ExperimentDropDown.Value));
      col_num = abs(imag(app.ExperimentDropDown.Value));

      app.RowDropDown.Value = row_num;
      app.ColumnDropDown.Value = col_num;
    elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'XYZCT-Bio-Formats')
      parse_input_structure_XYZCT_Bio_Formats(app,plate_num);
      img_num = app.ExperimentDropDown.Value;
      img_name = app.ExperimentDropDown.Items{app.ExperimentDropDown.Value};
      selected_img_name_idx = strcmp({app.ExperimentDropDown.UserData.ImageName}, img_name);
      available_multi_channel_img = app.ExperimentDropDown.UserData(selected_img_name_idx);
      timepoints = [available_multi_channel_img.timepoint];

      app.TimepointDropDown.Items = arrayfun(@(x) {num2str(x)},timepoints);
      app.TimepointDropDown.ItemsData = timepoints;
    end

    draw_display_image_selection(app);
    start_processing_of_one_image(app);
    update_figure(app);
    app.log_processing_message(app, 'Finished.');

    if ~isempty(prev_fig)
      figure(prev_fig); % Set back current figure to focus
    end

    % Delete log
%     delete(app.StartupLogTextArea);
% 	app.StartupLogTextArea.tx.String = {};

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end

