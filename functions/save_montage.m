function fun(app)
  is_movie = app.MontageMovieCheckBox.Value;
  imgs_to_process = get_images_to_process(app);
  save_dir = uigetdir(app.ChooseplatemapEditField.Value,'Select Directory to Save Montage In');
  mag = num2str(app.AtMagnificationSpinner.Value);
  date_str = datestr(now,'yyyymmddTHHMMSS');

  % Display log
  app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [126,651,650,105]);
  app.log_startup_message(app, 'Starting Montage.');
  pause(0.5); % enough time for the log text area to appear on screen

  for img=imgs_to_process'
    plate_num = img.plate_num;
    if plate_num ~= app.PlateDropDown.Value
      continue % only operate on the currently selected plate
    end

    msg = sprintf('Generating montage for image %s...', img.ImageName);
    app.log_startup_message(app, msg);

    if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
      app.RowDropDown.Value = img.row;
      app.ColumnDropDown.Value = img.column;
      app.FieldDropDown.Value = img.field;
      app.TimepointDropDown.Value = img.timepoint;
      app.ExperimentDropDown.Value = complex(img.row,-img.column);
      filename = sprintf('%s/montage_%s_plate%d_row%d_column%d_field%d_timepoint%d.png', save_dir, date_str, img.row, img.column, img.field, img.timepoint);

    elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')
      app.ExperimentDropDown.Value = img.experiment;
      filename = sprintf('%s/montage_%s_%s.png', date_str, save_dir, experiment);
    end

    start_processing_of_one_image(app); % process image and display
    update_figure(app);
    figure(111); % set focus to display figure
    export_fig(filename, ['-m' mag]); % save figure as image
  end

  % Delete log
  app.log_startup_message(app, 'Finished');
  delete(app.StartupLogTextArea);
  % msg = sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "OperettaSplitTiffs". Aborting.',plate.metadata.ImageFileFormat);
  % uialert(app.UIFigure,msg,'Saved Montage', 'Icon','success');

end