function fun(plugin_name, plugin_num,ResultTable, measurement_name,Imaging_Type,average_replicates,control_treatment,verbose_Plot,Plot_Title,MetaRows,MetaCols)

% for debugging
try
    exist('plugin_name','var') & exist('plugin_num','var')==true;
    fprintf('User Arguments:\n- Measurement name: %s\n- Imaging type of data acquisition: %s\n- Control treatment: %s\n', measurement_name, char(Imaging_Type), control_treatment) 
catch
    disp('Using debug mode variables')
    measurement_name = 'TimePoint';
    Imaging_Type  = 'Fixed';
    average_replicates = 'Average Replicates';
    control_treatment = 'No Dox';
    verbose_Plot = true;
    Plot_Title = '20180326_SE';
    MetaRows = 'Treatment'; MetaCols = 'Clone';
end

% ResultTable=app.ResultTable;
ResultTable.(measurement_name)=ResultTable.(measurement_name);
% ResultTable(contains(ResultTable.(measurement_name),'14Hr'),23)={'14'}    

if strcmp(ResultTable.Properties.VariableNames{1},'Row')
    ResultTable.Properties.VariableNames{1} = 'row';
    ResultTable.Properties.VariableNames{2} = 'column';
end
% ResultTable.TimePoint=str2double(ResultTable.TimePoint);
uniResults = table();
% uniResults.TimePoint = (unique(ResultTable.TimePoint,'sorted'))

MetaDataColumns=ResultTable.Properties.VariableNames(find(strcmpi(ResultTable.Properties.VariableNames,'WellConditions')):end);
% MetaDataColumns=ResultTable.Properties.VariableNames(find(strcmpi(ResultTable.Properties.VariableNames,'Well_Info')):end);

uniResults = unique(ResultTable(:,['row','column',MetaDataColumns]));
uniTimePoint = flip(unique(ResultTable.(measurement_name),'stable'));
uniWells = unique(ResultTable(:,{'row','column'}));

count=1;
% Obtain cell number for each well per timepoint
for well = 1:size(uniWells,1)
    for time_point = 1:size(uniTimePoint,1)
        row = uniWells.row(well); col=uniWells.column(well);
        % Total number of cells per well
        Num = sum(ismember(ResultTable.(measurement_name),uniTimePoint(time_point))&ResultTable.row==row&ResultTable.column==col); 
        % Append cell number at the particular well to the uniWells variable.
        uniResults.(['TP_' cell2mat(uniTimePoint(time_point)) '_Hr'])(count,1) = Num; 
%         disp(['TimePoint: ' num2str(uniTimePoint(time_point)) ' Row:' num2str(uniWells.row(well)) ' Col: ' num2str(uniWells.column(well)) ' CellNum: ' num2str(Num)])
%         pause(0.05)  
    end
    count=count+1;
end

[uniResults,start_idx,end_idx] = Cell_Cycle_Calculation(uniResults,uniWells);

% Make exponential separate
% if verbose_Plot == 'Exponential'
%     
%     disp('HI Exponential Plotting')
%     
% end

% Plot Microplate Plot for Cell Cycle Length
data_to_plot = 'Cell_Cycle'; Main_Title = 'Cell Cycle Length (Hours)'; color = 'Dark2';rounding_decimal=2;
color = 'cool(6)';
MicroPlate_Plotting(uniResults,uniWells,data_to_plot,color,Main_Title,Plot_Title,MetaRows,MetaCols,rounding_decimal)


if all(verbose_Plot=='Verbose Plots')

    % Microplate Plot for Cell Number
    for i = start_idx:end_idx
        data_to_plot = char(uniResults.Properties.VariableNames(i));
        Main_Title = ['Cell Number (' data_to_plot ')']; color = 'Spectral';
        MicroPlate_Plotting(uniResults,uniWells,data_to_plot,color,Main_Title,Plot_Title,MetaRows,MetaCols,rounding_decimal)
    end
end

if all(average_replicates=='Average')
    Pre_Processing(uniResults,uniWells,average_replicates,control_treatment,normalize_by,Imaging_Type,Plot_Title)
end




assignin('base','uniResults',uniResults);
evalin('base','openvar(''uniResults'')'); 


end