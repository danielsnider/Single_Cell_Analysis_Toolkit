function [tableA tableB] = fun(tableA, tableB)
  if isempty(tableA) | isempty(tableB)
    return
  end
  missingA = setdiff(tableB.Properties.VariableNames, tableA.Properties.VariableNames);
  missingB = setdiff(tableA.Properties.VariableNames, tableB.Properties.VariableNames);

  %% Fix tableA
  % Figure out what acceptable default values are to fill in missing data with. NaN for numeric, empty cells, and structs with NaNs
  for col_name=missingA
    col_data = tableB{:,col_name};
    if iscell(col_data)
      col_data=col_data{:};
    end
    if isnumeric(col_data)
      missing_data = NaN;
    elseif iscell(col_data)
      missing_data = cell(1);
    elseif ischar(col_data)
      missing_data = {''};
    elseif isstruct(col_data)
      missing_data = struct();
      for field_name=fields(col_data)'
        missing_data.(field_name{:}) = NaN;
      end
    else
      error(sprintf('Sorry, the measurement with class ''%s'' is missing for some plates. Please report this issue in detail to: https://github.com/danielsnider/Single_Cell_Analysis_Toolkit/issues', class(col_data)));
    end
    tableA{:,col_name{:}} = missing_data;
  end

%% Fix tableB
  % Figure out what acceptable default values are to fill in missing data with. NaN for numeric, empty cells, and structs with NaNs
  for col_name=missingB
    col_data = tableA{:,col_name};
    if iscell(col_data)
      col_data=col_data{:};
    end
    if isnumeric(col_data)
      missing_data = NaN;
    elseif iscell(col_data)
      missing_data = cell(1);
    elseif ischar(col_data)
      missing_data = {''};
    elseif isstruct(col_data)
      missing_data = struct();
      for field_name=fields(col_data)'
        missing_data.(field_name{:}) = NaN;
      end
    else
      error(sprintf('Sorry, the measurement with class ''%s'' is missing for some plates. Please report this issue in detail to: https://github.com/danielsnider/Single_Cell_Analysis_Toolkit/issues', class(col_data)));
    end
    tableB{:,col_name{:}} = missing_data;
  end

  % Old way, only NaNs....
  %tableA = [tableA array2table(nan(height(tableA), numel(missingA)), 'VariableNames', missingA)]; % add missing columns
  %tableB = [tableB array2table(nan(height(tableB), numel(missingB)), 'VariableNames', missingB)]; % add missing columns

end