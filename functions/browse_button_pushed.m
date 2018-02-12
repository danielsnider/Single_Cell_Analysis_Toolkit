function fun(app, createCallbackFcn)
  if ~isempty(app.ChooseplatemapEditField.Value)
    % uialert(app.UIFigure,'Sorry, changing plate map is not yet implemented. Please close and re-open this application to change plate map.','Cannot Change Plate Map',...
    %     'Icon','error');
    % return
    init_variables(app);
  end



  % Load Daniel and Justin's testing plate maps
  % plate_file = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Camilla_Plate_Map.xlsx';
  % if exist(plate_file)
  %   app.ChooseplatemapEditField.Value = plate_file;
  %   FileName = ''; % just helps testing
  % end
  % plate_file = 'R:\Justin_S\Ceryl_Nucleolus_Plate_Map_20180129.xlsx';
  % if exist(plate_file)
  %   app.ChooseplatemapEditField.Value = plate_file;
  %   FileName = ''; % just helps testing
  % end

  % Browse for path if the testing files don't exist
  if isempty(app.ChooseplatemapEditField.Value)
    [FileName,PathName,FilterIndex] = uigetfile('*');
    if ~FileName
       return
    end
    app.ChooseplatemapEditField.Value = [PathName FileName];
  end

  % Load plate info
  if strfind(FileName,'.mat')
    load(app.ChooseplatemapEditField.Value);
    app.plates = saved_app.plates;
  else
    app.plates = parse_platemap(app.ChooseplatemapEditField.Value);

  end

  % Draw Plates
  draw_input_data(app, createCallbackFcn);

  % Display startup log
  app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [126,651,614,105]);
  pause(1); % enough time for the log text area to appear on screen
  % Parse image files (can be slow!)
  parse_image_names(app);
  % Delete startup log
  delete(app.StartupLogTextArea);

  if strfind(FileName,'.mat')
    load_saved_state(app,saved_app,createCallbackFcn);
  else
    % Initialize Segmentation Tab
    add_segment(app, createCallbackFcn);

    % Initialize Measurements Tab
    add_measure(app, createCallbackFcn);
  end

  % Initialize Display Tab
  draw_display(app);
  
  % Load the first image into the app!
  update_figure(app);

  % Primary Segment Dropdown
  app.PrimarySegmentDropDown.Items = app.segment_names;


end