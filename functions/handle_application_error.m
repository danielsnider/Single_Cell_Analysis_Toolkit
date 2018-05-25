function handle_application_error(app,ME)
  busy_state_change(app,'not busy');
  if isprop(app, 'progressdlg') && isvalid(app.progressdlg)
    close(app.progressdlg)
  end

  % If no cause is attached to the error, this is the first place we're handling it create a uialert, add a cause, and rethrow the error
  if isempty(ME.cause)
      if ~isnumeric(app.StartupLogTextArea)
          if isstruct(app.StartupLogTextArea)
%               delete(app.StartupLogTextArea);
%               	app.StartupLogTextArea.tx.String = {};
          end
      end
    error_msg = getReport(ME,'extended','hyperlinks','off');
    msg = sprintf('Sorry, an application error occured. Please check the error below for any obvious problems. You may need to restart the application at this time. If the problem persists please report it in detail to: https://github.com/danielsnider/Single_Cell_Analysis_Toolkit/issues\n\nThe error was:\n\n%s',error_msg);
    uialert(app.UIFigure,msg,'Application Error', 'Icon','error');
    msgID = 'APP:ApplicationError';
    msg = msg;
    causeException = MException(msgID,msg);
    ME = addCause(ME,causeException);
    rethrow(ME)
  else
      
    rethrow(ME)
  end
end