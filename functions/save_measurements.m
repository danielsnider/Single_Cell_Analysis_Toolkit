function save_measurements(app)
    msg = 'In which format would you like to save measurements?';
    title = 'Choose File Type';
    user_selection = uiconfirm(app.UIFigure,msg,title,...
               'Options',{'Spreadsheet (.csv)','Matlab (.mat)','Cancel'},...
               'DefaultOption',1,'CancelOption',3);

    if strcmp(user_selection,'Cancel')
        return
    end

    if strcmp(user_selection,'Matlab (.mat)')
        file_ending = '.mat';
    elseif strcmp(user_selection,'Spreadsheet (.csv)')
        file_ending = '.csv';
    end

    savename = 'ResultTable';
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
            dirname = uigetdir('\','Choose a folder to save to');
            if isempty(dirname)
                return
            end
            filename = [dirname '\' savename file_ending];
        else
            filename = [optional_path '\' savename file_ending];
        end
        disp(['Saving ResultTable of size ' str ' to ... ' filename ]) 

        if strcmp(user_selection,'Matlab (.mat)')
            if str2double(strrep(str,'Gb',''))>=2 & contains(str,'Gb')
                save(filename,'ResultTable', '-v7.3', '-nocompression')
            else
                save(filename,'ResultTable', '-v7')
            end
        elseif strcmp(user_selection,'Spreadsheet (.csv)')
            writetable(ResultTable,filename);
        end
    end 

    msg = sprintf('Saved measurements table of size %s to file:\n%s', str, filename);
    uialert(app.UIFigure, msg, 'Save Complete', 'Icon','success');
end