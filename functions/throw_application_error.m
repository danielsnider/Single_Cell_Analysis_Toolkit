function throw_application_error(app,msg,title)
  busy_state_change(app,'not busy');
  if isvalid(app.progressdlg)
    close(app.progressdlg)
  end
  uialert(app.UIFigure,msg,title, 'Icon','error');
  msgID = 'APP:ApplicationError';
  ME = MException(msgID,msg);
  causeException = MException(msgID,msg);
  ME = addCause(ME,causeException);
  throw(ME);
end