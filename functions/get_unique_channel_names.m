function uniq_chan_names = fun(app)
  uniq_chan_names = {};
  for plate_num=1:length(app.plates)
    metadata = app.plates(plate_num).metadata;
    uniq_chan_names{length(uniq_chan_names)+1} = metadata.Ch1;
    uniq_chan_names{length(uniq_chan_names)+1} = metadata.Ch2;
    uniq_chan_names{length(uniq_chan_names)+1} = metadata.Ch3;
    uniq_chan_names{length(uniq_chan_names)+1} = metadata.Ch4;
  end
  uniq_chan_names = unique(uniq_chan_names);
end