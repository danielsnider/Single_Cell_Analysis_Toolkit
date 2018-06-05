function fun(app)
  if ~istable(app.ResultTable) || isempty(app.ResultTable)
    uialert(app.UIFigure,'You must collect measurements before tracking. See the "Measure" tab.','No Measurements', 'Icon','warn');
    return
  end
  if isempty(app.TrackMeasuresListBox.Value)
    uialert(app.UIFigure,'You must choose measurements before tracking. See the "Choose Measurements" box.','No Measurements Selected', 'Icon','warn');
    return
  end

  % Display log
%   app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
% app.StartupLogTextArea = txt_update;
%   pause(0.1); % enough time for the log text area to appear on screen

  % Logging
  busy_state_change(app,'busy');
  app.log_processing_message(app, 'Starting tracking...');
  if isvalid(app.progressdlg)
    close(app.progressdlg)
  end
  app.progressdlg = uiprogressdlg(app.UIFigure,'Title','Please Wait','Message', 'Tracking Images.', 'Cancelable', 'on');
  assignin('base','app_progressdlg',app.progressdlg); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way


  %% METRIC WEIGHTS
  % Importance of each metric for when calculating composite distances.
  % Higher value is more important.
  % Metrics that don't have a weight setting will be ignored.
  weights = {};
%   for meas_name = app.TrackMeasuresListBox.Value
%     meas_name = meas_name{:};
%     weights.(meas_name) = 1;
%   end
  meas_name = app.TrackMeasuresListBox.Value;
  weights.(meas_name) = 1; % Only one weight limitation
  CentroidName = meas_name; % Only one weight limitation

  % The column in the measurements table that denotes time passing
  % time_column_name = app.TimeColumnDropDown.Value;
  time_column_name = 'timepoint';

  % Loop over images tracking each one
  TrackedTable = table();
  image_names = unique(app.ResultTable.ImageName)';
  num_images = length(image_names);
  count = 0;
  for image_name = image_names
    app.progressdlg.Message = sprintf('Tracking image %d of %d: %s', count, num_images, image_name{:});
    app.progressdlg.Value = count / num_images;
    imageTable = app.ResultTable(ismember(app.ResultTable.ImageName,image_name),:);

    % Delete any info from last time tracking ran
    if any(ismember(imageTable.Properties.VariableNames,'Trace'))
      imageTable.Trace = [];
    end
    if any(ismember(imageTable.Properties.VariableNames,'TraceUsed'))
      imageTable.TraceUsed = [];
    end
    if any(ismember(imageTable.Properties.VariableNames,'TraceShort'))
      imageTable.TraceShort = [];
    end
    if any(ismember(imageTable.Properties.VariableNames,'TraceColor'))
      imageTable.TraceColor = [];
    end

    %% CALC DIFFERENCES BETWEEN FRAMES
    app.log_processing_message(app, 'Measuring differences between frames...');
    [raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(imageTable,weights,time_column_name);

    %% TRACK CELLS
    app.log_processing_message(app, 'Tracking...');
    [imageTable,DiffTable] = cell_tracking_v1_simple(imageTable, composite_differences, time_column_name, CentroidName);
  
    % Store result
    TrackedTable = [TrackedTable; imageTable];
    count = count + 1;
  end
  app.ResultTable = TrackedTable;

  % Get the new results for the objects currently in the display figure, find them by UUID 
  if ~isempty(app.ResultTable_for_display) % there is no display when data was loaded using a .mat
    app.ResultTable_for_display = app.ResultTable(ismember(app.ResultTable.ID,app.ResultTable_for_display.ID),:);
  end

  % Update list of measurements in the analyze tab
  changed_MeasurementNames(app);

  if isvalid(app.progressdlg)
    close(app.progressdlg)
  end
  app.log_processing_message(app, 'Finished tracking.');
  busy_state_change(app,'not busy');

  uialert(app.UIFigure,'Tracking complete.','Success', 'Icon','success');

  
  % Delete log
%   delete(app.StartupLogTextArea);
%     app.StartupLogTextArea.tx.String = {};
end