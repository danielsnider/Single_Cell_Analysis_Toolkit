function [mass_Interest,cc_Interest,data_legend_platemap] = Growth_Rate_Estimation(ResultDataStructure,Cell_Cycle_Params,Fixed_Cells_Args,Bulk_Measure,verbose_Plot)



% Growth Rate Equation: v = 1/Nt * dMt/dt
clearvars x y_Mass y_cellNum tmp

Treatments = Fixed_Cells_Args.Treatments;
MetaDataColumns = Fixed_Cells_Args.MetaDataColumns;
uniTimePoint = Fixed_Cells_Args.TimePoints;
Control_Var = Cell_Cycle_Params.control_treatment;

unique_main_conditions = erase(Treatments('Control'),Control_Var);
unique_main_conditions = strtrim(unique_main_conditions);


uniDrugTreatments = vertcat(Treatments('Drug_Treatments'));
uniControlTreatments = vertcat(Treatments('Control'));

%% User pick what drugs they want results for
% tmp = Get_User_Desired_Labels(uniDrugTreatments);
% uniDrugTreatments = uniDrugTreatments(unique(tmp.UserData.datatable_row), unique(tmp.UserData.datatable_col));
% clearvars tmp
k=0;
% Main for-loop to parse each unique main condition 
for i = 1:size(unique_main_conditions,1)
    
    if verbose_Plot==true
        fig1 = figure('Name','Growth Rate','Position', [100, 100, 800, 800]); fig2 = figure('Name','Cell Num','Position', [100, 100, 800, 800]);position = 0;
    end
    
%     if contains(char(unique_main_conditions(i)),'+')
%         uniCellTreatExpression = strrep(char(unique_main_conditions(i)),'+','(+)');
%     else
%         uniCellTreatExpression = char(unique_main_conditions(i));
%     end
    
    disp(['Working on ' char(unique_main_conditions(i))])

        %% Treatment
%         k=k+1;
        current_treatment = (uniDrugTreatments(contains(uniDrugTreatments,unique_main_conditions(i))));
        for j = 1:size(current_treatment,1)
            k=k+1;
            current_drug_treatment = char(current_treatment(j));
            [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,current_drug_treatment));
            
            if isempty(idx_Row)&&isempty(idx_Col)
                continue
            end
            
            disp(['|----------Working on ' current_drug_treatment])
            
            if verbose_Plot==true
                position = position+1;
                
                % Plot for Protein Mass
                figure(fig1)
                subplot(size(current_treatment,1)+1,1,position);hold on;
                % Plot for Cell Number
                figure(fig2)
                subplot(size(current_treatment,1)+1,1,position);hold on;
            end
            
            clearvars idx_Row idx_Col
            
            for timepoint = 1:length(uniTimePoint)
                current_timepoint = uniTimePoint(timepoint);
                % Fitting Growth_Rate
                [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,current_drug_treatment));
                
                if isempty(idx_Row)&&isempty(idx_Col)
                    disp('Something is not right with this, will be skipping....')
                    continue
                end
                
                for r = 1:length(idx_Row)
                    y_Mass(timepoint,r) = (ResultDataStructure.(Bulk_Measure)(idx_Row(r),idx_Col(r),timepoint));
                    y_cellNum(timepoint,r) = (ResultDataStructure.Numcells(idx_Row(r),idx_Col(r),timepoint));
                end
            end
            try
                x = repmat(str2num((cell2mat(uniTimePoint))),[size(y_Mass,2) 1]);
            catch
                x = repmat(str2num((char(uniTimePoint))),[size(y_Mass,2) 1]);
            end
            y_Mass = log2(reshape(y_Mass,[size(y_Mass,1)*size(y_Mass,2) 1]));
            y_cellNum = log2(reshape(y_cellNum,[size(y_cellNum,1)*size(y_cellNum,2) 1]));
            
            
            f = fittype('m*x + b');
            if verbose_Plot==true
                figure(fig1)
            end
            [fit1,gof,~] = fit(x,y_Mass,f,'StartPoint',[1 1],'Robust','on');
            if verbose_Plot==true
                plot(fit1,x,y_Mass,'or')
                text(str2num((cell2mat(uniTimePoint(1))))+1,(max(y_Mass))-0.5,sprintf('Rsq = %g\nAdj = %g\nSlope = %g\n1/Slope = %g',gof.rsquare,gof.adjrsquare,fit1.m,1/fit1.m))
                title(['Treatment: ' current_drug_treatment])
                legend('off')
            end
            data_legend_platemap(k) = cellstr(current_drug_treatment);
            
            % mass doubling time
            mass_doublingTime(k) = 1/fit1.m;
            % Cell mass at time zero
            mass_at_time_zero(k) = 2^fit1.b;
            mass_gof(k) = gof.rsquare;
            
            clearvars fit1 gof
            
            if verbose_Plot==true
                figure(fig2)
            end
            [fit1,gof,~] = fit(x,y_cellNum,f,'StartPoint',[1 1],'Robust','on');
            if verbose_Plot==true
                plot(fit1,x,y_cellNum,'or')
                text(str2num((cell2mat(uniTimePoint(1))))+1,max(y_cellNum)-0.5,sprintf('Rsq = %g\nAdj = %g\nSlope = %g\n1/Slope = %g',gof.rsquare,gof.adjrsquare,fit1.m,1/fit1.m))
                title(['Treatment: ' current_drug_treatment])
                legend('off')
            end
            
            % Cell Cycle length from fixed measurements
            cellNum_doublingTime(k) = 1/fit1.m;
            % Number of cells at time zero
            cellNum_at_time_zero(k) = 2^fit1.b;
            cellNum_gof(k) = gof.rsquare;
            
            
            clearvars x y_Mass y_cellNum  idx_Row idx_Col
        end
        
        %% Control
        k=k+1;
        current_control = char(uniControlTreatments(contains(uniControlTreatments,unique_main_conditions(i))));
        [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,current_control));

        if isempty(idx_Row)&&isempty(idx_Col)
            continue
        end
        
        disp(['|----------Working on ' current_control])
        
        if verbose_Plot==true
            position = position+1;
            
            % Plot for Protein Mass
            figure(fig1)
            subplot(size(current_treatment,1)+1,1,position);hold on;
            % Plot for Cell Number
            figure(fig2)
            subplot(size(current_treatment,1)+1,1,position);hold on;
        end
        
        clearvars idx_Row idx_Col
        
        for timepoint = 1:length(uniTimePoint)
            current_timepoint = uniTimePoint(timepoint);
            % Fitting Growth_Rate
            [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,current_control));
            
            if isempty(idx_Row)&&isempty(idx_Col)
                disp('Something is not right with this, will be skipping....')
                continue
            end
            
            for r = 1:length(idx_Row)
                y_Mass(timepoint,r) = (ResultDataStructure.(Bulk_Measure)(idx_Row(r),idx_Col(r),timepoint));
                y_cellNum(timepoint,r) = (ResultDataStructure.Numcells(idx_Row(r),idx_Col(r),timepoint));
            end
        end
        try
            x = repmat(str2num((cell2mat(uniTimePoint))),[size(y_Mass,2) 1]);
        catch
            x = repmat(str2num((char(uniTimePoint))),[size(y_Mass,2) 1]);
        end
        y_Mass = log2(reshape(y_Mass,[size(y_Mass,1)*size(y_Mass,2) 1]));
        y_cellNum = log2(reshape(y_cellNum,[size(y_cellNum,1)*size(y_cellNum,2) 1]));
        
        
        f = fittype('m*x + b');
        if verbose_Plot==true
            figure(fig1)
        end
        [fit1,gof,~] = fit(x,y_Mass,f,'StartPoint',[1 1],'Robust','on');
        if verbose_Plot==true
            plot(fit1,x,y_Mass,'or')
            text(str2num((cell2mat(uniTimePoint(1))))+1,(max(y_Mass)),sprintf('Rsq = %g\nAdj = %g\nSlope = %g\n1/Slope = %g',gof.rsquare,gof.adjrsquare,fit1.m,1/fit1.m))
            title(['Treatment: ' current_control])
            legend('off')
        end
        data_legend_platemap(k) = cellstr(current_control);
        
        % mass doubling time
        mass_doublingTime(k) = 1/fit1.m;
        % Cell mass at time zero
        mass_at_time_zero(k) = 2^fit1.b;
        mass_gof(k) = gof.rsquare;
        
        clearvars fit1 gof
        
        if verbose_Plot==true
            figure(fig2)
        end
        [fit1,gof,~] = fit(x,y_cellNum,f,'StartPoint',[1 1],'Robust','on');
        if verbose_Plot==true
            plot(fit1,x,y_cellNum,'or')
            text(str2num((cell2mat(uniTimePoint(1))))+1,max(y_cellNum),sprintf('Rsq = %g\nAdj = %g\nSlope = %g\n1/Slope = %g',gof.rsquare,gof.adjrsquare,fit1.m,1/fit1.m))
            title(['Treatment: ' current_control])
            legend('off')
        end
        
        % Cell Cycle length from fixed measurements
        cellNum_doublingTime(k) = 1/fit1.m;
        % Number of cells at time zero
        cellNum_at_time_zero(k) = 2^fit1.b;
        cellNum_gof(k) = gof.rsquare;
        
        
        clearvars x y_Mass y_cellNum  idx_Row idx_Col
         
    if verbose_Plot==true
        figure(fig1)
        set(0,'DefaultTextInterpreter','none')
        suptitle(['Protein Mass for: ' char(unique_main_conditions(i))])
        [ax1,h1]=suplabel('Time (Hours)');
        set(h1,'FontSize',15)
        [ax2,h2]=suplabel('log2 Cell Mass','y');
        set(h2,'FontSize',15)
        hold off;
        
        figure(fig2)
        set(0,'DefaultTextInterpreter','none')
        suptitle(['Cell Number for: ' char(unique_main_conditions(i))])
        [ax1,h1]=suplabel('Time (Hours)');
        set(h1,'FontSize',15)
        [ax2,h2]=suplabel('log2 Cell Number','y');
        set(h2,'FontSize',15)
        hold off;
    end
    clearvars x y_Mass y_cellNum fig1 fig2 ax1 ax2 h1 h2 fit1 gof
    
    
    
    
end

clearvars i k

mass_Interest = mass_doublingTime;
cc_Interest = cellNum_doublingTime;

clearvars mass_doublingTime cellNum_doublingTime mass_at_time_zero cellNum_at_time_zero mass_gof cellNum_gof

[map,~,~] = brewermap(size(mass_Interest,2),'Dark2'); 
symbol = {'o','s','*','x','+','d','p','h'};
figure('Name','CCL vs GR'); hold on;
count = 1;current_symbol = char(symbol(randi([1 numel(symbol)])));sz = 5;
for i = 1:size(data_legend_platemap,2) 
    


        y = mass_Interest(i);
        x = cc_Interest(i);
        
        plot(x,y,'--g',...
            'LineWidth',2,...
            'Marker',current_symbol,...
            'MarkerSize',sz,...
            'MarkerEdgeColor',map(count,:),...
            'MarkerFaceColor',map(count,:))
        if ~mod(i,size(data_legend_platemap,2)/size(unique_main_conditions,1))
            count = count + 1;
            current_symbol = char(symbol(randi([1 numel(symbol)])));
            sz = 5;
        else
            sz = sz + 2.5;
        end
        

end
clearvars i sz k y x 

title('Growth Rate vs. Cell Cycle Length'); xlabel('Cell Cycle Length (Hours)'); ylabel('Growth Rate');

legend(reshape(data_legend_platemap(contains(data_legend_platemap,unique_main_conditions)), [size(mass_Interest,1)*size(mass_Interest,2) 1]))
MeanS=mean(cc_Interest(1,1))*mean(mass_Interest(1,1));
plot(10:100,MeanS./(10:100),'k')
plot(10:100,0.75*MeanS./(10:100),'k');
plot(10:100,1.25*MeanS./(10:100),'k');

hold off;

clearvars MeanS map symbol

end % End of Function