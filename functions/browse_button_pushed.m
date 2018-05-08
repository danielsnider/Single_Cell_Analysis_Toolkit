function fun(app, createCallbackFcn)
cwp=gcp('nocreate');
if isempty(cwp)
    warning off all
else
    pctRunOnAll warning off all %Turn off Warnings
end
  try
    if ~isempty(app.ChooseplatemapEditField.Value)
      init_variables(app);
    end

    % Load Daniel and Justin's testing plate maps
    plate_file = 'Z:\Justin_S\Justin_Growth_Rate_Plate_Map_20180129.xlsx';
    plate_file = 'R:\Justin_S\Justin_Growth_Rate_Plate_Map_20180129.xlsx';
    % plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Ceryl_Nucleolus_Plate_Map_20180129';
    % plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Ceryl_Tissue_Plate_Map.xlsx';
    % plate_file = 'Z:\Ceryl\MATLAB codes\Single_Cell_Analysis_Toolkit\Ceryl_Tissue_Plate_Map.xlsx';
    % plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Multi_Plate_Map.xlsx';
    % plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Camilla_Plate_Map.xlsx';
    % plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Derrick_Plate_Map.xlsx';
    % plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Derrick_Plate_Map.xlsx';
    plate_file = 'C:\Users\danie\Dropbox\Kafri\Projects\Single_Cell_Analysis_Toolkit\daniel\Laura_Plate_Map_Laptop.xlsx';
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
%     app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
    app.StartupLogTextArea = txt_update;
    app.log_processing_message(app, 'Starting...');
    pause(0.1); % enough time for the log text area to appear on screen

    % Load plate info
    if strfind(FileName,'.mat')
      load(app.ChooseplatemapEditField.Value);
      app.plates = saved_app.plates;
    else
      app.plates = parse_platemap(app.ChooseplatemapEditField.Value);
    end

    %% Assert the name number of metadata fields exists on all plates TODO(Dan): to remove this limitation see file 'append_missing_columns_table_pair.m'
    lengths = [];
    for plate_num=1:length(app.plates)
      lengths = [lengths length(fields(app.plates(plate_num).metadata))];
    end
    if length(unique(lengths))>1
      msg = sprintf('Sorry, there is a limitation that all plates in your platemap must have the same number of metadata fields. Please correct this in your file ''%s'' and try again.', app.ChooseplatemapEditField.Value);
      uialert(app.UIFigure,msg,'Sorry', 'Icon','error');
      % Delete log
%       delete(app.StartupLogTextArea);
%       	app.StartupLogTextArea.tx.String = {};
      return
    end

    % Draw Plates
    draw_input_data(app, createCallbackFcn);

    % Parse image files (can be slow!)
    % uialert(app.UIFigure,'Opening Images can be slow! Click OK to begin.','Opening Images', 'Icon','info');
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
%     delete(app.StartupLogTextArea);
%     app.StartupLogTextArea.tx.String = {};
    app.ProcessingLogTextArea.Value = '';

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end