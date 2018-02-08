function fun(app)
  if ~any(ismember(fields(app),'display'))
    return
  end
  if ~isfield(app.display, 'channel')
    return
  end
  % Delete UI components that were there before
  for chan_num=1:length(app.display.channel)    
      delete(app.display.channel{chan_num}.checkbox);
      delete(app.display.channel{chan_num}.label);
      delete(app.display.channel{chan_num}.min_slider);
      delete(app.display.channel{chan_num}.max_slider);
      delete(app.display.channel{chan_num}.min_label);
      delete(app.display.channel{chan_num}.max_label);
      delete(app.display.channel{chan_num}.color_picker);
      delete(app.display.channel{chan_num}.focus);
  end
  app.display.channel = {};
end