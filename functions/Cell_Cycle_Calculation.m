function [uniResults] = Cell_Cycle_Calculation(uniResults,uniWells)

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


%% Extracts Time Points
TP_Headers = uniResults.Properties.VariableNames(start_idx:end_idx)';
MatchExpression = 'TP_(\d+)_Hr';
Tokens = regexp(TP_Headers,MatchExpression,'tokens');
TimePoint = cell(size(Tokens,1),1);
for tok = 1:size(Tokens,1)
    TimePoint(tok,1) = num2cell(str2num(cell2mat(Tokens{tok,1}{1,1})));
end

x = unique(cell2mat(TimePoint),'stable');
Doubling_Time=cell(size(uniResults,1),1);
Cell_Cycle=cell(size(uniResults,1),1);

%% loop over all wells to calculate cell cyle
for well = 1:size(uniWells,1)
    if any(contains(uniResults.Properties.VariableNames, 'row') | contains(uniResults.Properties.VariableNames, 'column'))
        row = uniWells.row(well); col=uniResults.column(well);
        disp(['Calculating... ' '|Row: ' num2str(uniWells.row(well)) '	|Col: ' num2str(uniWells.column(well)) '	|Well Info: ' char(uniResults.WellConditions(well))])
        y = log2(table2array(uniResults(uniResults.row==row&uniResults.column==col,start_idx:end_idx)))';
        f = fittype('m*x + b');
        %     options = fitoptions(f);
        %     options = fitoptions('Method', 'LinearLeastSquares','Robust', 'Bisquare');
        [fit1,~,~] = fit(x,y,f,'StartPoint',[1 1],'Robust','on');
        m = coeffvalues(fit1); % Slope
        Doubling_Time(well,1)=num2cell(m(2));
        Cell_Cycle(well,1)=num2cell(round((1/m(2))));
        clearvars fit1
    else
        disp(['Calculating...   |Well Info: ' char(uniWells(well))])
        y = log2(table2array(uniResults(contains(uniResults.WellConditions,uniWells(well)),start_idx:end_idx)))';
        f = fittype('m*x + b');
        %     options = fitoptions(f);
        %     options = fitoptions('Method', 'LinearLeastSquares','Robust', 'Bisquare'); 
        [fit1,~,~] = fit(x,y,f,'StartPoint',[1 1],'Robust','on');
        m = coeffvalues(fit1); % Slope
        Doubling_Time(well,1)=num2cell(m(2));
        Cell_Cycle(well,1)=num2cell(round((1/m(2))));
        clearvars fit1
    end 
end

%% Store Results into uniResults Table
uniResults.Doubling_Time=cell2mat(Doubling_Time);
uniResults.Cell_Cycle=cell2mat(Cell_Cycle);

end %End of Function