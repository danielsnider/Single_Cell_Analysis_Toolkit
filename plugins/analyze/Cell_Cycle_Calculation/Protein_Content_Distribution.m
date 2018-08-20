function Protein_Content_Distribution(ResultDataStructure,Fixed_Cells_Args,Cell_Cycle_Params)

Treatments = Fixed_Cells_Args.Treatments;
uniDrugTreatments = Treatments('Drug_Treatments');
uniDrugTreatments_with_Control = Treatments('Control');
uniColumnTreatments = Fixed_Cells_Args.uniColumnTreatments;
MetaDataColumns = Fixed_Cells_Args.MetaDataColumns;
uniTimePoint = Fixed_Cells_Args.TimePoints;
Control_Var = Cell_Cycle_Params.control_treatment;

unique_main_conditions = erase(uniDrugTreatments_with_Control,Control_Var);
unique_main_conditions = strtrim(unique_main_conditions);

clearvars x y
    for i = 1:size(unique_main_conditions,1)

            fig = figure('Name','Protein Mass');position = 0;
            for timepoint = 1:length(uniTimePoint)
                current_timepoint = uniTimePoint(timepoint);
                position = position+1;
                subplot(2,round(size(uniTimePoint,1)/2),position);hold on;
                
                % Plotting Treatment
                % Find index specific unique well condition(s)
                current_treatment = (uniDrugTreatments(contains(uniDrugTreatments,unique_main_conditions(i))));
                colours = {'b','k'};
                for j = 1:size(current_treatment,1)
                    treatment = char(current_treatment(j));
                    [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,treatment));
                    
                    if isempty(idx_Row)&&isempty(idx_Col)
                        continue
                    end
                    
                    for r = 1:length(idx_Row)
                        x(:,r) = (ResultDataStructure.Paxis{idx_Row(r),idx_Col(r),timepoint});
                        y(:,r) = (ResultDataStructure.Pdensity{idx_Row(r),idx_Col(r),timepoint});
                    end
                    
                    if j ==1
                    p1 = plot(x,y,colours{j});
                    else
                        p2 = plot(x,y,colours{j});
                    end
                    
                    clearvars x y idx_Row idx_Col
                end
                
                % Plotting Control
                [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,char(uniDrugTreatments_with_Control(contains(uniDrugTreatments_with_Control,unique_main_conditions(i)))))); % This will break if there is more than one control

                if isempty(idx_Row)&&isempty(idx_Col)
                    continue
                end
                
                for r = 1:length(idx_Row)
                    x(:,r) = (ResultDataStructure.Paxis{idx_Row(r),idx_Col(r),timepoint});
                    y(:,r) = (ResultDataStructure.Pdensity{idx_Row(r),idx_Col(r),timepoint});
                end
                p3 = plot(x,y,'r');
                if timepoint == 1
                    if j ==2
                    legend([p1(1) p2(1) p3(1)], {'\color{blue} Dox100','\color{blue} Dox50','\color{red} Control'})  
                    else
                        legend([p1(1) p3(1)], {'\color{blue} Dox50','\color{red} Control'})  
                    end
                end
                clearvars x y idx_Row idx_Col
                
                title([cell2mat(current_timepoint) 'Hours'])
                
            end
            set(0,'DefaultTextInterpreter','none')
            suptitle(['Protein Mass: ' char(unique_main_conditions(i))])
            [ax1,h1]=suplabel('Protein Mass');
            set(h1,'FontSize',15)
            [ax2,h2]=suplabel('Frequency','y');
            set(h2,'FontSize',15)
            hold off;

    end
 
end % End of function