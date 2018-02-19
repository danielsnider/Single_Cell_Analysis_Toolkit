function fun(app, createCallbackFcn)
  try
    if ~isempty(app.ChooseplatemapEditField.Value)
      init_variables(app);
    end

    % Load Daniel and Justin's testing plate maps
      plate_file = 'Z:\Justin_S\Justin_Growth_Rate_Plate_Map_20180129.xlsx';
    plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Ceryl_Nucleolus_Plate_Map_20180129';
    plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Ceryl_Tissue_Plate_Map.xlsx';
    plate_file = 'Z:\Ceryl\MATLAB codes\Single_Cell_Analysis_Toolkit\Ceryl_Tissue_Plate_Map.xlsx';
    plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Camilla_Plate_Map.xlsx';
    if exist(plate_file)
      app.ChooseplatemapEditField.Value = plate_file;
      FileName = ''; % just helps testing
    end
    %   plate_file = 'R:\Justin_S\Justin_Growth_Rate_Plate_Map_20180129.xlsx';
    % if exist(plate_file)
    %   app.ChooseplatemapEditField.Value = plate_file;
    %   FileName = ''; % just helps testing
    % end

    % Browse for path if the testing files don't exist
    if isempty(app.ChooseplatemapEditField.Value)
      [FileName,PathName,FilterIndex] = uigetfile('*','Pick a plate map (.xlsx) or saved state (.mat)');
      if ~FileName
         return
      end
      app.ChooseplatemapEditField.Value = [PathName FileName];
    end

    % Display log
    app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [126,651,650,105]);
    app.log_processing_message(app, 'Starting...');
    pause(0.1); % enough time for the log text area to appear on screen

    % Load plate info
    if strfind(FileName,'.mat')
      load(app.ChooseplatemapEditField.Value);
      app.plates = saved_app.plates;
    else
      app.plates = parse_platemap(app.ChooseplatemapEditField.Value);
    end

    % Draw Plates
    draw_input_data(app, createCallbackFcn);

   
    % Parse image files (can be slow!)
    parse_image_names(app);

    % Load saved state
    if strfind(FileName,'.mat')
      load_saved_state(app,saved_app,createCallbackFcn);
    end

    % Initialize Display Tab
    draw_display(app);

    % Process one image
    start_processing_of_one_image(app);
    
    % Load the first image into the app!
    update_figure(app);

    % Delete log
    delete(app.StartupLogTextArea);

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end