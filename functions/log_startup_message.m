function images = fun(app, new_msg)
  app.log_processing_message(app, new_msg); % duplicate to measurement windo
  new_msg = ['[' char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')) ']: ' new_msg];
  log_ = app.StartupLogTextArea.Value;
  if ~isempty(log_{1})
    log_ = [ { new_msg }, log_' ];
  else
    log_ = {char(new_msg)};
  end
  app.StartupLogTextArea.Value = log_;
end