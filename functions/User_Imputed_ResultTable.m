Data = readtable("R:\Justin_S\Single_Cell_Analysis_Toolkit\Justin_TEST_Eden_Result_Table_Data\SE\Dataset_LKB1Data.xlsx");
% PlateMap = Data.Plate_Map;

[num,txt,raw] = xlsread('R:\Justin_S\Single_Cell_Analysis_Toolkit\Justin_TEST_Eden_Result_Table_Data\Plate map 20180129_LKB1cellcycle.xlsx');

% Get Well Meta-Info based on 96-Well Plate
Well_Conditons = cell(60,3);idx = 1;
for row = 2:9
    for col = 2:13        
        Well_Conditons(idx,1) = num2cell(row-1);
        Well_Conditons(idx,2) = num2cell(col-1);
        Well_Conditons(idx,3) = raw(row,col);
        idx = idx + 1;
    end
end
Well_Conditons = cell2table(Well_Conditons,'VariableNames',{'row','column','Well_Info'});

% Get Row Conditions based on 96-Well Plate
tmp_Row_Con=num2cell(1:8)';
Row_Conditions = struct;
for item = 14:size(raw,2)
    tmp_Row_Con(:,2) = raw(2:9,item);
    tmp_Row_Con = cell2table(tmp_Row_Con,'VariableNames',{'row',char(raw(1,item))});
    Row_Conditions.(char(raw(1,item)))= tmp_Row_Con;
    tmp_Row_Con=num2cell(2:9)';
end

% Get Column Conditons based on 96-Well Plate
tmp_Col_Con=num2cell(1:12)';
Col_Conditions = struct;
for item = 10:size(raw,1)
    tmp_Col_Con(:,2)=raw(item,2:13)';
    tmp_Col_Con = cell2table(tmp_Col_Con,'VariableNames',{'col',char(raw(item,1))});
    Col_Conditions.(char(raw(item,1)))= tmp_Col_Con;
    tmp_Col_Con=num2cell(2:13)';
end

uniWells = unique(ResultTable(:,{'Row','Column'}));
WellConditions = table();
WellConditions(:,1) = uniWells(:,1);
WellConditions(:,2) = uniWells(:,2);
WellConditions.Properties.VariableNames{1} = 'row';
WellConditions.Properties.VariableNames{2} = 'column';
WellConditions.WellConditions = cell(size(uniWells,1),1);
for well = 1:size(uniWells,1)
    row = uniWells.Row(well); col = uniWells.Column(well);
    tmp = [char(table2cell(Well_Conditons(Well_Conditons.row==row&Well_Conditons.column==col,3))) ', ' char(table2cell(Col_Conditions.CellLineType(Col_Conditions.CellLineType.col==col,2))) ', ' char(table2cell(Row_Conditions.Drug(Row_Conditions.Drug.row==row,2)))];% FIX THIS AT SOME POINT
    WellConditions.WellConditions(WellConditions.row==row&WellConditions.column==col) = cellstr(tmp);
    
end


% Combine ResultsTables with TimePoint
Paths = Data.Path_to_Dataset;
TimePoints = Data.Time_Point;
iterTable = table();
ResultTable = table();
for path = 1:size(Paths,1)    
    load_iterTable = load([char(Paths(path)) '\ResultTable.mat']);
    iterTable = load_iterTable.ResultTable;
    TableHeight = size(iterTable,1);
    Impute_TimePoint = cell(TableHeight,1);
    Impute_TimePoint(:)= cellstr(num2str(TimePoints(path)));
    iterTable.TimePoint = Impute_TimePoint;
    ResultTable = [ResultTable;iterTable];
end


uniWells = unique(ResultTable(:,{'Row','Column'}));

for well = 1:size(uniWells,1)
    row = uniWells.Row(well); col = uniWells.Column(well);
    ResultTable.WellConditions(ResultTable.Row==row&ResultTable.Column==col,1) = table2cell(WellConditions(WellConditions.row==row&WellConditions.column==col,3));
end

ResultTable.Well_Info = cell(size(ResultTable,1),1);
for well = 1:size(uniWells,1)
    row = uniWells.Row(well); col = uniWells.Column(well);
    ResultTable.Well_Info(ResultTable.Row==row&ResultTable.Column==col,1) = table2cell(Well_Conditons(Well_Conditons.row==row&Well_Conditons.column==col,3));
end

for idx = 1:size(Row_Conditions,1)
    field = Row_Conditions(idx);
    Row_metadata = Row_Conditions.(char(fieldnames(field)));
    ResultTable.(matlab.lang.makeValidName(char(fieldnames(field)))) = cell(size(ResultTable,1),1);
    for well = 1:size(uniWells,1)
        row = uniWells.Row(well);
        ResultTable.(matlab.lang.makeValidName(char(fieldnames(field))))(ResultTable.Row==row,1) = table2cell(Row_metadata(Row_metadata.row==row,2));
    end
end

for idx = 1:size(Col_Conditions,1)
    field = Col_Conditions(idx);
    Col_metadata = Col_Conditions.(char(fieldnames(field)));
    ResultTable.(matlab.lang.makeValidName(char(fieldnames(field)))) = cell(size(ResultTable,1),1);
    for well = 1:size(uniWells,1)
        col = uniWells.Column(well);
        ResultTable.(matlab.lang.makeValidName(char(fieldnames(field))))(ResultTable.Column==col,1) = table2cell(Col_metadata(Col_metadata.col==col,2));
    end
end

uisave('ResultTable','ResultTable')