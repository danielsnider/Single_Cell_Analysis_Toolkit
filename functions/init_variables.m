
function fun(app)

  % Delete input data plates
  if isprop(app, 'input_data')
    if isfield(app.input_data, 'tabgp')
      delete(app.input_data.tabgp);
    end
  end

  delete_display_segments(app);
  delete_display_channels(app);
  if any(ismember(fields(app),'preprocess_tabgp'))
    delete(app.preprocess_tabgp);
    app.preprocess_tabgp = [];
    app.preprocess = [];
  end
  if any(ismember(fields(app),'segment_tabgp'))
    delete(app.segment_tabgp);
    app.segment_tabgp = [];
    app.segment = [];
  end
  if any(ismember(fields(app),'measure_tabgp'))
    delete(app.measure_tabgp);
    app.measure_tabgp = [];
    app.measure = [];
  end
  if any(ismember(fields(app),'analyze_tabgp'))
    delete(app.analyze_tabgp);
    app.analyze_tabgp = [];
    app.analyze = [];
  end


  app.input_data = {};
  app.plates = {};
  app.segment = {};
  app.segment_tabgp = [];
  app.display = {};
  app.display.segment = {};
  app.display.channel = {};
  app.display.channel_override = 0;
  app.measure = {};
  app.measure_tabgp = [];
  app.measure_overlay_color = [0 1 0];
  app.analyze = {};
  app.analyze_tabgp = [];

  app.Button_RunAllAnalysis.Visible = 'off';
  app.Button_ViewMeasurements.Visible = 'off';
  app.Button_ExportMeasurements.Visible = 'off';
  app.Button_ViewFilteredData.Visible = 'off';
  app.Button_ViewOverlaidMeasurements.Visible = 'off';

  app.progressdlg = uiprogressdlg(app.UIFigure,'Title','','Message', '');
  assignin('base','app_progressdlg',app.progressdlg); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way
  close(app.progressdlg);

  app.ExperimentDropDown.Items = {};
  app.PlateDropDown.Items = {};
  %app.PlateDropDown.Value;

  app.FiltersTextArea.UserData.LastValue = {''};
  app.ProcessingLogTextArea.Value = {''};

  app.log_processing_message = @log_processing_message;

  app.PrimarySegmentDropDown.Items = {};
  app.PrimarySegmentDropDown.ItemsData = [];

  app.ChooseplatemapEditField.Value = '';


  %% Measure Tab
  app.DisplayMeasureCheckBox.Value = false;
  app.DisplayMeasureDropDown.Items = {};
  app.RemoveSecondarySegments_CheckBox.Enable = false;
  app.RemovePrimarySegments_CheckBox.Enable = false;
  app.RemovePrimarySegmentsOutside.Enable = false;

  % Set number of parallel workers based on amount of available system memory or cpus
  [user,sys] = memory;
  avail_mem_GiB = sys.PhysicalMemory.Available / 1024^3;
  total_mem_GiB = sys.PhysicalMemory.Total / 1024^3;
  GiB_required_per_worker = 4;
  worker_count_by_memory = floor(total_mem_GiB / GiB_required_per_worker);
  num_cores = feature('numcores');
  num_workers = min([num_cores, worker_count_by_memory]);
  if num_workers == 0 
    num_workers = 1;
  end
  app.ParallelWorkersField.Value = num_workers;

  busy_state_change(app,'not busy');
end