function Pre_Processing(uniResults,uniWells,pre_process_options,control_treatment,normalize_by,Imaging_Type,Plot_Title)

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

if contains(pre_process_options(1),'Average Replicates')
    
    if contains(Imaging_Type,'DPC')
        % Averaging Cell Cycle numbers
        Avg_uniResults = grpstats(uniResults,meta_info,{'mean','std'},'DataVars',{'Doubling_Time', 'Cell_Cycle'});
        Cell_Cycle_ScatterPlot(Avg_uniResults,normalize_by,control_treatment,Imaging_Type,Plot_Title)
        
    elseif contains(Imaging_Type,'Fixed')
%             uniWells = unique(uniResults.WellConditions,'stable');
%             tmp_uniResults = uniResults;
%             tmp_uniResults(:,{'row','column','Doubling_Time','Cell_Cycle'}) = [];
%             Avg_uniResults = Cell_Cycle_Calculation(tmp_uniResults,uniWells);
%             
        Avg_uniResults = grpstats(uniResults,meta_info,'mean','DataVars',Time_Points);
        uniWells = unique(Avg_uniResults.WellConditions,'stable');
        Avg_uniResults = Cell_Cycle_Calculation(Avg_uniResults,uniWells);
        Cell_Cycle_ScatterPlot(Avg_uniResults,normalize_by,control_treatment,Imaging_Type,Plot_Title)
    end
         

end








normalize_by_minus_control_treatment = strrep(normalize_by,control_treatment,'');

uniConditions = unique(uniResults.WellConditions,'stable');

% if contains(pre_process_options(2),'Normalize')
%     
%     
%     
%     for i = 1:length(normalize_by_minus_control_treatment)
%         
%         normalize_by_minus_control_treatment(i)
%         well_to_norm = uniResults.WellConditions(contains(uniResults.WellConditions,normalize_by_minus_control_treatment(i))&~contains(uniResults.WellConditions,control_treatment));
%         well_to_norm_indx = find(contains(uniResults.WellConditions,well_to_norm));
%         normalizer_idx = find(contains(uniResults.WellConditions,normalize_by(i)))
%         for k = 1:length(well_to_norm_idx)
%             difference = uniResults(well_to_norm_indx(k),start_idx) - uniResults(
%             
%             
%         end
%         uniResults(1,start_idx:end_idx)
%         uniResults(41,start_idx:end_idx)
%         
%         func = @(x,difference) x-difference;
%         varfun(func,uniResults(1,start_idx:end_idx))
%         
%         
%         
%     end

    
% end



end