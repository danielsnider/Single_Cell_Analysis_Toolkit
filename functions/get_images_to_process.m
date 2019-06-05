function imgs_to_process = fun(app)
  imgs_to_process = [];

  if isstruct(app.StartupLogTextArea)
    msg = sprintf('Checking which images should be processed');
    app.log_processing_message(app, msg);
  end
  
  for plate_num=1:length(app.plates)
    plate=app.plates(plate_num);
    if ~plate.checkbox.Value
      continue % skip if a disabled plate
    end
    num_channels = length(plate.channels);
      
    if ismember(app.plates(plate_num).metadata.ImageFileFormat, {'ZeissSplitTiffs','SingleChannelFiles','XYZCT-Bio-Format-SingleFile', 'XYZTC-Bio-Format-SingleFile','MultiChannelFiles','XYZ-Bio-Formats','XYZC-Bio-Formats','OperettaSplitTiffs','IncuCyte', 'CellomicsTiffs'})
      imgs_to_process = [imgs_to_process; app.plates(plate_num).img_files_subset];
    end
  end
end