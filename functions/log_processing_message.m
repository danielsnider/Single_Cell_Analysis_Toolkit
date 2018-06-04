function images = fun(app, new_msg)
    MAX_LOG_SIZE = 500; % lines

    new_msg = ['[' char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')) ']: ' new_msg];
    disp(new_msg);
    if isstruct(app.StartupLogTextArea)
        %     log_ = app.StartupLogTextArea.Value;
        % Check to see if log window is still open, otherwise create a new
        % log window
        if isvalid(app.StartupLogTextArea.tx) == 1
            log_ = app.StartupLogTextArea.tx.String;
        else
            app.StartupLogTextArea = txt_update;
            log_ = app.StartupLogTextArea.tx.String;
        end
    else
        log_ = app.ProcessingLogTextArea.Value;
    end
    if ~isempty(log_)
        log_ = [ { new_msg }, log_' ];
    else
        log_ = {char(new_msg)};
    end
    if length(log_) > MAX_LOG_SIZE
        log_ = log_(1:MAX_LOG_SIZE);
    end
    if isstruct(app.StartupLogTextArea)
        %     app.StartupLogTextArea.Value = log_;
        if isvalid(app.StartupLogTextArea.tx) == 1
            % Assign log message
            set(app.StartupLogTextArea.tx,'string',log_)
        else
            app.StartupLogTextArea = txt_update;
            set(app.StartupLogTextArea.tx,'string',log_)
        end
    end
    app.ProcessingLogTextArea.Value = log_;
    % Assign log message
    try
        if isvalid(app.StartupLogTextArea.tx) == 1
            % Assign log message
            set(app.StartupLogTextArea.tx,'string',log_)
        else
            app.StartupLogTextArea = txt_update;
            set(app.StartupLogTextArea.tx,'string',log_)
        end
    catch
        % If log window is not opened from the start, start up a new log window
        % In the case of user going straight to analysis, log window doesn't get open
        app.StartupLogTextArea = txt_update;
        log_ = app.StartupLogTextArea.tx.String;
        set(app.StartupLogTextArea.tx,'string',log_)
    end
end