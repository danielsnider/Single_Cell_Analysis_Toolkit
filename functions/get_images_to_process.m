function imgs_to_process = fun(app)
  imgs_to_process = [];

  if isvalid(app.StartupLogTextArea)
    msg = sprintf('Checking which images should be processed');
    app.log_processing_message(app, msg);
  end
  
  for plate_num=1:length(app.plates)
    plate=app.plates(plate_num);
    if ~plate.checkbox.Value
      continue % skip if a disabled plate
    end
    num_channels = length(plate.channels);

    if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
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
          if ~strcmp(plate.metadata.ImageFileFormat, 'OperettaSplitTiffs')
            msg = sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "OperettaSplitTiffs". Aborting.',plate.metadata.ImageFileFormat);
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
    elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')
      imgs_to_process = [imgs_to_process; app.plates(plate_num).img_files_subset];
    end
  end
end