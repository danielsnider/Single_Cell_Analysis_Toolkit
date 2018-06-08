function save_measurements(app, save_as_file_type, prompt_save_location)

    if strcmp(save_as_file_type, 'prompt_file_type')
      msg = 'In which format would you like to save measurements?';
      title = 'Choose File Type';
      save_as_file_type = uiconfirm(app.UIFigure,msg,title,...
                 'Options',{'Spreadsheet (.csv)','Matlab (.mat)','Cancel'},...
                 'DefaultOption',1,'CancelOption',3);
    end

    if strcmp(save_as_file_type,'Cancel')
        return
    end

    date_str = datestr(now,'yyyymmddTHHMMSS');
    savename = sprintf('%s_ResultTable', date_str); % add date string to avoid overwritting and busy permission denied errors
    varToCheck = app.ResultTable;
    optional_path = app.SavetoEditField.Value;

    VariableInfo = whos('varToCheck');
    NumBytes = VariableInfo.bytes;
    scale = floor(log(NumBytes)/log(1024));
    ResultTable=varToCheck;
    switch scale
        case 0
            str = [sprintf('%.0f',NumBytes) ' b'];
        case 1
            str = [sprintf('%.2f',NumBytes/(1024)) ' kb'];
        case 2
            str = [sprintf('%.2f',NumBytes/(1024^2)) ' Mb'];
        case 3
            str = [sprintf('%.2f',NumBytes/(1024^3)) ' Gb'];
        case 4
            str = [sprintf('%.2f',NumBytes/(1024^4)) ' Tb'];
        case -inf
            % Size occasionally returned as zero (eg some Java objects).
            str = 'Not Available';
            return
        otherwise
            str = 'Over a petabyte!!!';
    end
    if ~strcmp(savename,'None')
        fprintf('\n')
        if strcmp(optional_path,'choose a path')
           optional_path = [];
        end
        if isempty(optional_path)
          if strcmp(prompt_save_location, 'prompt_save_location')
              dirname = uigetdir('\','Choose a folder to save to');
              if isempty(dirname)
                  return
              end
            else
              dirname = pwd; % current directory of the GUI
            end
            filename = [dirname '\' savename];
        else
            filename = [optional_path '\' savename];
        end

        if ismember(save_as_file_type,{'Matlab (.mat)','save_both_file_types'})
            file_ending = '.mat';
            filename = [filename file_ending];
            disp(['Saving ResultTable to ... ' filename ]) 
            if str2double(strrep(str,'Gb',''))>=2 & contains(str,'Gb')
                save(filename,'ResultTable', '-v7.3', '-nocompression')
            else
                save(filename,'ResultTable', '-v7')
            end
            if strcmp(save_as_file_type,'save_both_file_types')
              filename = filename(1:end-4); % remove extension (.mat) because in this case two different ones were saved and we don't want the filename to be like '20180605T144313_ResultTable.mat.csv'
            end
        end
        if ismember(save_as_file_type,{'Spreadsheet (.csv)','save_both_file_types'})
          file_ending = '.csv';
          filename = [filename file_ending];
          disp(['Saving ResultTable to ... ' filename ]) 
          writetable(ResultTable,filename);
        end
    end 

    if strcmp(save_as_file_type,'save_both_file_types')
      filename = filename(1:end-4); % remove extension (.csv or .mat) because in this case two different ones were saved, it would be confusing to show the user only one location.
    end

    msg = sprintf('Saved measurements table to file:\n%s', filename);
    uialert(app.UIFigure, msg, 'Save Complete', 'Icon','success');
end