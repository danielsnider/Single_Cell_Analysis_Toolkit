function stat_data = fun(stat_data,MeasureTable,stat_name,intensity_stat_flag, flag_3d)
  % Handle missing segments
  if length(stat_data) < height(MeasureTable)
      % Create an example dataset to find out the shape of the output
      % of region props. We will fill in nan or zeros for any missing
      % segments. Missing segments are created when one segment has
      % fewer labels than a previous one and region props doesn't 
      % know so it outputs fewer stats. We will fill in the missing
      % stats with nan or zeros of the correct shape.
      test_intensity_data = nan(3,3); % make a sample dataset
      test_data = zeros(3,3); % make a sample dataset
      test_data(5)=1; % create one labelled region
      if intensity_stat_flag & ~flag_3d
        test_stats = regionprops(test_data,test_intensity_data,stat_name); % measure stat
      elseif intensity_stat_flag & flag_3d
        test_stats = regionprops3(test_data,test_intensity_data,stat_name); % measure stat
      elseif ~intensity_stat_flag & flag_3d
        test_stats = regionprops3(test_data,stat_name); % measure stat
      elseif ~intensity_stat_flag & ~flag_3d
        test_stats = regionprops(test_data,stat_name); % measure stat
      end
      test_stat_data = test_stats.(stat_name); % extract stat
      if iscell(test_stat_data)
        missing_data = cell(1); % fill cells with empty cell
      elseif strcmp(stat_name,{'Area', 'ConvexArea', 'EquivDiameter', 'Perimeter','Volume', 'ConvexVolume', 'PrincipalAxisLength', 'SurfaceArea'})
        missing_data = zeros(size(test_stat_data)); % create zeros with the right shape for this stat
      else
        missing_data = NaN; % create nan with the right shape for this stat, any shape will do
      end
      missing_data_start_pos = length(stat_data)+1; % start index of missing data
      missing_data_end_pos = height(MeasureTable); % end index of missing data
      stat_data(missing_data_start_pos:missing_data_end_pos,:) = missing_data; % fill in missing data
  end
end