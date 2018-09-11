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

% Save input arguments as a structure
Cell_Cycle_Params = struct();
Cell_Cycle_Params.ResultTable = ResultTable;
Cell_Cycle_Params.Check_for_Old_GUI = Check_for_Old_GUI;
Cell_Cycle_Params.measurement_name = measurement_name;
Cell_Cycle_Params.Imaging_Type = Imaging_Type;
Cell_Cycle_Params.average_replicates = average_replicates;
Cell_Cycle_Params.control_treatment = control_treatment;
Cell_Cycle_Params.Row_Treatment = Row_Treatment;
Cell_Cycle_Params.Column_Treatment = Column_Treatment;
Cell_Cycle_Params.Nucleus_Channel = Nucleus_Channel;
Cell_Cycle_Params.Cell_Cycle_Channel = Cell_Cycle_Channel;
Cell_Cycle_Params.Cytosol_Channel = Cytosol_Channel;
Cell_Cycle_Params.Nucleus_Area = Nucleus_Area;
Cell_Cycle_Params.Bulk_Measure = Bulk_Measure;
Cell_Cycle_Params.verbose_Plot = verbose_Plot;
Cell_Cycle_Params.Plot_Title = Plot_Title;
Cell_Cycle_Params.MetaRows = MetaRows;
Cell_Cycle_Params.MetaCols = MetaCols;



% ResultTable=app.ResultTable;
% ResultTable.(measurement_name)=ResultTable.(measurement_name);
% ResultTable(contains(ResultTable.(measurement_name),'14Hr'),23)={'14'}

if strcmp(ResultTable.Properties.VariableNames{1},'Row')
    ResultTable.Properties.VariableNames{1} = 'row';
    ResultTable.Properties.VariableNames{2} = 'column';
    Cell_Cycle_Params.ResultTable = ResultTable;
end
% ResultTable.TimePoint=str2double(ResultTable.TimePoint);

if strcmp(Imaging_Type,'DPC')
    [uniResults] = DPC_Image_Pipeline(Cell_Cycle_Params);
    assignin('base','uniResults',uniResults);
    evalin('base','openvar(''uniResults'')');
end

if strcmp(Imaging_Type,'Fixed')
    [ResultDataStructure, uniResults,Cell_Cycle_Params] = Fixed_Plate_Data_Analysis(Cell_Cycle_Params);
    assignin('base','uniResults',uniResults);
    evalin('base','openvar(''uniResults'')');
    assignin('base','uniResults',ResultDataStructure);
    evalin('base','openvar(''ResultDataStructure'')');
end
end