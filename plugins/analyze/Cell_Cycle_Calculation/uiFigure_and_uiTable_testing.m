% --- FIGURE -------------------------------------
handles.figure1 = figure( ...
    'Tag', 'figure1', ...
    'Units', 'characters', ...
    'Position', [102.8 24.2307692307692 126.8 33], ...
    'Name', 'Parameter', ...
    'MenuBar', 'none', ...
    'NumberTitle', 'off', ...
    'Color', [0.941 0.941 0.941]);

% --- UITABLE -------------------------------------
% Initialize empty string for components of the Data
Data=cell(16,5);
for i = 1:numel(Data)
    Data{i} = '';
end
handles.uitable1 = uitable( ...
    'Parent', handles.figure1, ...
    'Tag', 'uitable1', ...
    'UserData', zeros(1,0), ...
    'Units', 'characters', ...
    'Position', [12.2 8 85.6 21], ...
    'BackgroundColor', [1 1 1;0.961 0.961 0.961], ...
    'ColumnEditable', [true,true,true,true,true], ...
    'ColumnFormat', {'char','char','char','char','char'}, ...
    'ColumnName',{'ID','<html>P<sub>i</sub> -stationary<br>[W]','<html>P<sub>i</sub> -transient<br>[W/t]','<html>&Omega','V'}, ... % '<html>P<sub>i</sup></html>[W]'für griechische Buchstaben in einer Column <HTML>&Buchstabe
    'ColumnWidth', {'auto','auto','auto','auto','auto'}, ...
    'Data',Data); % add the "string" Data








% DIFF SOURCE
% create a figure instance
h_fig = uifigure();

figProps = struct(h_fig);  
controller = figProps.Controller;      % Controller is a private hidden property of Figure
controllerProps = struct(controller);
container = controllerProps.Container;  % Container is a private hidden property of FigureController
win = container.CEF;   % CEF is a regular (public) hidden property of FigureContainer


% Instantiate MATLAB's uitable
h_m_table = uitable( h_fig, ...
                    'Position',[20 20 262+900 204+180],...
                    'Data', ResultDataStructure.PlateMap, ...
                    'ColumnName', {'1','2','3','4','5','6','7','8','9','10','11','12'},... 
                    'RowName', {'A','B','C','D','E','F','G','H'});

% if you already created a table using MATLAB's GUIDE editor, simply pass
% in the "tag" name property, which should be in the "handles" structure by
% default. If you didn't edit that field it's "uitable1" by default so:
% 
% h_m_table = handles.uitable1  % replace 'uitable1' with tag name

% Get java scroll pane object
j_scrollpane = findjobj(h_m_table);

% Get java table object
j_table = j_scrollpane.getViewport.getView;

% (optional) Make entire ROW highlighted when user clicks on any row(s)
% j_table.setNonContiguousCellSelection(false);
% j_table.setColumnSelectionAllowed(false);
% j_table.setRowSelectionAllowed(true);

% Set selction mode to SINGLE_SELECCTION
j_table.setSelectionMode(0);




