function images = fun(app, new_msg)
  new_msg = ['[' char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')) ']: ' new_msg];
  log_ = app.StartupLogTextArea.Value;
  if ~isempty(log_{1})
    log_ = [ { new_msg }, log_' ];
  else
    log_ = {char(new_msg)};
  end
  if isvalid(app.StartupLogTextArea)
    app.StartupLogTextArea.Value = log_;
  end
  app.ProcessingLogTextArea.Value = log_;
end