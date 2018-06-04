function fun(app)
  try
    % Currently selected plate number
    plate_num = app.PlateDropDown.Value;

    % Don't create montage for 3D image stack formats (not yet implemented)
    if app.plates(plate_num).supports_3D
      msg = sprintf('Sorry, creating a montage is currently not supported for the 3D image stack formats.');
      uialert(app.UIFigure,msg,'Not Yet Implemented', 'Icon','warn');
      return % don't create montage
    end

    is_movie = app.MontageMovieCheckBox.Value;
    imgs_to_process = get_images_to_process(app);
    save_dir = uigetdir(app.ChooseplatemapEditField.Value,'Select Directory to Save Montage In');
    mag = num2str(app.AtMagnificationSpinner.Value);
    fps = app.MovieatFPSSpinner.Value;
    date_str = datestr(now,'yyyymmddTHHMMSS');
    gif_filename = sprintf('%s/montage_%s.gif', save_dir, date_str);
    count = 1;

    % Display log
%     app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
% app.StartupLogTextArea = txt_update;
    app.log_processing_message(app, 'Starting Montage.');
    pause(0.5); % enough time for the log text area to appear on screen

    for img=imgs_to_process'
      plate_num = img.plate_num;
      if plate_num ~= app.PlateDropDown.Value
        continue % only operate on the currently selected plate
      end

      msg = sprintf('Processing montage for image %s...', img.ImageName);
      app.log_processing_message(app, msg);

      if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
        app.RowDropDown.Value = img.row;
        app.ColumnDropDown.Value = img.column;
        app.FieldDropDown.Value = img.field;
        app.TimepointDropDown.Value = img.timepoint;
        exp_val = complex(img.row,-img.column);
        if ismember(exp_val, app.ExperimentDropDown.ItemsData)
          app.ExperimentDropDown.Value = exp_val;
        end
        filename = sprintf('%s/montage_%s_plate%d_row%d_column%d_field%d_timepoint%d.png', save_dir, date_str, img.row, img.column, img.field, img.timepoint);

      elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'ZeissSplitTiffs','SingleChannelFiles'})
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
    app.log_processing_message(app, 'Finished');
    uialert(app.UIFigure,'Montage complete.','Success', 'Icon','success');
%     delete(app.StartupLogTextArea);
%     app.StartupLogTextArea.tx.String = {};

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end