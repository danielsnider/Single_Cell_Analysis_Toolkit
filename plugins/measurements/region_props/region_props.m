function MeasureTable = func(stats_per_label, stats_per_channel, segments, imgs)

  MeasureTable = table();

  % Nothing to do if no segments are given
  if exist('segments') && isempty(segments)
    return;
  end
  seg_names = fields(segments);

  % Get channel names if there are any
  if exist('imgs') && ~isempty(imgs)
    chan_names = fields(imgs);
  end


  % Remove special measurements from the stats_per_channel list, these can't be passed to regionprops and will be handled seperately
  TotalIntensity_enabled = find(strcmp(stats_per_channel,'TotalIntensity'));
  if TotalIntensity_enabled
    stats_per_channel(TotalIntensity_enabled) = [];
  end
  GradientMeanIntensity_enabled = find(strcmp(stats_per_channel,'GradientMeanIntensity'));
  if GradientMeanIntensity_enabled
    stats_per_channel(GradientMeanIntensity_enabled) = [];
  end
  GradientTotalIntensity_enabled = find(strcmp(stats_per_channel,'GradientTotalIntensity'));
  if GradientTotalIntensity_enabled
    stats_per_channel(GradientTotalIntensity_enabled) = [];
  end

  % Loop over segments
  for seg_name=seg_names'
    seg_name = seg_name{:};
    seg_data = segments.(seg_name);

    % Calculate shape stats
    if ~isempty(stats_per_label)
      stats = regionprops(seg_data,stats_per_label);
      for stat_num=1:length(stats_per_label)
        stat_name = stats_per_label{stat_num};
        stat_data = cat(1,stats.(stat_name));
        
        % Handle missing segments
        if length(stat_data) < height(MeasureTable)
            % Create an example dataset to find out the shape of the output
            % of region props. We will fill in zeros for any missing
            % segments. Missing segments are created when one segment has
            % fewer labels than a previous one and region props doesn't 
            % know so it outputs fewer stats. We will fill in the missing
            % stats with zeros of the correct shape.
            test_data = zeros(3,3); % make a sample dataset
            test_data(5)=1; % create one labelled region
            test_stats = regionprops(test_data,stat_name); % measure stat
            test_stat_data = test_stats.(stat_name); % extract stat
            zeros_for_missing_segments = zeros(size(test_stat_data)); % create zeros with the right shape for this stat
            missing_data_start_pos = length(stat_data)+1; % start index of missing data
            missing_data_end_pos = height(MeasureTable); % end index of missing data
            stat_data(missing_data_start_pos:missing_data_end_pos) = zeros_for_missing_segments; % fill in missing data
        end
            
        MeasureTable{:,[seg_name '_' stat_name]}=stat_data;
      end
    end

    % Skip image measurements if no images
    if ~exist('imgs') || isempty(imgs)
      continue;
    end
    % Calculate intensity stats for each channel
    for chan_num=1:length(chan_names)
      chan_name = chan_names{chan_num};
      % Calculate total intensity
      if TotalIntensity_enabled
        stats = regionprops(seg_data,imgs.(chan_name),{'Area', 'MeanIntensity'});
        MeasureTable{:,[seg_name '_' chan_name '_TotalIntensity']}=cat(1,stats.MeanIntensity).*cat(1,stats.Area);
      end
      % Calculate intensity stats
      if ~isempty(stats_per_channel)
        stats = regionprops(seg_data,imgs.(chan_name),stats_per_channel);
        for stat_num=1:length(stats_per_channel)
          stat_name = stats_per_channel{stat_num};
          MeasureTable{:,[seg_name '_' chan_name '_' stat_name]}=cat(1,stats.(stat_name));
        end
      end
      % Calculate gradient (std dev) total and mean
      if any([GradientMeanIntensity_enabled, GradientTotalIntensity_enabled])
        gradient_im = imgradient(imgs.(chan_name));
        stats = regionprops(seg_data,gradient_im,{'Area', 'MeanIntensity'});
        MeasureTable{:,[seg_name '_' chan_name '_GradientMeanIntensity']}=cat(1,stats.MeanIntensity);
        MeasureTable{:,[seg_name '_' chan_name '_GradientTotalIntensity']}=cat(1,stats.MeanIntensity).*cat(1,stats.Area);
      end
    end
  end

end