function Pre_Processing(ResultDataStructure,average_replicates,control_treatment,Plot_Title,total_measurement,MetaRows,MetaCols,Control_Rows,Control_Cols,separate_data_by_meta_var,list_order)
uniResults = ResultDataStructure.uniResults;
uniWells = ResultDataStructure.uniWells;
ResultTable = ResultDataStructure.ResultTable;
% Pre-Processing Data

%Get column indexes for TP_{time}_Hr headers
count = zeros(1,size(uniResults.Properties.VariableNames,2))*nan;
Time_Points = cell(1,size(uniResults.Properties.VariableNames,2));
for i = 1:size(uniResults.Properties.VariableNames,2)
    if ~isempty(cell2mat(regexp(uniResults.Properties.VariableNames(i),'TP_\d+_Hr')))
        count(1,i) = i;
        Time_Points(1,i) = uniResults.Properties.VariableNames(i);
    end
end
count(isnan(count))=[];
Time_Points(cellfun('isempty',Time_Points))=[];
start_idx = count(1); end_idx = count(end); clearvars i count
meta_info = uniResults.Properties.VariableNames(3:start_idx-1);
clearvars count

if average_replicates==true
    
        uniColumnTreatments = table2array(unique(ResultTable(:,MetaCols),'stable'));
        uniWell_Conditions = unique(ResultDataStructure.PlateMap,'stable'); uniWell_Conditions(1) = [];
        
        % Averaging Cell Cycle numbers
        Avg_uniResults = grpstats(uniResults,meta_info,{'mean','std'},'DataVars',{'Doubling_Time', 'Cell_Cycle'});
        
        % Find Controls and Treatments
        if isempty(Control_Rows) && isempty(Control_Cols)
        % Get user to pick which wells are control wells
            [fh,tmp] = Get_User_Desired_Labels(ResultDataStructure.PlateMap);
            Control_Rows = unique(tmp.UserData.datatable_row);
            Control_Cols = unique(tmp.UserData.datatable_col);
        end
        
        Controls = ResultDataStructure.PlateMap(Control_Rows, Control_Cols)';
        Controls = unique(reshape(Controls,[(size(Controls,1)*size(Controls,2)),1]));
        Treatments = unique(ResultDataStructure.PlateMap(~contains(ResultDataStructure.PlateMap,Controls)&...
            ~contains(ResultDataStructure.PlateMap,'NaN')));
        keySet = {'Control', 'Drug_Treatments'};
        value = {Controls,Treatments};
        Treatments = containers.Map(keySet,value);
        
        uniWell_Conditions = uniWell_Conditions((contains(uniWell_Conditions,Treatments('Control'))|contains(uniWell_Conditions,Treatments('Drug_Treatments')))&contains(uniWell_Conditions,uniColumnTreatments));
        
        if isempty(Control_Rows) && isempty(Control_Cols)
            close(fh)
            clearvars tmp
        end
        
        if isempty(separate_data_by_meta_var)
            fig = uifigure('Position',[100 100 500 500]);
            
            % Create uilabel
            text = sprintf('%s\n%s\n%s','Select which meta-column you would like to separate your data by.','This will separate your data into different plots based on unique cases','in the meta-column you select.');
            Description_label = uilabel(fig,...
                'Text',text,'Position',[20 80 450 750]);
            Description_label.FontSize = 14;
            
            % Create list box
            Group_Plotting_List = uilistbox(fig,...
                'Position',[20 20 350 400],...
                'Items',[{'Well_Info'},MetaRows,MetaCols]);
            
            btn = uibutton(fig,...
                'push',...
                'Text', 'OK',...
                'Position',[380,100, 100, 22],...
                'ButtonPushedFcn', @(btn, event) ButtonPushed(fig,'invisible','resume'));
            
            uiwait(fig)
            Group_by_Value = Group_Plotting_List.Value;
        else
            Group_by_Value = char(separate_data_by_meta_var);
        end
        
        unique_Grouping = unique(Avg_uniResults.(Group_by_Value),'stable');
        
        for i = 1:size(unique_Grouping,1)

            group = uniWell_Conditions(contains(uniWell_Conditions,unique_Grouping(i)));
            
            if isempty(list_order)
                data_order_to_process = reorderlist(group);
            else
                data_order_to_process = auto_reorderlist(group,list_order);
            end
            
            WellConditions_Index = find(strcmp(Avg_uniResults.Properties.VariableNames,'WellConditions'))+1:find(strcmp(Avg_uniResults.Properties.VariableNames,'GroupCount'))-1;
            target_row_result_idxs = contains(join(table2cell(Avg_uniResults(:,WellConditions_Index)),', '),data_order_to_process);
            
            
            keySet = data_order_to_process;
            valueSet = Avg_uniResults.mean_Cell_Cycle(target_row_result_idxs);
            Cell_Cycle_Length_Map = containers.Map(keySet,valueSet);
            
            clearvars keySet valueSet
        
            % Get the total number of unique specific conditions to group by -- to colour code the same experiement testing different conditions
            unique_measurement_count = size(unique(Avg_uniResults(:,find(strcmp(Avg_uniResults.Properties.VariableNames,'GroupCount'))-1),'stable'),1);
            
            
            Figure_Name = 'CCL ScatterPlot';
            num_Points = double(size(group,1));
            num_Points_to_Group = unique_measurement_count;
            data_Map = Cell_Cycle_Length_Map;
            text_point_label = "CCL: ";
            plot_title = ['Cell Cycle Length based on ' total_measurement ' for: ' Plot_Title '_' char(unique_Grouping(i))];
            y_label = 'Cell Cycle (Hours)';
            x_label = 'Well Condition';

            dynamic_Scatter_Plot(Figure_Name, data_Map, data_order_to_process, num_Points, num_Points_to_Group, text_point_label, plot_title, y_label, x_label)

        end
        
        if isempty(separate_data_by_meta_var)
            close(fig)
        end
%         Cell_Cycle_ScatterPlot(Avg_uniResults,control_treatment,Plot_Title,total_measurement)
        
        
end

end