function img = func(app, img_path)
  if ~exist(img_path) % If the file doesn't exist warn user
    msg = sprintf('Could not find the image file at location: %s',img_path);
    uialert(app.UIFigure,msg,'File Not Found', 'Icon','error');
    error(msg);
  end

  [filepath,name,ext] = fileparts(img_path);
  if isvalid(app.StartupLogTextArea.tx) == 1
    msg = sprintf('Loading image %s', [name ext]);
    if app.CheckBox_Parallel.Value && app.processing_running
        disp(msg)
%         send(app.ProcessingLogQueue, msg);
    else
      app.log_processing_message(app, msg);
    end
  end

  img = imread(img_path);
end
