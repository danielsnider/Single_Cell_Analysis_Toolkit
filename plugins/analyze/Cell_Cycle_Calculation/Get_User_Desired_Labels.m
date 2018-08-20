function [fh,table] = Get_User_Desired_Labels(Well_Condition_Split_Control)

tableData =  Well_Condition_Split_Control;
fh = figure('WindowStyle','normal');
fh.Position = [1 1 1000 300];
pos = fh.Position; %// gives x left, y bottom, width, height
left = pos(1);
bottom = pos(2);
width = pos(3);
height = pos(4);
    
% Create text label description
text = sprintf('%s\n%s','Select which wells are the controls','Use `Ctrl` to select multiple wells');
 
txt = uicontrol('Parent',fh,...
    'Style','text',...
    'Position',[left-(left) bottom width height],...
    'String',text,...
    'FontSize',14);


% num_col = size(Well_Condition_Split_Control,2);
% num_rows = size(Well_Condition_Split_Control,1);
table = uitable('Parent',fh,...
    'Position',[20 bottom+50 860 150],...  %[20 20 262+150 204+180]860
    'data', tableData,...
    'CellSelectionCallback',@data_uitable_CellSelectionCallback);

% btn = uibutton(fh,...
%                'push',...
%                'Text', 'OK',...
%                'Position',[400+50,100, 100, 22],...
%                'ButtonPushedFcn', @(btn, event) ButtonPushed(fh));
           
% Create push button
    btn = uicontrol('Style', 'pushbutton', 'String', 'Ok',...
        'Position', [860+20,bottom+50, 100, 22],...
        'Callback', @(btn, event) ButtonPushed(fh));              
           
uiwait(fh)
% Get Selected Rows and Columns.
% data = table.UserData;
% disp(data)
% Desired_Condition_Labels = Well_Condition_Split_Control(unique(data.datatable_row), unique(data.datatable_col));
% Close Figure
% close(fh) % Need to figure out how to close this figure
end