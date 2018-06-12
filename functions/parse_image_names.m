function fun(app)
  % images = {'images/example_cells/r02c02f01p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch4sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch4sk1fk1fl1.tiff'};

  for plate_num=1:length(app.plates)
    img_dir = app.plates(plate_num).metadata.ImageDir;
    naming_scheme = app.plates(plate_num).metadata.ImageFileFormat;

    msg = sprintf('Loading image names for plate %i...', plate_num);
    app.log_processing_message(app, msg);

    default_colors = [...
      0 1 0;
      1 0 0;
      0 0 1;
      1 1 0;
      0 1 1;
      1 0 1; % limitation introduced here on the number of channels
    ];

    % Handle different supported cases
    if strcmp(naming_scheme, 'OperettaSplitTiffs')
      parse_input_structure_OperettaSplitTiffs(app, plate_num);

      default_colors = [...
        1 0 0;
        0 1 0;
        0 0 1;
        1 1 0;
        0 1 1;
        1 0 1; % limitation introduced here on the number of channels
      ];
      app.plates(plate_num).supports_3D = false;

    elseif strcmp(naming_scheme, 'ZeissSplitTiffs')
      parse_input_structure_ZeissSplitTiffs(app, plate_num);
      app.plates(plate_num).supports_3D = false;

    elseif strcmp(naming_scheme, 'SingleChannelFiles')
      parse_input_structure_SingleChannelFiles(app, plate_num);
      app.plates(plate_num).supports_3D = false;

    elseif ismember(naming_scheme, {'XYZCT-Bio-Format-SingleFile'})
      parse_input_structure_XYZCT_Bio_Formats(app, plate_num);
      app.plates(plate_num).supports_3D = true;

    elseif ismember(naming_scheme, {'XYZC-Bio-Formats'})
      parse_input_structure_XYZC_Bio_Formats(app, plate_num);
      app.plates(plate_num).supports_3D = true;

    elseif ismember(naming_scheme, {'XYZ-Bio-Formats'})
      parse_input_structure_XYZ_Bio_Formats(app, plate_num);
      app.plates(plate_num).supports_3D = true;

    elseif ismember(naming_scheme, {'MultiChannelFiles'})
      parse_input_structure_MultiChannelFiles(app, plate_num);
      app.plates(plate_num).supports_3D = false;
    end

    % Enable by default all channels for display in the figure
    app.plates(plate_num).enabled_channels = logical(app.plates(plate_num).channels);

    % Enable by default full dynamic range of channel intensities for display in the figure
    app.plates(plate_num).channel_max = ones(1,length(app.plates(plate_num).channels))*100;
    app.plates(plate_num).channel_min = zeros(1,length(app.plates(plate_num).channels));

    % Default channels colors for display in the figure
    app.plates(plate_num).channel_colors = default_colors(1:length(app.plates(plate_num).channels),:); % set each channel a default colour;

    % Build a list of channel names per plate in app.input_data.plate.chan_names. Ex. {'DAPI'} {'SE'}
    app.plates(plate_num).chan_names = {};
    for chan_num=[app.plates(plate_num).channels]
      chan_name = getfield(app.plates(plate_num).metadata,['Ch' num2str(chan_num)]);
      app.plates(plate_num).chan_names{chan_num} = chan_name;
    end

    % Update UI with defaults for row, column, etc. filtering values
    changed_FilterInput(app, plate_num);
  end

  % Build list of channel names across all plotes in app.input_data.channel_names. Ex. {'DAPI'} {'SE'}
  app.input_data.channel_names = get_unique_channel_names(app);

end
