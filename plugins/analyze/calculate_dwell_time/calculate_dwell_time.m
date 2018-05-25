function fun(plugin_name, plugin_num, analyze_value, is_less_than, is_greater_than, track_by, save_additional_info, save_path, ResultTable)

  %% Calculate Duration of Contact
  contact_durations = []; % Each value is a length of timepoints for a contact that took place
  in_contact_bool = []; % Each value is whether a pero is in contact or not
  all_trace_pos = [];
  all_additional_info = {};

  contact_durations_per_pero = [];
  for trace_id=unique(ResultTable.(track_by.name), 'stable')'
    trace_pos = ismember(ResultTable.(track_by.name),trace_id);
    TraceTable = ResultTable(trace_pos,:);
    distances = TraceTable.(analyze_value.name);
    is_less_than_in_contact_timepoints = ones(1,length(distances))';
    is_greater_than_in_contact_timepoints = ones(1,length(distances))';
    if is_less_than
      is_less_than_in_contact_timepoints = [distances<is_less_than];
    end
    if is_greater_than
      is_greater_than_in_contact_timepoints = [distances>is_greater_than];
    end
    in_contact_timepoints = is_less_than_in_contact_timepoints & is_greater_than_in_contact_timepoints;
    % Example: in_contact_timepoints                             = [0 1 0 1 1 0 0 1 1 1 0 1 1 0 1 1] 
    % Example after calculation finishes: in_contact_duration    = [0 1 0 1 2 0 0 1 2 3 0 1 2 0 1 2]
    % Example after calculation finishes: contact_durations      = [  1     2         3     2     2]
    in_contact_timepoints=[0; in_contact_timepoints];
    in_contact_duration = [0];
    for i=2:length(in_contact_timepoints)
      if in_contact_timepoints(i)==0
        in_contact_duration(i) = 0;
      else
        in_contact_duration(i) = in_contact_duration(i-1)+1;
        if in_contact_duration(i) == 0 
          in_contact_duration(i) = 1;
        end
      end
    end
    cell_contact_durations = in_contact_duration(imregionalmax(in_contact_duration)); % find [0 1 0 1 2 0 0 1 2 3 0 1 1 0 1 1] -->  [  1     2         3   2     2  ]
    contact_durations = [contact_durations cell_contact_durations];
    
    % Save a piece of additional information about the found contacts
    if ~isequal(save_additional_info,false)
      temp_info = cell(1,length(cell_contact_durations)); % setup cell array
      temp_info(:) = {TraceTable{1,save_additional_info.name}}; % fill with first value for all contacts found for this trace
      all_additional_info = [all_additional_info temp_info]; % store for later use
    end

    in_contact_duration = in_contact_duration(2:end); % remove first item in list because this algorithm only added it to facilitate calculation
    contact_durations_per_pero = [contact_durations_per_pero; in_contact_duration']; % store one data point of length of the seen trace per observed peroxisome, used to save into a CSV 
    in_contact_timepoints = in_contact_timepoints(2:end); % remove first item in list because this algorithm only added it to facilitate calculation
    in_contact_bool = [in_contact_bool in_contact_timepoints'];


     % Get locations of these traces within the T table. The order is important because when we add data back to the table it has to be sorted the same as the table. The table is sorted by timepoint (see create_table_pero_2DResultTable.m) but this function sorts data by Trace. We will correct locations.
    all_trace_pos = [all_trace_pos; find(trace_pos)];

  end

  % Remove 0s we anly want to know trace lengths greater than 0
  if ~isequal(save_additional_info,false)
    all_additional_info(contact_durations==0)=[];
  end
  contact_durations(contact_durations==0)=[];

  %% For adding a stats to table
  % Create an array that contains for each pero at each timepoint how long the contact Consecutive time is.
  % Example before calculation finishes: in_contact_duration    = [0 1 0 1 2 0 0 1 2 3 0 1 2 0 1 2]
  % Example after  calculation finishes: in_contact_duration2   = [0 1 0 2 2 0 0 3 3 3 0 2 2 0 2 2]
  in_contact_duration2 = [];
  in_contact_duration_ = [contact_durations_per_pero' 0];
  for i=fliplr(1:length(in_contact_duration_)-1)
    if in_contact_duration_(i+1) == 0 && in_contact_duration_(i) > 0
      save_num = in_contact_duration_(i);
    end
    if in_contact_duration_(i) == 0
      save_num = 0;
    end
    in_contact_duration2(i) = save_num;
  end

  % Correct data so it is sorted the same way as table T
  in_contact_bool=in_contact_bool(all_trace_pos);
  in_contact_duration2=in_contact_duration2(all_trace_pos);

  %% Add to Consecutive table
  ConsecutiveTable = table();
  ConsecutiveTable.ConsecutiveTime = contact_durations';
  if ~isequal(save_additional_info,false)
    ConsecutiveTable(:,save_additional_info.name) = all_additional_info';
  end

  % Check if empty
  if isempty(ConsecutiveTable)
    title_ = 'No Consecutive Values Found!';
    msg = sprintf('No values were found to be within the range provided by the user. Try collecting more data or loosening the allowed range in the parameter section of the ''%s'' plugin.', plugin_name);
    f = errordlg(msg,title_);
    return
  end

  % Check if save path is empty, ask the human
  if isempty(save_path)
    save_path = uigetdir('\','Choose a folder to save to');
  end
  if isempty(save_path)
      save_path = '';
  end

  %% Save table
  date_str = datestr(now,'yyyymmddTHHMMSS');
  safe_save_path = sprintf('%s_stats.csv', date_str); % add date string to avoid overwritting and busy permission denied errors
  full_path = fullfile(save_path,safe_save_path);
  writetable(ConsecutiveTable,full_path);

  %% Calculate Summary Table
  SummaryTable = table();
  if ~isequal(save_additional_info,false)
    unique_groups = unique(ResultTable{:,save_additional_info.name});
  else
    unique_groups = {'only one group'};
  end
  for group=unique_groups'
    if strcmp(group, 'only one group')
      GroupConsecTable = ConsecutiveTable;
      GroupResultTable = ResultTable;
      group = {'all data'};
    else
      GroupConsecTable = ConsecutiveTable(ismember(ConsecutiveTable{:,save_additional_info.name}, group), 'ConsecutiveTime');
      GroupResultTable = ResultTable(ismember(ResultTable{:,save_additional_info.name}, group), :);
    end

    iterSummaryTable = table();
    iterSummaryTable.tracked_samples = length(unique(GroupResultTable.(track_by.name)));
    iterSummaryTable.total_samples = height(GroupResultTable);
    iterSummaryTable.count_contact = height(GroupConsecTable);
    iterSummaryTable.percentage_contact = height(GroupConsecTable) / length(unique(GroupResultTable.(track_by.name)));
    iterSummaryTable.sum_contact = sum(GroupConsecTable.ConsecutiveTime);
    iterSummaryTable.mean_contact = mean(GroupConsecTable.ConsecutiveTime);
    iterSummaryTable.median_contact = median(GroupConsecTable.ConsecutiveTime);
    iterSummaryTable.mode_contact = mode(GroupConsecTable.ConsecutiveTime);
    range_contact = range(GroupConsecTable.ConsecutiveTime);
    if isempty(range_contact)
        range_contact = NaN;
    end
    iterSummaryTable.range_contact = range_contact;
    iterSummaryTable.std_dev_contact = std(GroupConsecTable.ConsecutiveTime);
    min_contact = min(GroupConsecTable.ConsecutiveTime);
    if isempty(min_contact)
      min_contact = NaN;
    end
    iterSummaryTable.min_contact = min_contact;
    max_contact = max(GroupConsecTable.ConsecutiveTime);
    if isempty(max_contact)
      max_contact = NaN;
    end
    iterSummaryTable.max_contact = max_contact;
    iterSummaryTable.Properties.RowNames = group;

    SummaryTable = [SummaryTable; iterSummaryTable];
  end

  summary_save_path = sprintf('%s_summary.csv', date_str); % add date string to avoid overwritting and busy permission denied errors
  full_path = fullfile(save_path,summary_save_path);
  writetable(SummaryTable,full_path,'WriteRowNames',true);

end