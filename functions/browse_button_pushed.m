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
    % plate_file = 'C:\Users\danie\Dropbox\Kafri\Projects\Single_Cell_Analysis_Toolkit\daniel\Derrick_Plate_Map_Laptop_2D_multi_chan.xlsx';
    %     if exist(plate_file)
    %       app.ChooseplatemapEditField.Value = plate_file;
    %       FileName = ''; % just helps testing
    %     end
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

    busy_state_change(app,'busy');

    msg = sprintf('Loading plate map');
    app.progressdlg2 = uiprogressdlg(app.UIFigure,'Title','Please Wait',...
    'Message',msg);
    assignin('base','app_progressdlg2',app.progressdlg2); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way

    % Display log
%     app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
    app.StartupLogTextArea = txt_update;
    app.log_processing_message(app, sprintf('Loading plate map %s', app.ChooseplatemapEditField.Value));
    app.progressdlg2.Message = sprintf('%s\n%s',msg,'Parsing plate map...');
    app.progressdlg2.Value = 0.1;
    pause(0.1); % enough time for the log text area to appear on screen

    % Load plate info
    if strfind(FileName,'.mat')
      load(app.ChooseplatemapEditField.Value);
      app.plates = saved_app.plates;
    else
      [plates app_parameters] = parse_platemap(app.ChooseplatemapEditField.Value);
      app.plates = plates;
    end

      % Image Naming Scheme Supported Check
    for plate_num=1:length(app.plates)
      naming_scheme = app.plates(plate_num).metadata.ImageFileFormat;
      known_naming_schemes = {'OperettaSplitTiffs','ZeissSplitTiffs', 'SingleChannelFiles', 'XYZCT-Bio-Format-SingleFile','MultiChannelFiles','XYZ-Bio-Formats','XYZC-Bio-Formats'};
      known_naming_schemes_str=cellfun(@(x) [x ', '],known_naming_schemes,'UniformOutput',false);
      known_naming_schemes_str=[known_naming_schemes_str{:}];
      known_naming_schemes_str=known_naming_schemes_str(1:end-2);

      if ~ismember(naming_scheme, known_naming_schemes)
        msg = sprintf('Unkown image file type "%s". Please check your your plate map spreadsheet to correct this error. The allowed values are: %s',naming_scheme,known_naming_schemes_str);
        title_ = 'User Error - Unknown Image File Format';
        throw_application_error(app,msg,title_)
      end
    end

    %% Assert the name number of metadata fields exists on all plates TODO(Dan): to remove this limitation see file 'append_missing_columns_table_pair.m'
    lengths = [];
    for plate_num=1:length(app.plates)
      lengths = [lengths length(fields(app.plates(plate_num).metadata))];
    end
    if length(unique(lengths))>1
      msg = sprintf('Sorry, there is a limitation that all plates in your platemap must have the same number of metadata fields. Please correct this in your file ''%s'' and try again.', app.ChooseplatemapEditField.Value);
      uialert(app.UIFigure,msg,'Sorry', 'Icon','error');
      return
    end

    % Draw Plates
    app.progressdlg2.Message = sprintf('%s\n%s',msg,'Drawing input UI...');
    app.progressdlg2.Value = 0.15;
    draw_input_data(app, createCallbackFcn);

    % Parse image files (can be slow!)
    app.progressdlg2.Message = sprintf('%s\n%s',msg,'Scanning image files (can be slow!)...');
    app.progressdlg2.Value = 0.3;
    parse_image_names(app);

    % Load saved state
    if strfind(FileName,'.mat')
      load_saved_state(app,saved_app,createCallbackFcn);
    end

    % Initialize Display Tab
    app.progressdlg2.Message = sprintf('%s\n%s',msg,'Drawing display UI...');
    app.progressdlg2.Value = 0.5;
    draw_display(app);

    % Process one image
    app.progressdlg2.Message = sprintf('%s\n%s',msg,'Processing first image...');
    app.progressdlg2.Value = 0.65;
    start_processing_of_one_image(app);
    
    % Load the first image into the app!
    app.progressdlg2.Message = sprintf('%s\n%s',msg,'Displaying first image...');
    app.progressdlg2.Value = 0.8;
    update_figure(app);

    % Load parameters from XSLS into app
    if exist('app_parameters') && ~isempty(app_parameters)
      app.progressdlg2.Message = sprintf('%s\n%s',msg,'Loading saved parameters...');
      app.progressdlg2.Value = 0.9;
      load_app_parameters(app, app_parameters, createCallbackFcn);
    end

    % Finished
    app.progressdlg2.Message = sprintf('%s\n%s',msg,'Finished.');
    app.progressdlg2.Value = 1;
    close(app.progressdlg2);
    app.log_processing_message(app, 'Ready.');
    busy_state_change(app,'not busy');
    % uialert(app.UIFigure,'Loading complete.','Ready', 'Icon','success');

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end