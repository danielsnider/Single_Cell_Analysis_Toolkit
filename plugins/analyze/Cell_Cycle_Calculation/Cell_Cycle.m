function fun(plugin_name, plugin_num,ResultTable, measurement_name,Plot)

% ResultTable=app.ResultTable;
ResultTable.(measurement_name)=ResultTable.(measurement_name);
% ResultTable.TimePoint=str2double(ResultTable.TimePoint);
uniResults = table();
% uniResults.TimePoint = (unique(ResultTable.TimePoint,'sorted'))

MetaDataColumns=ResultTable.Properties.VariableNames(find(strcmpi(ResultTable.Properties.VariableNames,'WellConditions')):end);

uniResults = unique(ResultTable(:,['row','column',MetaDataColumns]));
uniTimePoint = unique(ResultTable.(measurement_name),'sorted');
uniWells = unique(ResultTable(:,{'row','column'}));

count=1;
% loop over all wells
for well = 1:size(uniWells,1)
    % loop over time points
    for time_point = 1:size(uniTimePoint,1)
        row = uniWells.row(well); col=uniWells.column(well);
        Num = sum(ismember(ResultTable.(measurement_name),uniTimePoint(time_point))&ResultTable.row==row&ResultTable.column==col); % Total number of cells per well
        uniResults.(['TP_' cell2mat(uniTimePoint(time_point)) '_Hr'])(count,1) = Num; %Append cell number at the particular well to the uniWells variable.
%         disp(['TimePoint: ' num2str(uniTimePoint(time_point)) ' Row:' num2str(uniWells.row(well)) ' Col: ' num2str(uniWells.column(well)) ' CellNum: ' num2str(Num)])
%         pause(0.05)  
    end
    count=count+1;
end

uniResults = Cell_Cycle_Calculation(uniResults,uniWells);

% if Plot == 'Exponential'
%     
%     disp('HI Exponential Plotting')
%     
% end

if strcmp(Plot,'MicroPlate')   
    MicroPlate_Plotting(uniResults,uniWells)    
end






assignin('base','uniResults',uniResults);
evalin('base','openvar(''uniResults'')'); 


end