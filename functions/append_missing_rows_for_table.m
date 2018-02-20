function complete_table = append_missing_rows_for_table(incomplete_table, desired_height)
  complete_table = table();

  % Figure out what acceptable default values are to fill in missing data with. NaN for numeric, empty cells, and structs with NaNs
  for col_name=incomplete_table.Properties.VariableNames
    col_data = incomplete_table{1,col_name};
    if isnumeric(col_data)
      missing_data = nan(size(col_data));
    elseif iscell(col_data)
      missing_data = cell(size(col_data));
    elseif isstruct(col_data)
      missing_data = struct();
      for field_name=fields(col_data)'
        missing_data.(field_name{:}) = NaN;
      end
    else
      error(sprintf('Sorry, the measurement with class ''%s'' that you are producing cannot be handled at this time. Please create report this issue in detail to: https://github.com/danielsnider/Single_Cell_Analysis_Toolkit/issues', class(col_data)));
    end
    complete_table.(col_name{:}) = missing_data;
  end

  % Loop over rows that must be added and do adding
  missing_start_pos = height(incomplete_table)+1;
  missing_end_pos = desired_height;
  for idx=missing_start_pos:missing_end_pos
    incomplete_table(idx,:) = complete_table;
  end

  % Set the proper output variable
  complete_table = incomplete_table;

end