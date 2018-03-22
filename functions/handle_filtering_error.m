function fun(app,ME)
  % If no cause is attached to the error, this is the first place we're handling it create a uialert, add a cause, and rethrow the error
  if isempty(ME.cause)
    if isstruct(app.StartupLogTextArea)
%       delete(app.StartupLogTextArea);
%     	app.StartupLogTextArea.tx.String = {};
    end
    msg = sprintf('Sorry, filtering could not complete. Perhaps you have entered an incorrect filter or perhaps there is a bug. See the Matlab console for the full error message. If you are unable fix the error yourself please report it in detail to: https://github.com/danielsnider/Single_Cell_Analysis_Toolkit/issues');
    uialert(app.UIFigure,msg,'Filter Error', 'Icon','warn');
    msgID = 'APP:FilterError';
    msg = msg;
    causeException = MException(msgID,msg);
    ME = addCause(ME,causeException);
    rethrow(ME)
  else
    rethrow(ME)
  end
end