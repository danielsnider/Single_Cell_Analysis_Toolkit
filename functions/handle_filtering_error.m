function fun(app,ME)
  % If no cause is attached to the error, this is the first place we're handling it create a uialert, add a cause, and rethrow the error
  if isempty(ME.cause)
    if isstruct(app.StartupLogTextArea)
%       delete(app.StartupLogTextArea);
%     	app.StartupLogTextArea.tx.String = {};
    end
    error_msg = getReport(ME,'extended','hyperlinks','off');
    msg = sprintf('Sorry, filtering could not complete. Perhaps you have entered an incorrect filter or perhaps there is a bug. See the error below. If you are unable fix the error yourself please report it in detail to: https://github.com/danielsnider/Single_Cell_Analysis_Toolkit/issues\n\nThe error was:\n\n%s',error_msg);
    uialert(app.UIFigure,msg,'Filter Error', 'Icon','warn');
    msgID = 'APP:FilterError';
    msg = msg;
    causeException = MException(msgID,msg);
    ME = addCause(ME,causeException);

    busy_state_change(app,'not busy');

    if isprop(app, 'progressdlg') && isvalid(app.progressdlg)
      close(app.progressdlg)
    end

    rethrow(ME)
  else
    rethrow(ME)
  end
end