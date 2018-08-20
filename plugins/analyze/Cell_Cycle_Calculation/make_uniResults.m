function [ResultDataStructure,uniResults,uniWells] = make_uniResults(ResultTable, measurement_name, control_treatment, total_measurement)

uniResults = table();
ResultDataStructure = struct();

ResultTable_Headers = ResultTable.Properties.VariableNames;
[~, idxCol_WellCondition] =  find(strcmp(ResultTable_Headers,'WellConditions'));
tmp = table2cell(ResultTable(:,idxCol_WellCondition:end));
tmp = regexprep(tmp, '\W$', '');
[~,idxCol] = find(strcmp(tmp,control_treatment));
idxCol_containing_Control = unique(idxCol,'stable');
Control_Col = char(ResultTable_Headers(idxCol_WellCondition+idxCol_containing_Control-1));
Current_End_Col = char(ResultTable_Headers(end));
ResultTable = movevars(ResultTable, Control_Col, 'After', Current_End_Col);
Well_Meta_Cols = ResultTable_Headers(find(strcmp(ResultTable_Headers,'Well_Info')==1):end);

MetaDataColumns = ResultTable.Properties.VariableNames(find(strcmpi(ResultTable.Properties.VariableNames,'WellConditions')):end);
% MetaDataColumns=ResultTable.Properties.VariableNames(find(strcmpi(ResultTable.Properties.VariableNames,'Well_Info')):end);

uniResults = unique(ResultTable(:,['row','column',MetaDataColumns]));
uniTimePoint = (unique(str2num(char(ResultTable.(measurement_name))),'sort'));
uniWells = unique(ResultTable(:,{'row','column'}));

count=1;
% Obtain cell number for each well per timepoint
for well = 1:size(uniWells,1)
    for time_point = 1:size(uniTimePoint,1)
        row = uniWells.row(well); col=uniWells.column(well);
        if strcmp(total_measurement,'Cell Number')
            % Total number of cells per well
            Num = sum(ismember(ResultTable.(measurement_name),cellstr(num2str(uniTimePoint(time_point))))&ResultTable.row==row&ResultTable.column==col);
        else
            % Total measurement per well
            Num = sum(ResultTable.(total_measurement)(ismember(ResultTable.(measurement_name),cellstr(num2str(uniTimePoint(time_point))))&ResultTable.row==row&ResultTable.column==col));
            
        end
        % Append cell number at the particular well to the uniWells variable.
        uniResults.(['TP_' num2str(uniTimePoint(time_point)) '_Hr'])(count,1) = Num;
        %         disp(['TimePoint: ' num2str(uniTimePoint(time_point)) ' Row:' num2str(uniWells.row(well)) ' Col: ' num2str(uniWells.column(well)) ' CellNum: ' num2str(Num)])
        %         pause(0.05)
    end
    count=count+1;
    ResultDataStructure.PlateMap{row,col} = char(join(table2array(unique(ResultTable(ResultTable.row==row&ResultTable.column==col,Well_Meta_Cols))),', '));
end
ResultDataStructure.PlateMap(cellfun('isempty',ResultDataStructure.PlateMap))={'NaN'};

end