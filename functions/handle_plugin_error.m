function handle_plugin_error(app,ME,plugin_type,plugin_num)
  % If no cause is attached to the error, this is the first place we're handling it create a uialert, add a cause, and rethrow the error
  if isempty(ME.cause)
    if isstruct(app.StartupLogTextArea)
%       delete(app.StartupLogTextArea);
%         app.StartupLogTextArea.tx.String = {};
    end
    maintainer = app.(plugin_type){plugin_num}.algorithm_info.maintainer;
    algo_name = app.(plugin_type){plugin_num}.tab.Title;
    algo_file = app.(plugin_type){plugin_num}.AlgorithmDropDown.Value;
    msg = sprintf('An error occured in the plugin ''%s.m'' for ''%s''. Please check the error message in the Matlab console. If you are unable fix the error yourself please contact the maintainer of the plugin ''%s'' or report it in detail to: https://github.com/danielsnider/Single_Cell_Analysis_Toolkit/issues', algo_file, algo_name,maintainer);
    Title = sprintf('Plugin Error ''%s.m''',algo_file);
    uialert(app.UIFigure,msg,Title, 'Icon','error');
    msgID = 'APP:PluginError';
    msg = msg;
    causeException = MException(msgID,msg);
    ME = addCause(ME,causeException);
    rethrow(ME)
  else
    rethrow(ME)
  end
end