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
    num_imgs_to_process = length(imgs_to_process);
    count = 1;

    % Display log
    msg = 'Starting Montage.';
    app.log_processing_message(app, msg);
    app.progressdlg2 = uiprogressdlg(app.UIFigure,'Title','Please Wait', 'Message',msg, 'Cancelable', 'on');
    assignin('base','app_progressdlg2',app.progressdlg2); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way


    for img=imgs_to_process'
      if app.progressdlg2.CancelRequested
        break
      end
      plate_num = img.plate_num;
      if plate_num ~= app.PlateDropDown.Value
        continue % only operate on the currently selected plate
      end


      msg = sprintf('Processing montage for image %d of %d: %s', count, num_imgs_to_process, img.ImageName);
      app.progressdlg2.Message = msg;
      app.progressdlg2.Value = count / num_imgs_to_process;
      app.log_processing_message(app, msg);

      if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')||strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
        app.RowDropDown.Value = img.row;
        app.ColumnDropDown.Value = img.column;
        app.FieldDropDown.Value = img.field;
        app.TimepointDropDown.Value = img.timepoint;
        exp_val = complex(img.row,-img.column);
        if ismember(exp_val, app.ExperimentDropDown.ItemsData)
          app.ExperimentDropDown.Value = exp_val;
        end
        filename = sprintf('%s/montage_%s_plate%d_row%d_column%d_field%d_timepoint%d.png', save_dir, date_str, plate_num, img.row, img.column, img.field, img.timepoint);

      elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'ZeissSplitTiffs','SingleChannelFiles', 'MultiChannelFiles'})
        app.ExperimentDropDown.Value = img.experiment_num;
        filename = sprintf('%s/montage_%s_plate%d_%s.png', save_dir, date_str, plate_num, img.experiment);
      end
    
      
      % Need lines 57, 58 and 60
      
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
    app.log_processing_message(app, 'Finished montage.');
    close(app.progressdlg2);
    uialert(app.UIFigure,'Montage complete.','Success', 'Icon','success');

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end