function [ResultDataStructure, uniResults,Cell_Cycle_Params] = Fixed_Plate_Data_Analysis(Cell_Cycle_Params)

% addpath('R:\Justin_S\Single_Cell_Analysis_Toolkit\functions')
% addpath('R:\Justin_S\Single_Cell_Analysis_Toolkit\plugins\analyze\Cell_Cycle_Calculation')
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
%     verbose_Plot = true
%     Plot_Title = "20180122_Eden"
% MetaRows = {'Drug'}; MetaCols = {'CellLineType'};
% Check_for_Old_GUI = true;

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
%     MetaRows = 'Induction_Treatment';
%     MetaCols = {'Cell_Line','Growth_Condition','Drug_Treatment'};
% Row_Treatment = {'Induction_Treatment'};
% Column_Treatment = {'Cell_Line','Growth_Condition','Drug_Treatment'};
%     verbose_Plot = 'Verbose Plots';
%     Check_for_Old_GUI = true;
% end

%% ------------------------------ Extract Params from Cell Cycle Parameters Structure -------------
ResultTable = Cell_Cycle_Params.ResultTable;
Check_for_Old_GUI = Cell_Cycle_Params.Check_for_Old_GUI;
measurement_name = Cell_Cycle_Params.measurement_name;
average_replicates = Cell_Cycle_Params.average_replicates;
control_treatment = Cell_Cycle_Params.control_treatment;
Row_Treatment = Cell_Cycle_Params.Row_Treatment;
Column_Treatment = Cell_Cycle_Params.Column_Treatment;
Nucleus_Channel = Cell_Cycle_Params.Nucleus_Channel;
Cell_Cycle_Channel = Cell_Cycle_Params.Cell_Cycle_Channel;
Cytosol_Channel = Cell_Cycle_Params.Cytosol_Channel;
Nucleus_Area = Cell_Cycle_Params.Nucleus_Area;
Bulk_Measure = Cell_Cycle_Params.Bulk_Measure;
verbose_Plot = Cell_Cycle_Params.verbose_Plot;
Plot_Title = Cell_Cycle_Params.Plot_Title;
MetaRows = Cell_Cycle_Params.MetaRows;
MetaCols = Cell_Cycle_Params.MetaCols;


% If Row variable name and Column variable name in RestulsTable is captalized, convert to lowercase
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
    Cytosol_Channel = {'CInt',chSE};
    Nucleus_Area = 'NArea';
end

% Initialize ResultDataStructure to store calculated stats and other information
ResultDataStructure = struct();
ResultDataStructure.PlateMap = cell([6,10]);
ResultDataStructure.PlateMap(cellfun('isempty',ResultDataStructure.PlateMap))={'NaN'};

% Store original ResultTable in tmp var
tmp_Original_ResultTable = ResultTable;

% Initializing important variables
uniWells = unique(ResultTable(:,{'row','column'}));
uniColumnTreatments = table2array(unique(ResultTable(:,Column_Treatment),'stable'));


uniRowTreatments = table2array(unique(ResultTable(:,Row_Treatment),'stable'));
uniWellTreatments = unique(ResultTable.WellConditions,'stable');
uniWellTreatments_with_Control = uniWellTreatments(contains(uniWellTreatments,control_treatment));
uniWellTreatments = uniWellTreatments(~contains(uniWellTreatments,control_treatment));

keySet = {'Control', 'Drug_Treatments'};
value = {uniWellTreatments_with_Control, uniWellTreatments};
Treatments = containers.Map(keySet,value);

% uniTreatments = join(table2array(unique(ResultTable(:,[Column_Treatment,Row_Treatment]),'stable')),', ');
% Treatments_w_o_Control = uniTreatments(~contains(uniTreatments,control_treatment));
% Control = uniTreatments(contains(uniTreatments,control_treatment));

ResultTable_Headers = ResultTable.Properties.VariableNames;
[~, idxCol_WellCondition] =  find(strcmp(ResultTable_Headers,'WellConditions'));
tmp = table2cell(ResultTable(:,idxCol_WellCondition:end));
tmp = regexprep(tmp, '\W$', '');
[~,idxCol] = find(strcmp(tmp,control_treatment)); clearvars tmp;
idxCol_containing_Control = unique(idxCol,'stable');
Control_Col = char(ResultTable_Headers(idxCol_WellCondition+idxCol_containing_Control-1));
% Get the total number of unique specific conditions to group by -- to colour code the same experiement testing different conditions
unique_measurement_count = size(unique(ResultTable(:,{Control_Col}),'stable'),1);
Current_End_Col = char(ResultTable_Headers(end));
ResultTable = movevars(ResultTable, Control_Col, 'After', Current_End_Col);
ResultTable_Headers = ResultTable.Properties.VariableNames;
Well_Meta_Cols = ResultTable_Headers(find(strcmp(ResultTable_Headers,'Well_Info')==1):end);

MetaDataColumns = ResultTable.Properties.VariableNames(find(strcmpi(ResultTable.Properties.VariableNames,'WellConditions')):end);


Fixed_Cells_Args = struct();
Fixed_Cells_Args.Treatments = Treatments;
Fixed_Cells_Args.uniColumnTreatments = uniColumnTreatments;
Fixed_Cells_Args.uniRowTreatments = uniRowTreatments;
Fixed_Cells_Args.MetaDataColumns = MetaDataColumns;



%% ------------------------------ Main ------------------------------------------------------------
% ResultTable{:,measurement_name} = num2cell(str2double(table2cell(ResultTable(:,measurement_name))));
if Check_for_Old_GUI==true
    ResultTable.lGem = mylog((ResultTable.(Cell_Cycle_Channel)(:,chGEM)));
else
     ResultTable.lGem = mylog((ResultTable{:,Cell_Cycle_Channel}));
end
ResultTable.EG1=zeros(size(ResultTable.lGem));
ResultTable.LG1=zeros(size(ResultTable.lGem));
ResultTable.G1S=zeros(size(ResultTable.lGem));
ResultTable.S=zeros(size(ResultTable.lGem));
ResultTable.G2=zeros(size(ResultTable.lGem));
ResultTable.Reject=zeros(size(ResultTable.lGem));
ResultTable.numinfield=zeros(size(ResultTable.lGem));
ResultTable.Keep=false(size(ResultTable.lGem));

% Sort ResultTable based on Measurement, then row and the column
tmp_ResultTable = sortrows(ResultTable,{measurement_name, 'row', 'column'}, {'ascend'});

% Get unique measurement (i.e. timepoints)
uniTimePoint = (unique((tmp_ResultTable{:,measurement_name}) ,'sorted'));
Fixed_Cells_Args.TimePoints = uniTimePoint;

frame_counter = 1; 
for timepoint = 1:length(uniTimePoint)
    current_timepoint = uniTimePoint(timepoint);
    for well = 1:size(uniWells,1)
        row=table2array(uniWells(well,1));col=table2array(uniWells(well,2));
        FieldName = ['Row: ' num2str(row) ' | Col: ' num2str(col) ' | TimePoint: ' cell2mat(current_timepoint)];
        
        % Find Cells in well at timepoint
        FCells = find( ...
            ResultTable.row==row & ...
            ResultTable.column==col & ...
            strcmp(ResultTable.(measurement_name),(current_timepoint)));
        try
            DNA = ResultTable.(Nucleus_Channel)(FCells);
        catch
            DNA = ResultTable.(Nucleus_Channel)(FCells,ChDNA);
        end
        lGem = ResultTable.lGem(FCells);
        if verbose_Plot==false
            plot_stages = 'image';
        else
            plot_stages = 'NOimage';
        end
        % Separate Cells into 5 different cell stages
        if ~exist('frame','var')
            [idxEG1,idxLG1,idxG1S,idxS,idxG2,~] = FindStages_VarGem(DNA,lGem,FieldName,frame_counter,plot_stages);
        else
            [idxEG1,idxLG1,idxG1S,idxS,idxG2,frame] = FindStages_VarGem(DNA,lGem,FieldName,frame_counter,plot_stages,frame);
        end
        ResultTable.EG1(FCells(idxEG1))=1;
        ResultTable.LG1(FCells(idxLG1))=1;
        ResultTable.G1S(FCells(idxG1S))=1;
        ResultTable.S(FCells(idxS))=1;
        ResultTable.G2(FCells(idxG2))=1;
        % Discard cells that have abnormal DNA/geminin levels- probably dead or segmentation errors. We are also discarding mitotics here.
        ResultTable.Reject(FCells(~(idxEG1|idxLG1|idxG1S|idxS|idxG2)))=1;
        keepers=FCells(ResultTable.Reject(FCells)==0);
        ResultTable.Keep(keepers)=true;
        
        
        % Plot DNA distribution WIP
        
%         Ch_for_Nucleus_int = {'NInt',1};
%         DNA = ResultTable.(char(Ch_for_Nucleus_int(1)))(keepers,cell2mat(Ch_for_Nucleus_int(2)));
%         figure(100); histogram(DNA)
%         title('Histogram of DNA content')
%         set(gca, 'FontSize', 12); xlabel('Nuclear DNA'); ylabel('Frequency');
%         xlim([prctile((ResultTable.NInt(:,chDNA)), 0.09) prctile((ResultTable.NInt(:,chDNA)), 98.7)]);
        
        % Collect various information about cells
        [ResultDataStructure] = Fixed_Data_Stats_Collection(row,col,timepoint,keepers,ResultTable,Cytosol_Channel,Nucleus_Area,ResultDataStructure);
        % Add plate map to datastructure for future use
        ResultDataStructure.PlateMap{row,col} = char(join(table2array(unique(ResultTable(ResultTable.row==row&ResultTable.column==col,Well_Meta_Cols))),', '));
        frame_counter = frame_counter + 1;
    end
end

ResultDataStructure.PlateMap(cellfun('isempty',ResultDataStructure.PlateMap))={'NaN'};

uniWell_Conditions = unique(ResultDataStructure.PlateMap,'stable'); uniWell_Conditions(1) = [];
Fixed_Cells_Args.uniWell_Conditions = uniWell_Conditions;

Cell_Cycle_Params.Nucleus_Channel = Nucleus_Channel;
Cell_Cycle_Params.Cell_Cycle_Channel = Cell_Cycle_Channel;
Cell_Cycle_Params.Cytosol_Channel = Cytosol_Channel;
Cell_Cycle_Params.ResultDataStructure = ResultDataStructure;

% Plot Cell Cycle Stage Plot
if verbose_Plot==false
%     [h, w, p] = size(frame(1).cdata);  % use 1st frame to get dimensions
%     hf = figure;
%     % resize figure based on frame's w x h, and place at (150, 150)
%     set(hf, 'position', [150 150 w h]);
%     axis off
%     movie(hf,frame,1,1);

    answer = questdlg('Would you like to save a gif of Cell Cycle Stage Plot?', ...
        'Save gif prompt', ...
        'Yes','No','No');
    % Handle response
    switch answer
        case 'Yes'
            disp([answer ' saving gif of Cell Cycle Stage plot.'])
            save_dir = uigetdir(pwd,'Select Directory to Save Cell Cycle Stage plot In');
            date_str = datestr(now,'yyyymmddTHHMMSS');
            gif_filename = sprintf('%s/Cell_Cycle_Stage_Plot_%s.gif', save_dir, date_str);
            movie2gif(frame, gif_filename, 'LoopCount', Inf, 'DelayTime', 0.5)

        case 'No'
            disp([answer ' will not save gif of Cell Cycle Stage plot.'])

    end


end

%% ------------------------------ Plot microplate plots of cell cycle length and cell number ------------------------------

% Create new ResultTable with only cells to keep
ResultTable_cleaned = ResultTable(ResultTable.Keep(:,1)==1,:);
ResultTable_cleaned = removevars(ResultTable_cleaned, {'lGem','EG1','LG1','G1S','S','G2','Reject','numinfield','Keep'});
ResultDataStructure.ResultTable = ResultTable_cleaned;
total_measurement = 'Cell Number';
[~,uniResults,~] = make_uniResults(ResultTable_cleaned,measurement_name, control_treatment, total_measurement);
uniWells = unique(uniResults(:,{'row','column'}));

%%%%%%%% Not good to do this
% uniResults.Properties.VariableNames{6} = 'Treatment'; MetaCols = 'Treatment';

[uniResults,start_idx,end_idx] = Cell_Cycle_Calculation(uniResults,uniWells,verbose_Plot,'CellNumber');

% Plot Microplate Plot for Cell Cycle Length
data_to_plot = 'Cell_Cycle'; Main_Title = 'Cell Cycle Length (Hours)'; color = 'Dark2';rounding_decimal=2;
color = 'cool(6)';
MicroPlate_Plotting(uniResults,uniWells,data_to_plot,color,Main_Title,Plot_Title,MetaRows,MetaCols,rounding_decimal)

if verbose_Plot==true
    
    % Microplate Plot for Cell Number
    for i = start_idx:end_idx
        data_to_plot = char(uniResults.Properties.VariableNames(i));
        Main_Title = ['Cell Number (' data_to_plot ')']; color = 'jet(6)';
        MicroPlate_Plotting(uniResults,uniWells,data_to_plot,color,Main_Title,Plot_Title,MetaRows,MetaCols,rounding_decimal)
    end
end

%% ------------------------------ User pick what samples they want results for ------------------------------
% Get user to specify which wells are control wells
[fh,tmp] = Get_User_Desired_Labels(ResultDataStructure.PlateMap);

Controls = ResultDataStructure.PlateMap(unique(tmp.UserData.datatable_row), unique(tmp.UserData.datatable_col))';
Controls = unique(reshape(Controls,[(size(Controls,1)*size(Controls,2)),1]));

Treatments = unique(ResultDataStructure.PlateMap(~contains(ResultDataStructure.PlateMap,Controls)&...
    ~contains(ResultDataStructure.PlateMap,'NaN')));

% tmp = Get_User_Desired_Labels(uniColumnTreatments);
% uniColumnTreatments = uniColumnTreatments(unique(tmp.UserData.datatable_row), unique(tmp.UserData.datatable_col));
% Fixed_Cells_Args.uniColumnTreatments = uniColumnTreatments;
% clearvars tmp
% tmp = vertcat(Treatments('Control'),Treatments('Drug_Treatments'));
% tmp1 = Get_User_Desired_Labels(tmp);
% tmp2 = tmp(unique(tmp1.UserData.datatable_row), unique(tmp1.UserData.datatable_col));
% tmpCon = tmp2(contains(tmp2,Treatments('Control')));
% tmpDrugs = tmp2(contains(tmp2,Treatments('Drug_Treatments')));
% keySet = {'Control', 'Drug_Treatments'};
% value = {tmpCon, tmpDrugs};
keySet = {'Control', 'Drug_Treatments'};
value = {Controls,Treatments};
Treatments = containers.Map(keySet,value);
Fixed_Cells_Args.Treatments = Treatments;
clearvars tmp
close(fh)

uniWell_Conditions = uniWell_Conditions((contains(uniWell_Conditions,Treatments('Control'))|contains(uniWell_Conditions,Treatments('Drug_Treatments')))&contains(uniWell_Conditions,uniColumnTreatments));

%% ------------------------------ Protein Mass vs.Frequency ---------------------------------------
if all(verbose_Plot==true)
    Protein_Content_Distribution(ResultDataStructure,Fixed_Cells_Args,Cell_Cycle_Params)
end

%% ------------------------------ Growth Rate Estimation ------------------------------------------
[mass_Interest,cc_Interest,data_legend_platemap] = Growth_Rate_Estimation(ResultDataStructure,Cell_Cycle_Params,Fixed_Cells_Args,Bulk_Measure,verbose_Plot);

%% ------------------------------ Scatterplot CCL ------------------------------------------
if average_replicates==true

    linear_var_platemap = reshape(data_legend_platemap, [size(cc_Interest,1)*size(cc_Interest,2) 1]);
    
    
    ResultTable_Conditions = [{'Well_Info'},Column_Treatment,Row_Treatment(1)];
    
    fig = uifigure('Position',[100 100 500 500]);
    
    % Create uilabel
        text = sprintf('%s\n%s\n%s','Select which meta-column you would like to separate your data by.','This will separate your data into different plots based on unique cases','in the meta-column you select.');
        Description_label = uilabel(fig,...
            'Text',text,'Position',[20 80 450 750]);
        Description_label.FontSize = 14;
    
    % Create list box
    Group_Plotting_List = uilistbox(fig,...
        'Position',[20 20 350 400],...
        'Items',[{'Well_Info'},Column_Treatment,Row_Treatment(1)]);
    
    btn = uibutton(fig,...
               'push',...
               'Text', 'OK',...
               'Position',[380,100, 100, 22],...
               'ButtonPushedFcn', @(btn, event) ButtonPushed(fig,'invisible','resume'));
    
    uiwait(fig)
    Group_by_Value = Group_Plotting_List.Value;

    unique_Grouping = unique(ResultTable_cleaned.(Group_by_Value),'stable');

    for i = 1:size(unique_Grouping,1)
        fprintf('Working on: %s\n', unique_Grouping{i});
        
        group = linear_var_platemap(contains(linear_var_platemap,unique_Grouping(i)));
        Control_bool_idx = (contains(group,control_treatment));
        if find(Control_bool_idx) ~= 1
            group = [group(Control_bool_idx), group(~Control_bool_idx)]';
        end
        data_order_to_process = group;
%         data_order_to_process= reorderlist(group);
        
        % CCL
        keySet = reshape(data_legend_platemap, [size(cc_Interest,1)*size(cc_Interest,2) 1]);
        valueSet = reshape(cc_Interest, [size(cc_Interest,1)*size(cc_Interest,2) 1]);
        Cell_Cycle_Length_Map = containers.Map(keySet,valueSet);
        
        clearvars keySet valueSet
        
        Figure_Name = 'CCL ScatterPlot';
        num_Points = double(size(group,1));
        num_Points_to_Group = unique_measurement_count;
        data_Map = Cell_Cycle_Length_Map;
        text_point_label = "CCL: ";
        plot_title = ['Cell Cycle Length for: ' Plot_Title '_' char(unique_Grouping(i))];
        y_label = 'Cell Cycle (Hours)';
        x_label = 'Well Condition';
        
        dynamic_Scatter_Plot(Figure_Name, data_Map, data_order_to_process, num_Points, num_Points_to_Group, text_point_label, plot_title, y_label, x_label)
        
        
        
        % GR
        keySet = reshape(data_legend_platemap, [size(mass_Interest,1)*size(mass_Interest,2) 1]);
        valueSet = reshape(mass_Interest, [size(mass_Interest,1)*size(mass_Interest,2) 1]);
        bulk_protein_mass_Map = containers.Map(keySet,valueSet);
        
        clearvars keySet valueSet
        
        Figure_Name = 'GR ScatterPlot';
        num_Points = double(size(group,1));
        num_Points_to_Group = unique_measurement_count;
        data_Map = bulk_protein_mass_Map;
        text_point_label = "GR: ";
        plot_title = ['Growth Rate for: ' Plot_Title '_' char(unique_Grouping(i))];
        y_label = 'Growth Rate (Hours)';
        x_label = 'Well Condition';
        
        dynamic_Scatter_Plot(Figure_Name, data_Map, data_order_to_process, num_Points, num_Points_to_Group, text_point_label, plot_title, y_label, x_label)
        
    end
    
     if ~isempty(Group_by_Value)
        close(fig)
     end
    
    
     clearvars fig Group_Plotting_List btn Group_by_Value unique_Grouping
     
end



%% ------------------------------ Cell Size ------------------------------------------
data_order_to_process= reorderlist(uniWell_Conditions)';

fig = figure('Name','Cell Size');hold on; yMin = 0; yMax = 1;
for condition = 1:size(data_order_to_process,1)

    
    [idx_Row,idx_Col] = find(strcmp(ResultDataStructure.PlateMap,data_order_to_process(condition)));
    y = [];
    for well = 1:size(idx_Row,1)
        row = idx_Row(well); col = idx_Col(well);

        try
            tmp_y = mean(ResultTable_cleaned.(Cytosol_Channel)(contains(ResultTable_cleaned.WellConditions,strtrim(data_order_to_process(condition))) & ResultTable_cleaned.row==row & ResultTable_cleaned.column==col,Cytosol_Channel));
            y = tmp_y;
            tmp_y_std = std(ResultTable_cleaned.(Cytosol_Channel)(contains(ResultTable_cleaned.WellConditions,strtrim(data_order_to_process(condition))) & ResultTable_cleaned.row==row & ResultTable.column==col,Cytosol_Channel));
            y_std = tmp_y_std;
        catch
            if isempty(y)
                ResultTable_Conditions = char(join(table2array((ResultTable_cleaned(:,[{'Well_Info'},Column_Treatment,Row_Treatment(1)]))),', '));
                tmp_y = mean(ResultTable_cleaned.(Cytosol_Channel{1})(strcmp(ResultTable_Conditions,strtrim(data_order_to_process(condition))) &...
                    ResultTable_cleaned.row==row & ResultTable_cleaned.column==col,Cytosol_Channel{2}));
                y = tmp_y;
                tmp_y_std = std(ResultTable_cleaned.(Cytosol_Channel{1})(strcmp(ResultTable_Conditions,strtrim(data_order_to_process(condition))) &...
                    ResultTable_cleaned.row==row & ResultTable_cleaned.column==col,Cytosol_Channel{2}));;
                y_std = tmp_y_std;
            else
                tmp_y = mean(ResultTable_cleaned.(Cytosol_Channel{1})(contains(ResultTable_cleaned.WellConditions,strtrim(data_order_to_process(condition))) & ResultTable_cleaned.row==row & ResultTable_cleaned.column==col,Cytosol_Channel{2}));
                y = [y tmp_y];
                tmp_y_std = std(ResultTable_cleaned.(Cytosol_Channel{1})(contains(ResultTable_cleaned.WellConditions,strtrim(data_order_to_process(condition))) & ResultTable_cleaned.row==row & ResultTable_cleaned.column==col,Cytosol_Channel{2}));
                y_std = [y_std tmp_y_std];
            end
        end
        
        % Get Min y point
        if yMin == 0 && (tmp_y-tmp_y_std)>0
            yMin = tmp_y-tmp_y_std;
        elseif yMin > (tmp_y-tmp_y_std)
            yMin = tmp_y-tmp_y_std;
        end
        
        % Get Max y point
        if yMax < tmp_y + tmp_y_std
            yMax = tmp_y + tmp_y_std;
        end

    end
    errorbar(repelem(condition,size(idx_Row,1)),y,y_std,'s',...
            'MarkerSize',10)
    ax = gca;
    ax.XTick = 1:length(data_order_to_process);
    ax.XTickLabel = data_order_to_process;
    ax.XTickLabelRotation = 45;
    plot_title = ['Cell Size (Intensity) for: ' char(Plot_Title)];
    title(plot_title,'Interpreter', 'none')
    ylabel('Cytosol Channel Intensity')
    xlim([0 size(data_order_to_process,1)+1]); ylim([yMin-10^(floor(log10(yMin))) yMax+8^(floor(log10(yMax)))])
    grid on;


end


