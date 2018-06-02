function MeasureTable = func(plugin_name, plugin_num, segments, stats_per_label, imgs, stats_per_channel)
  % TODO: Known issue: if the number of labels varies between segments you'll end up with NaNs for missing things. The core issue is that this plugin assumes there to be the same number of segments per segment channel.

  MeasureTable = table();

  % Nothing to do if no segments are given
  if exist('segments') && isempty(segments)
    return;
  end

  % Get channel names if there are any
  if exist('imgs') && ~isempty(imgs)
    chan_names = fields(imgs);
  end

  % Remove special measurements from the stats_per_channel list, these can't be passed to regionprops and will be handled seperately
  TotalIntensity_enabled = find(strcmp(stats_per_channel,'TotalIntensity'));
  if TotalIntensity_enabled
    stats_per_channel(TotalIntensity_enabled) = [];
  end
  GradientMeanIntensity_enabled = find(strcmp(stats_per_channel,'GradientMeanIntensity (2D only)'));
  if GradientMeanIntensity_enabled
    stats_per_channel(GradientMeanIntensity_enabled) = [];
  end
  GradientTotalIntensity_enabled = find(strcmp(stats_per_channel,'GradientTotalIntensity (2D only)'));
  if GradientTotalIntensity_enabled
    stats_per_channel(GradientTotalIntensity_enabled) = [];
  end

  % Reorder segment names so that the one with the most segments is first, this way the work-around for region props giving different numbers of stats and putting them in the same table works 
  seg_names = fields(segments);
  seg_lengths = [];
  for seg_name=fields(segments)'
    seg_data = segments.(seg_name{:});
    seg_lengths = [seg_lengths max(seg_data(:))];
  end
  [sorted_,segment_max_to_min_order] = sort(seg_lengths,'descend');


  % Loop over segments
  for seg_num=segment_max_to_min_order
    seg_name = seg_names{seg_num};
    seg_data = segments.(seg_name);
    
    if max(seg_data(:))==0
        continue % skip because there are no segments to measure
    end

    % only some stats are supported for 3D images
    stats_per_label_ = {};
    if ndims(seg_data) == 3
      % Filter out 2D stats
      for stat_name=stats_per_label
        stat_name = stat_name{:};
        if ~contains(stat_name,' (2D only)')
          stats_per_label_{length(stats_per_label_)+1} = stat_name;
        end
      end
    elseif ndims(seg_data) == 2
      % Rename stats to remove ' (2D only)' string so that regionprops accepts it
      for stat_name=stats_per_label
        stat_name = stat_name{:};
        if contains(stat_name,' (2D only)')
          stat_name = stat_name(1:end-10); % remove trailing ' (2D only)'
        end
        stats_per_label_{length(stats_per_label_)+1} = stat_name;
      end
    end

    % Calculate shape stats
    if ~isempty(stats_per_label_)
      stats = regionprops(seg_data,stats_per_label_);
      for stat_num=1:length(stats_per_label_)
        stat_name = stats_per_label_{stat_num};
        stat_data = cat(1,stats.(stat_name));
        stat_data = append_stats_for_missing_labels(stat_data, MeasureTable, stat_name, false, false);
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
        stat_data = cat(1,stats.MeanIntensity).*cat(1,stats.Area);
        stat_data = append_stats_for_missing_labels(stat_data, MeasureTable, stat_name, true, false);
        MeasureTable{:,[seg_name '_' chan_name '_TotalIntensity']}=stat_data;
      end
      % Calculate intensity stats
      if ~isempty(stats_per_channel)
        stats = regionprops(seg_data,imgs.(chan_name),stats_per_channel);
        for stat_num=1:length(stats_per_channel)
          stat_name = stats_per_channel{stat_num};
          stat_data = cat(1,stats.(stat_name));
          stat_data = append_stats_for_missing_labels(stat_data, MeasureTable, stat_name, true, false);
          MeasureTable{:,[seg_name '_' chan_name '_' stat_name]}=stat_data;
        end
      end
      % Calculate gradient (std dev) total and mean
      if ndims(seg_data) == 2 & any([GradientMeanIntensity_enabled, GradientTotalIntensity_enabled])
        gradient_im = imgradient(imgs.(chan_name));
        stats = regionprops(seg_data,gradient_im,{'Area', 'MeanIntensity'});
        stat_data = cat(1,stats.MeanIntensity);
        stat_data = append_stats_for_missing_labels(stat_data, MeasureTable, 'Area', true, false);
        MeasureTable{:,[seg_name '_' chan_name '_GradientMeanIntensity']}=stat_data;
        stat_data = cat(1,stats.MeanIntensity).*cat(1,stats.Area);
        stat_data = append_stats_for_missing_labels(stat_data, MeasureTable, 'Area', true, false);
        MeasureTable{:,[seg_name '_' chan_name '_GradientTotalIntensity']}=stat_data;
      end
    end
  end

end