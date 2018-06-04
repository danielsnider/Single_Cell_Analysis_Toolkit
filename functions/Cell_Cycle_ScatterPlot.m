function Cell_Cycle_ScatterPlot(Avg_uniResults,normalize_by,control_treatment,Imaging_Type,Plot_Title)


    %% Splitting Well Condition into their seperate meta-info based on separation by commas
%     Well_Condition_Split_Control = strsplit(char(Avg_uniResults.WellConditions(contains(Avg_uniResults.WellConditions,control_treatment))),','); %OLD
    Well_Condition_Split_Control = regexp(Avg_uniResults.WellConditions(contains(Avg_uniResults.WellConditions,control_treatment)),',','split');
    tmp = cell(length(Well_Condition_Split_Control),size(Well_Condition_Split_Control{1,1},2));
    for i = 1:length(Well_Condition_Split_Control)
        tmp(i,1:size(Well_Condition_Split_Control{1,1},2)) = Well_Condition_Split_Control{i,1};
    end
    Well_Condition_Split_Control = tmp;
    clearvars i tmp
    
    %% Finding index col of the control meta-info to re-arrange the well info
    [~,control_idx_metainfo_col] = find(contains(Well_Condition_Split_Control,control_treatment));
    
    %% Re-Arranging Well Condition meta-info
    tmp = Well_Condition_Split_Control;
    tmp(:,control_idx_metainfo_col) = [];
    tmp(:,end+1) = Well_Condition_Split_Control(contains(Well_Condition_Split_Control,control_treatment));
    Well_Condition_Split_Control = tmp;
    clearvars tmp

    tmp = cell(size(Well_Condition_Split_Control,1),1);
    for i = 1:size(Well_Condition_Split_Control,1)
    tmp(i,1) = cellstr(strjoin(Well_Condition_Split_Control(i,:), ','));
    end
    Well_Condition_Split_Control = tmp;
    clearvars i tmp
    
    %% Get the unique experiments being tested
    global_unique_treatment = cellstr(strrep(Well_Condition_Split_Control,control_treatment,''));
    
    %% Get all the unique conditions
    uniConditions = unique(Avg_uniResults.WellConditions,'stable');
    uniConditions_Cell_Split = regexp(uniConditions,',','split');
    tmp = cell(length(uniConditions_Cell_Split),size(uniConditions_Cell_Split{1,1},2));
    for i = 1:length(uniConditions_Cell_Split)       
        tmp(i,1:size(uniConditions_Cell_Split{1,1},2)) = uniConditions_Cell_Split{i,1};    
    end
    uniConditions_Cell_Split = tmp;
    clearvars i tmp
    
    tmp = uniConditions_Cell_Split;
    tmp(:,control_idx_metainfo_col) = [];
    tmp(:,end+1) = uniConditions_Cell_Split(:,unique(control_idx_metainfo_col)); % Need to Optimize
    uniConditions_Cell_Split = tmp;
    clearvars tmp
    
    tmp = cell(size(uniConditions_Cell_Split,1),1);
    for i = 1:size(uniConditions_Cell_Split,1)
        tmp(i,1) = cellstr(strjoin(uniConditions_Cell_Split(i,:), ','));
    end
    uniConditions = tmp;
    clearvars i tmp
    
    %% Plotting Action
    color_list = distinguishable_colors(60,[0 0.5 0 ]);
    count = 1; fig_Hobj = figure('Name', 'ScatterPlot of Median Cell Cycle Length'); hold on; x_labels = cell(length(uniConditions),1);
    for i = 1:length(global_unique_treatment)
        current_condition = Avg_uniResults.WellConditions(contains(uniConditions,global_unique_treatment(i)));
        color = color_list(count,:);
        for sub_condition = 1:length(current_condition)
            if contains(Imaging_Type,'DPC')
                y = Avg_uniResults.mean_Cell_Cycle(contains(Avg_uniResults.WellConditions,current_condition(sub_condition)));
                y_err = Avg_uniResults.std_Cell_Cycle(contains(Avg_uniResults.WellConditions,current_condition(sub_condition)));
               
            elseif contains(Imaging_Type,'Fixed')
                y = Avg_uniResults.Cell_Cycle(contains(Avg_uniResults.WellConditions,current_condition(sub_condition)));
            end
            plot_handle = plot(count,y, 'o','MarkerEdgeColor','b','MarkerFaceColor',color);
%             hDatatip = makedatatip(plot_handle,[1 1]);
            txt1 = ['CCL: ' num2str(y)];
%             text(count,y+0.2,txt1,'VerticalAlignment','bottom','HorizontalAlignment','right')
            labelpoints(count,y,txt1,'N',0.2,1)
%             annotation('textarrow',count,y+0.1,'String',txt1)
%             annotation(fig_Hobj,'textarrow',[0,0.1],[0,0],'String',txt1)
            
            if contains(Imaging_Type,'DPC')
                errorbar(count,y, y_err,'LineStyle', '--', 'Color', color)
            end
            % Draw a line for the control median
            if any(strcmp(string(current_condition(sub_condition)),string(normalize_by)))
                line(1:count,repmat(y,1,count),'Color',color,'LineStyle','--','LineWidth', 0.5)
            end
            x_labels(count,1) = current_condition(sub_condition);
            count = count +1;
        end
    end
    ax = gca;
    ax.XTick = 1:length(x_labels);
    ax.XTickLabel = x_labels;
    ax.XTickLabelRotation = 45;
    
    title(['Cell Cycle Length for: ' Plot_Title],'Interpreter', 'none');ylabel('Cell Cycle (Hours)');xlabel('Well Condition')
    grid on
    hold off;
end