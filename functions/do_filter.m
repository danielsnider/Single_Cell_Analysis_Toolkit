function [Table, num_filtered_rows] = fun(Table, Filter)
  %% EXAMPLE INPUT FILTER:
  % Filter.column = { ...
  %   'SaddlePoint; SaddlePoint < 50', ... % not mitotic
  %   'NArea; NArea > median(NArea)', ...
  %   'NArea; NArea < prctile(NArea,99.9)' , ...
  %   'Row; Row == 1 ' , ...
  %   'Column; Column == 1 ' , ...
  %   'Field; Field == 10 ' , ...
  %   'Time; Time >= 1 ' , ...
  %   'Time; Time <= 10 ' , ...
  % }; 
  % Filter.sort = 'Solidity'; % not mitotic
  % Filter.first = 5;
  % Filter.last = 5;

  num_filtered_rows = [];

  %% Loop over column filters
  if isfield(Filter,'column') && ~isempty(Filter.column)
    for ii=1:length(Filter.column)
      height_before = height(Table);
      column_filter = char(Filter.column(ii));
      if isempty(strtrim(column_filter))
        continue % skip empty
      end
      column_filter_arr = strsplit(column_filter, ';');
      column_name = char(column_filter_arr(1));
      operator = char(column_filter_arr(2));

      % Sanity check
      if ~any(ismember(Table.Properties.VariableNames,column_name))
        warning('[filter_table.m] Cannot filter on column name "%s" because it doesn''t exist', column_name)
        continue
      end

      % Create a variable (ex. NArea) to make possible filters like 'NArea > median(NArea)'
      eval(sprintf('%s = Table.%s;',column_name, column_name)); 

      % Do filter
      do_filter = sprintf('Table(%s,:)', operator);
      fprintf('Doing filter: %s\n', operator)
      Table = eval(do_filter);

      % Store number of rows that were filtered out for each filter
      height_after = height(Table);
      num_filtered_rows = [num_filtered_rows; height_before - height_after];
    end
  end
  
  %% Handle Filter.sort
  if isfield(Filter,'sort') && ~isempty(Filter.sort)
    Table = sortrows(Table,Filter.sort);
  end

  %% Handle Filter.first
  FirstRows = table();
  if isfield(Filter,'first') && ~isempty(Filter.first)
    amount = Filter.first;
    if amount > height(Table)
      amount = height(Table); % Don't go overbounds
    end
    FirstRows = Table(1:amount,:);
  end
  %% Handle Filter.last
  LastRows = table();
  if isfield(Filter,'last') && ~isempty(Filter.last)
    amount = Filter.last-1;
    if amount < height(Table)
        LastRows = Table(end-amount:end,:);
    end
  end
  % Combine  first and last (if required)
  if (isfield(Filter,'first') && ~isempty(Filter.first)) | (isfield(Filter,'last') && ~isempty(Filter.last))
    Table = [FirstRows; LastRows];
  end

end
