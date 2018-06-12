function [ResultDataStructure, uniResults] = Fixed_Plate_Data_Analysis(ResultTable,Check_for_Old_GUI,measurement_name,average_replicates,control_treatment,Row_Treatment,Column_Treatment,Nucleus_Channel,Cell_Cycle_Channel,Cytosol_Channel,Nucleus_Area,Bulk_Measure,verbose_Plot,Plot_Title,MetaRows,MetaCols)

% addpath('R:\Justin_S\Single_Cell_Analysis_Toolkit\functions')
% data = "JOLD";
% if data == "E"
%     % Data from 20180129
%     load('R:\Justin_S\Single_Cell_Analysis_Toolkit\Justin_TEST_Eden_Result_Table_Data\SE\CombinedTable_on_20180502\ResultTable.mat')
%
%     % Temporary Args
%     ChDNA = 1; chGEM = 2; chSE = 3;
%     Nucleus_Channel = 'NInt';
%     Cell_Cycle_Channel = 'NInt';
%     Cytosol_Channel = {'CInt',1};
%     Nucleus_Area = 'NArea';
%     uniWells = unique(ResultTable(:,{'Row','Column'}));
%     measurement_name = 'TimePoint';
%     Row_Treatment = {'Drug'}; Column_Treatment = {'CellLineType'};
%     control_treatment = '30nM DMSO';
%     Bulk_Measure = 'TotalProt';
%
%
% elseif data == "J"
%
%     % Temporary Args
%     Nucleus_Channel = 'Nucleus_DAPI_MeanIntensity';
%     Cell_Cycle_Channel = 'Nucleus_Geminin_MeanIntensity';
%     Cytosol_Channel = 'Cell_SE_MeanIntensity';
%     Nucleus_Area = 'Nucleus_Area';
%     uniWells = unique(ResultTable(:,{'row','column'}));
%     measurement_name = 'TimePoint';
%     Row_Treatment = {'Treatment'}; Column_Treatment = {'Clone'};
%     control_treatment = 'No Dox';
%     Bulk_Measure = 'TotalProt';
%
% elseif data == "JOLD"
%     ChDNA = 1; chGEM = 2; chSE = 3;
%     Nucleus_Channel = 'NInt';
%     Cell_Cycle_Channel = 'NInt';
%     Cytosol_Channel = {'CInt',1};
%     Nucleus_Area = 'NArea';
%     Bulk_Measure = 'TotalProt';
%     Row_Treatment = {'Drug'}; Column_Treatment = {'Percent_FBS'};
%
%     uniWells = unique(ResultTable(:,{'Row','Column'}));
%     measurement_name = 'TimePoint';
%     control_treatment = 'No Dox';
%     Plot_Title = '20180604_Serum_Reduction_Pool_Fixed';
%     MetaRows = 'Drug';
%     MetaCols = 'Percent_FBS';
%     verbose_Plot = 'Verbose Plots';
% end

if any(strcmp('Row',ResultTable.Properties.VariableNames))
    idx = find(strcmp('Row',ResultTable.Properties.VariableNames));
    ResultTable.Properties.VariableNames{idx} = 'row';
end
if any(strcmp('Column',ResultTable.Properties.VariableNames))
    idx = find(strcmp('Column',ResultTable.Properties.VariableNames));
    ResultTable.Properties.VariableNames{idx} = 'column';
end

% If ResultTable is from Old GUI, use default Arguments always known to be defined
if Check_for_Old_GUI==true
    ChDNA = 1; chGEM = 2; chSE = 3;
    Nucleus_Channel = 'NInt';
    Cell_Cycle_Channel = 'NInt';
    Cytosol_Channel = {'CInt',1};
    Nucleus_Area = 'NArea';
end

ResultDataStructure = struct();
ResultDataStructure.PlateMap = cell([6,10]);
ResultDataStructure.PlateMap(cellfun('isempty',ResultDataStructure.PlateMap))={'NaN'};

tmp_Original_ResultTable = ResultTable;

% Initializing important variables
uniWells = unique(ResultTable(:,{'row','column'}));
uniCellTreatments = table2array(unique(ResultTable(:,Column_Treatment),'stable'));
uniWell_Conditions = unique(ResultDataStructure.PlateMap,'stable'); uniWell_Conditions(1) = [];

uniDrugTreatments = table2array(unique(ResultTable(:,Row_Treatment),'stable'));
uniDrugTreatments = uniDrugTreatments(~contains(uniDrugTreatments,control_treatment));

uniTreatments = join(table2array(unique(ResultTable(:,[Column_Treatment,Row_Treatment]),'stable')),', ');
Treatments_w_o_Control = uniTreatments(~contains(uniTreatments,control_treatment));
Control = uniTreatments(contains(uniTreatments,control_treatment));

MetaDataColumns=ResultTable.Properties.VariableNames(find(strcmpi(ResultTable.Properties.VariableNames,'WellConditions')):end);

%% ------------------------------ Main ------------------------------------------------------------
% ResultTable{:,measurement_name} = num2cell(str2double(table2cell(ResultTable(:,measurement_name))));
ResultTable.lGem = mylog((ResultTable{:,Cell_Cycle_Channel}));
ResultTable.EG1=zeros(size(ResultTable.lGem));
ResultTable.LG1=zeros(size(ResultTable.lGem));
ResultTable.G1S=zeros(size(ResultTable.lGem));
ResultTable.S=zeros(size(ResultTable.lGem));
ResultTable.G2=zeros(size(ResultTable.lGem));
ResultTable.Reject=zeros(size(ResultTable.lGem));
ResultTable.numinfield=zeros(size(ResultTable.lGem));
ResultTable.Keep=false(size(ResultTable.lGem));

tmp_ResultTable = sortrows(ResultTable,{measurement_name, 'row', 'column'}, {'ascend'});

uniTimePoint = (unique((tmp_ResultTable{:,measurement_name}) ,'sorted'));

for timepoint = 1:length(uniTimePoint)
    current_timepoint = uniTimePoint(timepoint);
    for well = 1:size(uniWells,1)
        row=table2array(uniWells(well,1));col=table2array(uniWells(well,2));
        FieldName = ['Row: ' num2str(row) ' | Col: ' num2str(col) ' | TimePoint: ' cell2mat(current_timepoint)];
        
        % Find Cells in well at timepoint
        FCells = find( ...
            ResultTable.row==row & ...
            ResultTable.column==col & ...
            contains(ResultTable.(measurement_name),(current_timepoint)));
        try
            DNA = ResultTable.(Nucleus_Channel)(FCells);
        catch
            DNA = ResultTable.(Nucleus_Channel)(FCells,ChDNA);
        end
        lGem = ResultTable.lGem(FCells);
        % Separate Cells into 5 different cell stages
        [idxEG1,idxLG1,idxG1S,idxS,idxG2] = FindStages_VarGem(DNA,lGem,FieldName,'NOimage');
        ResultTable.EG1(FCells(idxEG1))=1;
        ResultTable.LG1(FCells(idxLG1))=1;
        ResultTable.G1S(FCells(idxG1S))=1;
        ResultTable.S(FCells(idxS))=1;
        ResultTable.G2(FCells(idxG2))=1;
        % Discard cells that have abnormal DNA/geminin levels- probably dead or segmentation errors. We are also discarding mitotics here.
        ResultTable.Reject(FCells(~(idxEG1|idxLG1|idxG1S|idxS|idxG2)))=1;
        keepers=FCells(ResultTable.Reject(FCells)==0);
        ResultTable.Keep(keepers)=true;
        % Collect various information about cells
        [ResultDataStructure] = Fixed_Data_Stats_Collection(row,col,timepoint,keepers,ResultTable,Cytosol_Channel,Nucleus_Area,ResultDataStructure);
        % Add plate map to datastructure for future use
        ResultDataStructure.PlateMap{row,col} = char(join(table2array(unique(ResultTable(ResultTable.row==row&ResultTable.column==col,[Column_Treatment,Row_Treatment]))),', '));
        
    end
end

ResultDataStructure.PlateMap(cellfun('isempty',ResultDataStructure.PlateMap))={'NaN'};

%% Plot microplate plots of cell cycle length and cell number
% Create new ResultTable with only cells to keep
ResultTable_cleaned = ResultTable(ResultTable.Keep(:,1)==1,:);
ResultTable_cleaned = removevars(ResultTable_cleaned, {'lGem','EG1','LG1','G1S','S','G2','Reject','numinfield','Keep'});
uniResults = make_uniResults(ResultTable_cleaned,measurement_name);
uniWells = unique(uniResults(:,{'row','column'}));

%%%%%%%% Not good to do this
% uniResults.Properties.VariableNames{6} = 'Treatment'; MetaCols = 'Treatment';

[uniResults,start_idx,end_idx] = Cell_Cycle_Calculation(uniResults,uniWells);

% Plot Microplate Plot for Cell Cycle Length
data_to_plot = 'Cell_Cycle'; Main_Title = 'Cell Cycle Length (Hours)'; color = 'Dark2';rounding_decimal=2;
color = 'cool(6)';
MicroPlate_Plotting(uniResults,uniWells,data_to_plot,color,Main_Title,Plot_Title,MetaRows,MetaCols,rounding_decimal)

if verbose_Plot==true
    
    % Microplate Plot for Cell Number
    for i = start_idx:end_idx
        data_to_plot = char(uniResults.Properties.VariableNames(i));
        Main_Title = ['Cell Number (' data_to_plot ')']; color = 'Spectral';
        MicroPlate_Plotting(uniResults,uniWells,data_to_plot,color,Main_Title,Plot_Title,MetaRows,MetaCols,rounding_decimal)
    end
end


%% ------------------------------ Protein Mass vs.Frequency ---------------------------------------
if all(verbose_Plot==true)
    clearvars x y
    
    for i = 1:size(uniCellTreatments,1)
        for k = 1:size(uniDrugTreatments)
            [idx_Row,idx_Col] = find(...
                ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,[char(uniDrugTreatments(k)) '$']))&...
                ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,char(uniCellTreatments(i)))));
            if isempty(idx_Row)&&isempty(idx_Col)
                continue
            end
            
            fig = figure('Name','Protein Mass');position = 0;
            for timepoint = 1:length(uniTimePoint)
                current_timepoint = uniTimePoint(timepoint);
                position = position+1;
                subplot(2,round(size(uniTimePoint,1)/2),position);hold on;
                
                % Plotting Treatment
                [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,[char(uniCellTreatments(i)) ', ' char(uniDrugTreatments(k))]));
                if isempty(idx_Row)&&isempty(idx_Col)
                    [idx_Row,idx_Col] = find(...
                        ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,[char(uniDrugTreatments(k)) '$']))&...
                        ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,char(uniCellTreatments(i)))));
                end
                
                if isempty(idx_Row)&&isempty(idx_Col)
                    continue
                end
                
                for r = 1:length(idx_Row)
                    x(:,r) = (ResultDataStructure.Paxis{idx_Row(r),idx_Col(r),timepoint});
                    y(:,r) = (ResultDataStructure.Pdensity{idx_Row(r),idx_Col(r),timepoint});
                end
                plot(x,y,'b')
                clearvars x y idx_Row idx_Col
                
                % Plotting Control
                [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,[char(uniCellTreatments(i)) ', ' char(control_treatment)]));
                if isempty(idx_Row)&&isempty(idx_Col)
                    [idx_Row,idx_Col] = find(...
                        ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,[char(uniDrugTreatments(k)) '$']))&...
                        ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,char(uniCellTreatments(i)))));
                end
                
                if isempty(idx_Row)&&isempty(idx_Col)
                    continue
                end
                
                for r = 1:length(idx_Row)
                    x(:,r) = (ResultDataStructure.Paxis{idx_Row(r),idx_Col(r),timepoint});
                    y(:,r) = (ResultDataStructure.Pdensity{idx_Row(r),idx_Col(r),timepoint});
                end
                plot(x,y,'r')
                clearvars x y idx_Row idx_Col
                
                title([cell2mat(current_timepoint) 'Hours'])
                
            end
            set(0,'DefaultTextInterpreter','none')
            suptitle(['Protein Mass: ' char(uniCellTreatments(i)) ' with ' char(uniDrugTreatments(k))])
            [ax1,h1]=suplabel('Protein Mass');
            set(h1,'FontSize',15)
            [ax2,h2]=suplabel('Frequency','y');
            set(h2,'FontSize',15)
            hold off;
        end
    end
end

%% ------------------------------ Growth Rate Estimation ------------------------------------------
% Growth Rate Equation: v = 1/Nt * dMt/dt
clearvars x y_Mass y_cellNum
uniDrugTreatments = table2array(unique(ResultTable(:,Row_Treatment),'stable'));

for i = 1:size(uniCellTreatments,1)
    if verbose_Plot==true
        fig1 = figure('Name','Growth Rate'); fig2 = figure('Name','Cell Num');position = 0;
    end
    disp(['Working on ' char(uniCellTreatments(i))])
    for k = 1:size(uniDrugTreatments)
        [idx_Row,idx_Col] = find(...
            ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,[char(uniDrugTreatments(k)) '$']))&...
            ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,char(uniCellTreatments(i)))));
        if isempty(idx_Row)&&isempty(idx_Col)
            continue
        end
        
        disp(['|----------Working on ' char(uniDrugTreatments(k))])
        
        if verbose_Plot==true
            position = position+1;
            
            % Plot for Protein Mass
            figure(fig1)
            subplot(2,round(size(uniDrugTreatments,1)/2),position);hold on;
            % Plot for Cell Number
            figure(fig2)
            subplot(2,round(size(uniDrugTreatments,1)/2),position);hold on;
        end
        for timepoint = 1:length(uniTimePoint)
            current_timepoint = uniTimePoint(timepoint);
            % Fitting Growth_Rate
            [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,[char(uniCellTreatments(i)) ', ' char(uniDrugTreatments(k))]));
            
            if isempty(idx_Row)&&isempty(idx_Col)
                [idx_Row,idx_Col] = find(...
                    ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,char(uniDrugTreatments(k))))&...
                    ~cellfun(@isempty,regexp(ResultDataStructure.PlateMap,char(uniCellTreatments(i)))));
            end
            
            if isempty(idx_Row)&&isempty(idx_Col)
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
            text(0,(max(y_Mass)),sprintf('Rsq = %g\nAdj = %g',gof.rsquare,gof.adjrsquare))
            title(['Cell Line: ' char(uniCellTreatments(i)) ' | Treatment: ' char(uniDrugTreatments(k))])
        end
        data_legend_platemap(k,i) = cellstr([char(uniCellTreatments(i)) ', ' char(uniDrugTreatments(k))]);
        
        % mass doubling time
        mass_doublingTime(k,i) = 1/fit1.m;
        % Cell mass at time zero
        mass_at_time_zero(k,i) = 2^fit1.b;
        mass_gof(k,i) = gof.rsquare;
        
        if verbose_Plot==true
            figure(fig2)
        end
        [fit1,gof,~] = fit(x,y_cellNum,f,'StartPoint',[1 1],'Robust','on');
        if verbose_Plot==true
            plot(fit1,x,y_cellNum,'or')
            text(0,max(y_cellNum),sprintf('Rsq = %g\nAdj = %g',gof.rsquare,gof.adjrsquare))
            title(['Cell Line: ' char(uniCellTreatments(i)) ' | Treatment: ' char(uniDrugTreatments(k))])
        end
        
        % Cell Cycle length from fixed measurements
        cellNum_doublingTime(k,i) = 1/fit1.m;
        % Number of cells at time zero
        cellNum_at_time_zero(k,i) = 2^fit1.b;
        cellNum_gof(k,i) = gof.rsquare;
        
        
        clearvars x y_Mass y_cellNum  idx_Row idx_Col
        
    end
    
    if verbose_Plot==true
        figure(fig1)
        set(0,'DefaultTextInterpreter','none')
        suptitle(['Protein Mass for: ' char(uniCellTreatments(i))])
        [ax1,h1]=suplabel('Time (Hours)');
        set(h1,'FontSize',15)
        [ax2,h2]=suplabel('log2 Cell Mass','y');
        set(h2,'FontSize',15)
        hold off;
        
        figure(fig2)
        set(0,'DefaultTextInterpreter','none')
        suptitle(['Cell Number for: ' char(uniCellTreatments(i))])
        [ax1,h1]=suplabel('Time (Hours)');
        set(h1,'FontSize',15)
        [ax2,h2]=suplabel('log2 Cell Number','y');
        set(h2,'FontSize',15)
        hold off;
    end
    clearvars x y_Mass y_cellNum
end

clearvars i k

mass_Interest = mass_doublingTime;
% mass_Interest = mass_doublingTime(2:3,1:2); % For Eden
% cc_Interest = cellNum_doublingTime(2:3,1:2);
% [siCON siLKB1 - 50nM Tor; siCON siLKB1 - 30nM Rap ; siCON siLKB1 - DMSO ]
% cc_Interest = [mean([44,40,42,44]) mean([106,104,102,85]); mean([26,28,27,28]) mean([42,42,42,43]);  mean([19,19,20,21]) mean([25,24,23,23])];
% cc_Interest = [mean([26,28,27,28]) mean([42,42,42,43]);  mean([19,19,20,21]) mean([25,24,23,23])]; % For Eden
cc_Interest = cellNum_doublingTime;


% [map,~,~] = brewermap(size(uniCellTreatments,1),'Dark2'); % Original
[map,~,~] = brewermap(size(mass_Interest,2),'Dark2'); % Testing for Eden
symbol = {'o','s','*','x','+','d','p','h'};
figure('Name','CCL vs GR'); hold on;
% for i = 1:size(uniCellTreatments,1) % Original
for i = 1:size(mass_Interest,2) %Testing for Eden
    sz = 5;
    
    %     for k = 1:size(uniDrugTreatments)
    for k = 1:size(mass_Interest,1)
        %         y = mass_doublingTime(k,i);
        %         x = cellNum_doublingTime(k,i);
        
        y = mass_Interest(k,i);
        x = cc_Interest(k,i);
        
        
        plot(x,y,'--g',...
            'LineWidth',2,...
            'Marker',char(symbol(i)),...
            'MarkerSize',sz,...
            'MarkerEdgeColor',map(i,:),...
            'MarkerFaceColor',map(i,:))
        sz = sz + 2.5;
        
    end
end
title('Growth Rate vs. Cell Cycle Length'); xlabel('Cell Cycle Length (Hours)'); ylabel('Growth Rate');
%   legend({'siCON, 50nM TOR','siCON, 30nM Rap','siCON, 30nM DMSO','siLKB1, 50nM TOR','siLKB1, 30nM Rap','siLKB1, 30nM DMSO'})
% legend({'siCON, 30nM Rap','siCON, 30nM DMSO','siLKB1, 30nM Rap','siLKB1, 30nM DMSO'})
%   legend({'+Puro1, No Dox', '+Puro1, Dox1000', '+Puro2, No Dox',  '+Puro2, Dox1000', '+Puro3, No Dox',  '+Puro3, Dox1000', 'Pool, No Dox',  'Pool, Dox1000'})
%     legend({'cycE Delta, No Dox','cycE Delta, Dox50','cycE Delta, Dox100'})
legend(reshape(data_legend_platemap, [size(mass_Interest,1)*size(mass_Interest,2) 1]))
MeanS=mean(cc_Interest(1,:))*mean(mass_Interest(1,:));
plot(10:100,MeanS./(10:100),'k')
plot(10:100,0.75*MeanS./(10:100),'k');
plot(10:100,1.25*MeanS./(10:100),'k');

hold off;

%% Scatterplot CCL
if average_replicates==true
    % CCL
    color_list = distinguishable_colors(60,[0 0.5 0 ]);
    figure('Name', 'CCL ScatterPlot'); hold on; start_point = 1;end_point = size(cc_Interest,1);
    for yy = 1:size(cc_Interest,2)
        
        y = cc_Interest(:,yy);
        x = start_point:end_point;
        plot(x, y, 'o','MarkerEdgeColor','b','MarkerFaceColor',color_list(yy,:))
        
        txt1 = join(horzcat(repelem("CCL: ",size(y,1))', num2str(y)));
        labelpoints(x,y,txt1,'N',0.2,1)
        
        start_point = start_point + size(cc_Interest,1);
        end_point = end_point + size(cc_Interest,1);
    end
    x_labels = reshape(data_legend_platemap, [size(cc_Interest,1)*size(cc_Interest,2) 1]);
    ax = gca;
    ax.XTick = 1:length(x_labels);
    ax.XTickLabel = x_labels;
    ax.XTickLabelRotation = 45;
    title(['Cell Cycle Length for: ' Plot_Title],'Interpreter', 'none');ylabel('Cell Cycle (Hours)');xlabel('Well Condition')
    grid on;
    hold off;
    
    % GR
    color_list = distinguishable_colors(60,[0 0.5 0 ]);
    figure('Name','GR ScatterPlot'); hold on; start_point = 1;end_point = size(mass_Interest,1);
    for yy = 1:size(mass_Interest,2)
        
        y = mass_Interest(:,yy);
        x = start_point:end_point;
        plot(x, y, 'o','MarkerEdgeColor','b','MarkerFaceColor',color_list(yy,:))
        
        txt1 = join(horzcat(repelem("GR: ",size(y,1))', num2str(y)));
        labelpoints(x,y,txt1,'N',0.2,1)
        
        start_point = start_point + size(mass_Interest,1);
        end_point = end_point + size(mass_Interest,1);
    end
    x_labels = reshape(data_legend_platemap, [size(mass_Interest,1)*size(mass_Interest,2) 1]);
    ax = gca;
    ax.XTick = 1:length(x_labels);
    ax.XTickLabel = x_labels;
    ax.XTickLabelRotation = 45;
    title(['Growth Rate for: ' Plot_Title],'Interpreter', 'none');ylabel('Cell Cycle (Hours)');xlabel('Well Condition')
    grid on;
    hold off;
    
end
% %% Cell number
%
% ResultDataStructure.Numcells(:,:,3)
%
%
% %%  ------------------------------ G1 Length --------------------------------
%
% % ResultTable.row = num2str(ResultTable.row);
% % ResultTable.column = num2str(ResultTable.column);
% ResultTable = sortrows(ResultTable, {'TimePoint','row','column'},'ascend');
%
% uniWells = unique(ResultTable(:,{'row','column',measurement_name,MetaDataColumns{:}}),'stable');
%
%
%
% for i = 1:size(uniWells,1)
%
%    currentWell = table2cell(uniWells(i,3:end)); row = table2array(uniWells(i,1)); col = table2array(uniWells(i,2));
%
%    DNA = ResultTable.Nucleus_DAPI_MeanIntensity(all(ResultTable.row==row & ResultTable.column==col & contains(table2cell(ResultTable(:,{measurement_name,meta_info{:}})),currentWell),2));
%
%    figure(900);clf;hold on;
%    histogram(DNA)
%    set(gca, 'FontSize', 12); xlabel('Nuclear DNA'); ylabel('Frequency');
%    title(['Row: ' num2str(row) ' | Col: ' num2str(col) ' | TimePoint: ' char(table2array(uniWells(i,3)))])
%    xlim([prctile(DNA, 0.09) prctile(DNA, 98.7)]);
% %    pause(0.001)
%    hold off;
%
%
%
% end





end


