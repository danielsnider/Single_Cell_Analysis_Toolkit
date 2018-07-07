function [uniResults,uniWells] = make_uniResults(ResultTable, measurement_name, total_measurement)

uniResults = table();
% uniResults.TimePoint = (unique(ResultTable.TimePoint,'sorted'))

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
end
end