function fun(plugin_name, plugin_num, group_by, summary_stats, measures, save_path, remove_inf, ResultTable)

  % Sanity check that selected measurements are allowed (logical or double)
  for name = measures.names
    name = name{:};
    if ~ismember(class(ResultTable{:,name}),{'logical','double'})
      title_ = 'User Input Error';
      msg = sprintf('User caused an error in ''%s'' plugin. The input measurement ''%s'' that the user has chosen is not a numerical or boolean data. Please deselect this measurement choice in the settings for the ''%s'' analysis.', plugin_name, name, plugin_name);
      f = errordlg(msg,title_);
    end
  end

  % Check if save path is empty, ask the human
  if isempty(save_path)
    save_path = uigetdir('\','Choose a folder to save analysis to');
  end
  if isempty(save_path)
      save_path = '';
  end
  if save_path == 0 
    return
  end

  % Convert pretty names to short names accepted by grpstats function
  name_map = containers.Map;
  name_map('Mean') = 'mean';
  name_map('Median') = 'median';
  name_map('Mode') = 'mode';
  name_map('Minimum') = 'min';
  name_map('Maximum') = 'max';
  name_map('Range') = 'range';
  name_map('Standard error of the mean') = 'sem';
  name_map('Standard deviation') = 'std';
  name_map('Variance') = 'var';
  name_map('95% confidence interval for the mean') = 'meanci';
  name_map('95% prediction interval for a new observation') = 'predci';
  summary_stats_short = {};
  for stat_name = summary_stats
    summary_stats_short{length(summary_stats_short)+1} = name_map(stat_name{:});
  end

  if remove_inf
    inf_row_idx = find(ResultTable{:,measures.names}==Inf);
    ResultTable(inf_row_idx,:)=[];
  end

  % Calculate group stats
  GroupStatsTable = grpstats(ResultTable,group_by.names,summary_stats_short,'DataVars',measures.names);

  %% Save table
  date_str = datestr(now,'yyyymmddTHHMMSS');
  safe_save_path = sprintf('%s_group_stats.csv', date_str); % add date string to avoid overwritting and busy permission denied errors
  full_path = fullfile(save_path,safe_save_path);
  writetable(GroupStatsTable,full_path,'WriteRowNames',true);

end