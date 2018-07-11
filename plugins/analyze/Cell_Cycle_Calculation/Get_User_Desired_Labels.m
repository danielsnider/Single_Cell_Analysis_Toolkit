function table = Get_User_Desired_Labels(Well_Condition_Split_Control)

tableData =  Well_Condition_Split_Control;
fh=uifigure();
num_col = size(Well_Condition_Split_Control,2);
num_rows = size(Well_Condition_Split_Control,1);
table = uitable('Parent',fh,...
    'Position',[20 20 262+150 204+180],...
    'data', tableData,...
    'CellSelectionCallback',@data_uitable_CellSelectionCallback);



btn = uibutton(fh,...
               'push',...
               'Text', 'OK',...
               'Position',[400+50,100, 100, 22],...
               'ButtonPushedFcn', @(btn, event) ButtonPushed(fh));
uiwait(fh)
% Get Selected Rows and Columns.
% data = table.UserData;
% disp(data)
% Desired_Condition_Labels = Well_Condition_Split_Control(unique(data.datatable_row), unique(data.datatable_col));
% Close Figure
% close(fh) % Need to figure out how to close this figure
end