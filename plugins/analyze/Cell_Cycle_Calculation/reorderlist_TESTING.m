function reorderlist(items)
%     items = {'File1.png', 'File2.png', 'File3.png'};
%     items = reshape(data_legend_platemap, [size(cc_Interest,1)*size(cc_Interest,2) 1]);
    hfig = figure();

    hlist = uicontrol('Parent', hfig, 'style', 'listbox', 'string', items);

    set(hlist, 'units', 'norm', 'position', [0 0 0.75 1])

    promote = uicontrol('Parent', hfig, 'String', '^');
    set(promote, 'units', 'norm', 'position', [0.8 0.75 0.15 0.15])

    demote = uicontrol('Parent', hfig, 'String', 'v');
    set(demote, 'units', 'norm', 'position', [0.8 0.55 0.15 0.15])

    % Set button callbacks
    set(promote, 'Callback', @(s,e)moveitem(hlist,1))
    set(demote, 'Callback', @(s,e)moveitem(hlist,-1))

end