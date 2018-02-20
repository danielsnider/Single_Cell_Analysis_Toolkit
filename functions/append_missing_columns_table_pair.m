function [tableA tableB] = fun(tableA, tableB)
  if isempty(tableA) | isempty(tableB)
    return
  end
  missingA = setdiff(tableB.Properties.VariableNames, tableA.Properties.VariableNames);
  missingB = setdiff(tableA.Properties.VariableNames, tableB.Properties.VariableNames);

  % for col_name=missingB
  %   col_name
  % end

  % % Figure out what acceptable default values are to fill in missing data with. NaN for numeric, empty cells, and structs with NaNs
  % for col_name=incomplete_table.Properties.VariableNames
  %   col_data = incomplete_table{1,col_name};
  %   if isnumeric(col_data)
  %     missing_data = nan(size(col_data));
  %   elseif iscell(col_data)
  %     missing_data = cell(size(col_data));
  %   elseif isstruct(col_data)
  %     missing_data = struct();
  %     for field_name=fields(col_data)'
  %       missing_data.(field_name{:}) = NaN;
  %     end
  %   else
  %     error(sprintf('Sorry, the measurement with class ''%s'' that you are producing cannot be handled at this time. Please create report this issue in detail to: https://github.com/danielsnider/Single_Cell_Analysis_Toolkit/issues', class(col_data)));
  %   end
  %   complete_table.(col_name{:}) = missing_data;
  % end

  tableA = [tableA array2table(nan(height(tableA), numel(missingA)), 'VariableNames', missingA)]; % add missing columns
  tableB = [tableB array2table(nan(height(tableB), numel(missingB)), 'VariableNames', missingB)]; % add missing columns

end