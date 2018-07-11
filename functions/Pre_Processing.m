function Pre_Processing(uniResults,uniWells,average_replicates,control_treatment,Imaging_Type,Plot_Title,total_measurement)

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
    
    if contains(Imaging_Type,'DPC')
        % Averaging Cell Cycle numbers
        Avg_uniResults = grpstats(uniResults,meta_info,{'mean','std'},'DataVars',{'Doubling_Time', 'Cell_Cycle'});
        Cell_Cycle_ScatterPlot(Avg_uniResults,control_treatment,Imaging_Type,Plot_Title,total_measurement)
        
%     elseif contains(Imaging_Type,'Fixed')
% %             uniCondition = unique(uniResults.WellConditions,'stable');
% %             tmp_uniResults = uniResults;
% %             tmp_uniResults(:,{'row','column','Doubling_Time','Cell_Cycle'}) = [];
% %             Avg_uniResults = Cell_Cycle_Calculation(tmp_uniResults,uniWells);
% %       
% 
%         
%         uniCondition = unique(uniResults.WellConditions,'stable');
%         tmp_uniResult = cell([length(uniCondition)+1 end_idx]);
%         tmp_uniResult = uniResults.Properties.VariableNames;
%         for i = 1:length(uniCondition)
%             condition = uniCondition(i);
%             tmp_uniResult{i+1,1} = (cat(1,uniResults.row(contains(uniResults.WellConditions,condition))'));
%             tmp_uniResult{i+1,2} = (cat(1,uniResults.column(contains(uniResults.WellConditions,condition))'));
%             meta_to_fill = table2cell(unique((uniResults((contains(uniResults.WellConditions,condition)),meta_info))));
%             count = 1;
%             for j = 3:length(meta_info)+2
%                 tmp_uniResult(i+1,j) = meta_to_fill(count);
%                 count = count+1;
%             end
%             for k = start_idx:end_idx
%                 tmp_uniResult{i+1,k} = cat(1,uniResults.(char(uniResults.Properties.VariableNames(k)))(contains(uniResults.WellConditions,condition))');
%             end
%         end
%         tmp_uniResult = cell2table(tmp_uniResult(2:end,:));
%         tmp_uniResult.Properties.VariableNames = uniResults.Properties.VariableNames;
%         uniWells = unique(uniResults.WellConditions,'stable');
%         Avg_uniResults = Cell_Cycle_Calculation(tmp_uniResult,uniWells,'Averaged'); 
%         
%         % Old Averaging
% %         Avg_uniResults = grpstats(uniResults,meta_info,'mean','DataVars',Time_Points);
% %         uniWells = unique(Avg_uniResults.WellConditions,'stable');
% %         Avg_uniResults = Cell_Cycle_Calculation(Avg_uniResults,uniWells);
% %         
%         Cell_Cycle_ScatterPlot(Avg_uniResults,normalize_by,control_treatment,Imaging_Type,Plot_Title)
%     end
         

end






end