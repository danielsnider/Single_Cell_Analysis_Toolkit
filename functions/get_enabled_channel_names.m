function chan_names = get_enabled_channel_names(app)
  chan_names = {};
  for plate_num=1:length(app.plates)
    if app.plates(plate_num).checkbox.Value;
      chan_names{length(chan_names)+1}  = app.plates(plate_num).chan_names;
    end
  end
  chan_names = unique(cat(1,chan_names{:}),'stable');
end