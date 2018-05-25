function throw_application_error(app,msg)
  busy_state_change(app,'not busy');
  if isvalid(app.progressdlg)
    close(app.progressdlg)
  end
  uialert(app.UIFigure,msg,'Measurement Result Length Mismatch', 'Icon','error');
  msgID = 'APP:ApplicationError';
  ME = MException(msgID,msg);
  causeException = MException(msgID,msg);
  ME = addCause(ME,causeException);
  throw(ME);
end