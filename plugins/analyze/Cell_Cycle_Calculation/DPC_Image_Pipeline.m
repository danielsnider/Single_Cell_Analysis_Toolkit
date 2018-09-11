
function [uniResults] = DPC_Image_Pipeline(Cell_Cycle_Params)

% Import Variables
ResultTable = Cell_Cycle_Params.ResultTable;
measurement_name = Cell_Cycle_Params.measurement_name;
average_replicates = Cell_Cycle_Params.average_replicates;
control_treatment = Cell_Cycle_Params.control_treatment;
verbose_Plot = Cell_Cycle_Params.verbose_Plot;
Plot_Title = Cell_Cycle_Params.Plot_Title;
MetaRows = Cell_Cycle_Params.MetaRows;
MetaCols = Cell_Cycle_Params.MetaCols;
Control_Rows = Cell_Cycle_Params.Control_Rows;
Control_Cols = Cell_Cycle_Params.Control_Cols;
separate_data_by_meta_var = Cell_Cycle_Params.separate_data_by_meta_var;
list_order = Cell_Cycle_Params.list_order;

% Get number of cells per measurement for each well
Total_Measurements = {'Cell Number','NArea'}';
%     total_measurement = 'NArea';
%     total_measurement = 'Cell Number';
for jj = 1:size(Total_Measurements,1)
    total_measurement = char(Total_Measurements(jj));
    [ResultDataStructure,uniResults,uniWells] = make_uniResults(ResultTable, measurement_name, control_treatment, total_measurement);
    
    [uniResults,start_idx,end_idx] = Cell_Cycle_Calculation(uniResults,uniWells,verbose_Plot,total_measurement);
    
    
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
    
    
    ResultDataStructure.uniResults = uniResults;
    ResultDataStructure.uniWells = uniWells;
    ResultDataStructure.ResultTable = ResultTable;
    if average_replicates==true
        Pre_Processing(ResultDataStructure,average_replicates,control_treatment,Plot_Title,total_measurement,MetaRows,MetaCols,Control_Rows,Control_Cols,separate_data_by_meta_var,list_order)
    end
    
    %     assignin('base','uniResults',uniResults);
    %     evalin('base','openvar(''uniResults'')');
end

end % End of function