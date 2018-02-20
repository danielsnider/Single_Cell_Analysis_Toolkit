function uniq_chan_names = fun(app)
  uniq_chan_names = {};
  for plate_num=1:length(app.plates)
    metadata = app.plates(plate_num).metadata;
    if isfield(metadata,'Ch1')
      uniq_chan_names{length(uniq_chan_names)+1} = metadata.Ch1;
    end
    if isfield(metadata,'Ch2')
      uniq_chan_names{length(uniq_chan_names)+1} = metadata.Ch2;
    end
    if isfield(metadata,'Ch3')
      uniq_chan_names{length(uniq_chan_names)+1} = metadata.Ch3;
    end
    if isfield(metadata,'Ch4')
      uniq_chan_names{length(uniq_chan_names)+1} = metadata.Ch4;
    end
  end
  uniq_chan_names = unique(uniq_chan_names,'stable');
end