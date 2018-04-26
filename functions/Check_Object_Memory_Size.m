function Check_Object_Memory_Size(varToCheck,savename,optional_path)
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
        %if strcmp(optional_path,'choose a path')
        %    optional_path = uigetdir('C:\');
        %end
        if isempty(optional_path)
            dirname = uigetdir('C:\');
            filename = [dirname '\' savename '.mat'];
        else
            filename = [optional_path '\' savename '.mat'];
        end
        disp(['Saving ResultTable of size ' str ' to ... ' filename ]) 
        if str2double(strrep(str,'Gb',''))>=2 & contains(str,'Gb')
            save(filename,'ResultTable', '-v7.3', '-nocompression')
        else
            save(filename,'ResultTable', '-v7')
        end
    end 
end