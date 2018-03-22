function images = fun(app, new_msg)
  new_msg = ['[' char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')) ']: ' new_msg];
  if isstruct(app.StartupLogTextArea)
%     log_ = app.StartupLogTextArea.Value;
    log_ = app.StartupLogTextArea.tx.String;
  else
    log_ = app.ProcessingLogTextArea.Value;
  end
  if ~isempty(log_)
    log_ = [ { new_msg }, log_' ];
  else
    log_ = {char(new_msg)};
  end
  if isstruct(app.StartupLogTextArea)
%     app.StartupLogTextArea.Value = log_;
    set(app.StartupLogTextArea.tx,'string',log_)
  end
  app.ProcessingLogTextArea.Value = log_;
  set(app.StartupLogTextArea.tx,'string',log_)
end