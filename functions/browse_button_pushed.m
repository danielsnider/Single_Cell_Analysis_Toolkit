function fun(app)
  if ~isempty(app.ChooseplatemapEditField.Value)
    uialert(app.UIFigure,'Sorry, changing plate map is not yet implemented. Please close and re-open this application to change plate map.','Cannot Change Plate Map',...
        'Icon','error');
    return
  end

  % Update
  %[FileName,PathName,FilterIndex] = uigetfile('*');
  %if ~FileName
  %    return
  %end
  %app.ChooseplatemapEditField.Value = [PathName FileName];

  app.ChooseplatemapEditField.Value = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\Camilla_Plate_Map_no_experiments.xlsx';

  %Parse 
  app.plates = parse_platemap(app.ChooseplatemapEditField.Value);
  app.input_data.channel_map = {app.plates.Ch1; app.plates.Ch2; app.plates.Ch3; app.plates.Ch4};
  app.input_data.unique_channels = unique(app.input_data.channel_map);
  app.image_names = [];


  % Draw
  draw_input_data(app, @createCallbackFcn);

  % Display startup log
  %startup_f = uifigure('Color', [.6 .6 .6], 'Position', [412 243 540 510]);
  app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [126,658,614,105]);
  pause(1); % enough time for the log text area to appear on screen

  % Parse More (reading file list can be slow!)
  parse_image_names(app);

  % Delete startup log
  delete(app.StartupLogTextArea);

  % Initialize Display Tab
  draw_display(app);
  update_figure(app);

  % Initialize Segmentation Tab
  add_segment(app, @createCallbackFcn);

  % Initialize Measurements Tab
  add_measure(app, @createCallbackFcn);
  app.PrimarySegmentDropDown.Items = app.segment_names;
end