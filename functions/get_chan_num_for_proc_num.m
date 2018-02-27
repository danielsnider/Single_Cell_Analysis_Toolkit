function chan_num = fun(app, proc_num)
  plate_num = app.PlateDropDown.Value;
  proc_chan_name = app.preprocess{proc_num}.ChannelDropDown.Value;
  
  chan_num = NaN;

  % Convert channel name to it's number in the plate
  for chan_num = 1:length(app.plates(plate_num).chan_names)
    if strcmp(proc_chan_name, app.plates(plate_num).chan_names(chan_num));
      break % found it, the chan_num will be returned
    end
  end

end