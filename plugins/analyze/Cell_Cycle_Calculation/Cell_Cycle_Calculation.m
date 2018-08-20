function [uniResults,start_idx,end_idx] = Cell_Cycle_Calculation(uniResults,uniWells,verbose_Plot,total_measurement,varargin)


%% Get column indexes for TP_{time}_Hr headers
count = zeros(1,size(uniResults.Properties.VariableNames,2))*nan;
Time_Points = cell(1,size(uniResults.Properties.VariableNames,2));
for i = 1:size(uniResults.Properties.VariableNames,2)
    if ~isempty(cell2mat(regexp(uniResults.Properties.VariableNames(i),'(TP_\d+_Hr)|(mean_TP_\d+_Hr)')))
        count(1,i) = i;
        Time_Points(1,i) = uniResults.Properties.VariableNames(i);
    end
end
count(isnan(count))=[];
start_idx = count(1); end_idx = count(end); clearvars i count
meta_info = uniResults.Properties.VariableNames(3:start_idx-1);

%% Extracts Time Points
TP_Headers = uniResults.Properties.VariableNames(start_idx:end_idx)';
MatchExpression = 'TP_(\d+)_Hr';
Tokens = regexp(TP_Headers,MatchExpression,'tokens');
TimePoint = cell(size(Tokens,1),1);
for tok = 1:size(Tokens,1)
    TimePoint(tok,1) = num2cell(str2num(cell2mat(Tokens{tok,1}{1,1})));
end

x = unique(cell2mat(TimePoint),'stable');
Doubling_Time=cell(size(uniWells,1),1);
Cell_Cycle=cell(size(uniWells,1),1);

Fig_Num = 1;
if verbose_Plot == true
    figure('Name','Log2 Fitting');hold on;position = 1;
    suptitle(['Fits for: ' total_measurement ' ' num2str(Fig_Num)])
end
%% loop over all wells to calculate cell cyle
for well = 1:size(uniWells,1)
    % old if below varagin is empty if DPC aquisition FIX THIS
    %     if any(contains(uniResults.Properties.VariableNames, 'row') | contains(uniResults.Properties.VariableNames, 'column')) & ~contains(varargin,'Averaged')
    try
        %         if any(contains(uniResults.Properties.VariableNames, 'row') | contains(uniResults.Properties.VariableNames, 'column'))
        row = uniWells.row(well); col=uniResults.column(well);
        disp(['Calculating... ' '|Row: ' num2str(uniWells.row(well)) '	|Col: ' num2str(uniWells.column(well)) '	|Well Info: ' char(uniResults.WellConditions(well))])
        y = log2(table2array(uniResults(uniResults.row==row&uniResults.column==col,start_idx:end_idx)))';
        f = fittype('m*x + b');
        %     options = fitoptions(f);
        %     options = fitoptions('Method', 'LinearLeastSquares','Robust', 'Bisquare');
        if size(y,2)>1
            y = median(y,2);
        end
        [fit1,gof,~] = fit(x,y,f,'StartPoint',[1 1],'Robust','on');
        
        if verbose_Plot == true
            if position == 10
                Fig_Num = Fig_Num +1;
                figure('Name','Log2 Fitting');hold on;position = 1;
                suptitle(['Fits for: ' total_measurement ' ' num2str(Fig_Num)])
            end
            subplot(2,5,position)
            plot(fit1,x,y,'bo')
            xlabel('Time Point (Hour)');ylabel('Cell Number');title(['Row: ' num2str(uniWells.row(well)) '	| Col: ' num2str(uniWells.column(well))])
            y_axis_limits = ylim;
            if (y_axis_limits(2) - y_axis_limits(1)) <= 1.5
                diff = 0.1;
            else
                diff = 0.5;
            end
            text(x(1)+0.5,(y_axis_limits(2)-diff),sprintf('Rsq = %g\nAdj = %g',gof.rsquare,gof.adjrsquare))
            legend('off')
            position = position + 1;
        end
        
        m = coeffvalues(fit1); % Slope
        Doubling_Time(well,1)=num2cell(m(2));
        Cell_Cycle(well,1)=num2cell(((1/m(2))));
        clearvars fit1 y_axis_limits diff
    catch
        
        disp(['Calculating...   |Well Info: ' char(uniWells(well))])
        all_y = table2cell(uniResults(contains(uniResults.WellConditions,uniWells(well)),start_idx:end_idx));
        tmp_y = (all_y{1,1});
        for i = 2:length(all_y)
            tmp_y = [tmp_y (all_y{1,i})];
        end
        y = log2(tmp_y)';
        
        x2 = repelem(x,length(all_y{1,1}));
        f = fittype('m*x + b');
        %     options = fitoptions(f);
        %     options = fitoptions('Method', 'LinearLeastSquares','Robust', 'Bisquare');
        [fit1,~,~] = fit(x2,y,f,'StartPoint',[1 1],'Robust','on');
        
        if verbose_Plot == true
            if position == 10
                Fig_Num = Fig_Num +1;
                figure('Name','Log2 Fitting');hold on;position = 1;
                suptitle(['Fits for: ' total_measurement ' ' num2str(Fig_Num)])
            end
            subplot(2,5,position)
            plot(fit1,x,y,'bo')
            xlabel('Time Point (Hour)');ylabel('Cell Number');title([char(uniResults.WellConditions(well))])
            y_axis_limits = ylim;
            if (y_axis_limits(2) - y_axis_limits(1)) <= 1.5
                diff = 0.1;
            else
                diff = 0.5;
            end
            text(x(1)+0.5,(y_axis_limits(2)-diff),sprintf('Rsq = %g\nAdj = %g',gof.rsquare,gof.adjrsquare))
            legend('off')
            position = position + 1;
        end
        
        m = coeffvalues(fit1); % Slope
        Doubling_Time(well,1)=num2cell(m(2));
        Cell_Cycle(well,1)=num2cell(((1/m(2))));
        clearvars fit1 y_axis_limits diff
        
    end
end

%% Store Results into uniResults Table
uniResults.Doubling_Time=cell2mat(Doubling_Time);
uniResults.Cell_Cycle=cell2mat(Cell_Cycle);

end %End of Function