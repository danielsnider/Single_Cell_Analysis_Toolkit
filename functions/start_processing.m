function fun(app)
  %% Setup
  app.ProgressSlider.Value = 0; % reset progress bar to 0
  ResultTable = [];
  images_to_process = [];

  % Get image names that weren't filtered from all plates
  imgs_to_process = [];
  for plate_num=1:length(app.plates)
    plate=app.plates(plate_num);
    num_channels = length(plate.channels);

    for img_num=1:num_channels:length(app.plates(plate_num).img_files_subset)
      multi_channel_img = {};
      multi_channel_img.channel_nums = plate.channels;
      multi_channel_img.plate_num = plate_num;
      multi_channel_img.chans = [];
      image_file = app.plates(plate_num).img_files_subset(img_num);
      multi_channel_img.row = image_file.row{:};
      multi_channel_img.column = image_file.column{:};
      multi_channel_img.field = image_file.field{:};
      multi_channel_img.timepoint = image_file.timepoint{:};
      multi_channel_img.ImageName = image_file.name;
      for chan_num=[plate.channels]
        image_filename = image_file.name; % ex. r02c02f01p01-ch2sk1fk1fl1.tiff
        if ~strcmp(plate.metadata.ImageNamingScheme, 'Operetta')
          msg = sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "Operetta". Aborting.',plate.metadata.ImageNamingScheme);
          uialert(app.UIFigure,msg,'Unkown image naming scheme', 'Icon','error');
          error(msg);
        end
        image_filename(16) = num2str(chan_num); % change the channel number
        multi_channel_img.chans(chan_num).folder = image_file.folder;
        multi_channel_img.chans(chan_num).name = image_filename;
        multi_channel_img.chans(chan_num).path = [image_file.folder '\' image_filename];
      end
      imgs_to_process = [imgs_to_process; multi_channel_img];
    end
  end

  NumberOfImages = length(imgs_to_process);

  %% Loop over images performing segmentation and measuring
  for current_img_number=1:NumberOfImages
    do_a_loop(app,current_img_number,NumberOfImages,imgs_to_process);
  end
  app.log_processing_message(app, 'DONE.');

  app.ResultTable = ResultTable;
  % Update list of measurements in the display tab
  draw_display_measure_selection(app);

end