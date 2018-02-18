function fun(app)
  is_movie = app.MontageMovieCheckBox.Value;
  imgs_to_process = get_images_to_process(app);
  save_dir = uigetdir(app.ChooseplatemapEditField.Value,'Select Directory to Save Montage In');
  mag = num2str(app.AtMagnificationSpinner.Value);
  fps = app.MovieatFPSSpinner.Value;
  date_str = datestr(now,'yyyymmddTHHMMSS');
  gif_filename = sprintf('%s/montage_%s.gif', save_dir, date_str);
  count = 1;

  % Display log
  app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [126,651,650,105]);
  app.log_startup_message(app, 'Starting Montage.');
  pause(0.5); % enough time for the log text area to appear on screen

  for img=imgs_to_process'
    plate_num = img.plate_num;
    if plate_num ~= app.PlateDropDown.Value
      continue % only operate on the currently selected plate
    end

    msg = sprintf('Processing montage for image %s...', img.ImageName);
    app.log_startup_message(app, msg);

    if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
      app.RowDropDown.Value = img.row;
      app.ColumnDropDown.Value = img.column;
      app.FieldDropDown.Value = img.field;
      app.TimepointDropDown.Value = img.timepoint;
      app.ExperimentDropDown.Value = complex(img.row,-img.column);
      filename = sprintf('%s/montage_%s_plate%d_row%d_column%d_field%d_timepoint%d.png', save_dir, date_str, img.row, img.column, img.field, img.timepoint);

    elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')
      app.ExperimentDropDown.Value = img.experiment_num;
      filename = sprintf('%s/montage_%s_%s.png', save_dir, date_str, img.experiment);
    end

    start_processing_of_one_image(app); % process image and display
    update_figure(app);
    h = figure(111); % set focus to display figure
    if ~is_movie
      export_fig(filename, ['-m' mag]); % save figure as image
    end
    if is_movie
      [imageData, alpha] = export_fig(filename, ['-m' mag]); % save figure as image
      % Capture the plot as an image
      % frame = getframe(h); 
      % im = frame2im(frame); 
      % [imind,cm] = rgb2ind(im,256);
      % Write to GIF File 
      %imwrite(imind, cm, filename, 'gif', 'DelayTime',0.5, 'WriteMode', 'append'); 
      [imind,cm] = rgb2ind(imageData,256);
      if count == 1
          imwrite(imind, cm, gif_filename, 'gif', 'DelayTime',1/fps, 'Loopcount', inf); 
      else 
          imwrite(imind, cm, gif_filename, 'gif', 'DelayTime',1/fps, 'WriteMode', 'append'); 
      end 
      count = count + 1;
    end

  end


  % Delete log
  app.log_startup_message(app, 'Finished');
  delete(app.StartupLogTextArea);
  % pause(0.5);
  % msg = sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "OperettaSplitTiffs". Aborting.',plate.metadata.ImageFileFormat);
  % uialert(app.UIFigure,msg,'Saved Montage', 'Icon','success');

end