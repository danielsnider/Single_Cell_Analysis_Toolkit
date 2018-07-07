function fun(plugin_name, plugin_num,ResultTable, Check_for_Old_GUI, measurement_name,Imaging_Type,average_replicates,control_treatment,Row_Treatment,Column_Treatment,Nucleus_Channel,Cell_Cycle_Channel,Cytosol_Channel,Nucleus_Area,Bulk_Measure,verbose_Plot,Plot_Title,MetaRows,MetaCols)

% for debugging
try
    exist('plugin_name','var') & exist('plugin_num','var')==true;
    Row_Treatment = Row_Treatment.names;
    Column_Treatment = Column_Treatment.names;
    MetaRows = MetaRows.names;
    MetaCols = MetaCols.names;
    Bulk_Measure = char(Bulk_Measure);
    try
        Nucleus_Area = char(Nucleus_Area);
    catch
        Nucleus_Area = 'NArea';
    end
    
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

set(0,'DefaultFigureWindowStyle','docked')

% ResultTable=app.ResultTable;
ResultTable.(measurement_name)=ResultTable.(measurement_name);
% ResultTable(contains(ResultTable.(measurement_name),'14Hr'),23)={'14'}

if strcmp(ResultTable.Properties.VariableNames{1},'Row')
    ResultTable.Properties.VariableNames{1} = 'row';
    ResultTable.Properties.VariableNames{2} = 'column';
end
% ResultTable.TimePoint=str2double(ResultTable.TimePoint);

if strcmp(Imaging_Type,'DPC')
    % Get number of cells per measurement for each well
    Total_Measurements = {'Cell Number','NArea'}';
%     total_measurement = 'NArea';
%     total_measurement = 'Cell Number';
    for jj = 1:size(Total_Measurements,1)
    total_measurement = char(Total_Measurements(jj));
    [uniResults,uniWells] = make_uniResults(ResultTable, measurement_name,total_measurement);
    
    [uniResults,start_idx,end_idx] = Cell_Cycle_Calculation(uniResults,uniWells);
     
    % Plot Microplate Plot for Cell Cycle Length
    data_to_plot = 'Cell_Cycle'; Main_Title = ['Cell Cycle Length (Hours) Based on ' total_measurement]; color = 'Dark2';rounding_decimal=2;
    color = 'cool(6)';
    MicroPlate_Plotting(uniResults,uniWells,data_to_plot,color,Main_Title,Plot_Title,MetaRows,MetaCols,rounding_decimal)
    
    if verbose_Plot==true
        
        % Microplate Plot for Cell Number
        for i = start_idx:end_idx
            data_to_plot = char(uniResults.Properties.VariableNames(i));
            Main_Title = ['Total ' total_measurement ' at:  (' data_to_plot ')']; color = 'Spectral';
            MicroPlate_Plotting(uniResults,uniWells,data_to_plot,color,Main_Title,Plot_Title,MetaRows,MetaCols,rounding_decimal)
        end
    end
    
    if average_replicates==true
        Pre_Processing(uniResults,uniWells,average_replicates,control_treatment,Imaging_Type,Plot_Title,total_measurement)
    end
    
%     assignin('base','uniResults',uniResults);
%     evalin('base','openvar(''uniResults'')');
    end
end

if strcmp(Imaging_Type,'Fixed')
    [ResultDataStructure, uniResults] = Fixed_Plate_Data_Analysis(ResultTable,Check_for_Old_GUI,measurement_name,average_replicates,control_treatment,Row_Treatment,Column_Treatment,Nucleus_Channel,Cell_Cycle_Channel,Cytosol_Channel,Nucleus_Area,Bulk_Measure,verbose_Plot,Plot_Title,MetaRows,MetaCols);
    assignin('base','uniResults',uniResults);
    evalin('base','openvar(''uniResults'')');
    assignin('base','uniResults',ResultDataStructure);
    evalin('base','openvar(''ResultDataStructure'')');
end
end