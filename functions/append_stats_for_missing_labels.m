function stat_data = fun(stat_data,MeasureTable,stat_name,intensity_stat_flag)
  % Handle missing segments
  if length(stat_data) < height(MeasureTable)
      % Create an example dataset to find out the shape of the output
      % of region props. We will fill in zeros for any missing
      % segments. Missing segments are created when one segment has
      % fewer labels than a previous one and region props doesn't 
      % know so it outputs fewer stats. We will fill in the missing
      % stats with zeros of the correct shape.
      test_intensity_data = zeros(3,3); % make a sample dataset
      test_data = zeros(3,3); % make a sample dataset
      test_data(5)=1; % create one labelled region
      if intensity_stat_flag
        test_stats = regionprops(test_data,test_intensity_data,stat_name); % measure stat
      else
        test_stats = regionprops(test_data,stat_name); % measure stat
      end
      test_stat_data = test_stats.(stat_name); % extract stat
      zeros_for_missing_segments = zeros(size(test_stat_data)); % create zeros with the right shape for this stat
      missing_data_start_pos = length(stat_data)+1; % start index of missing data
      missing_data_end_pos = height(MeasureTable); % end index of missing data
      stat_data(missing_data_start_pos:missing_data_end_pos,:) = zeros_for_missing_segments; % fill in missing data
  end
end