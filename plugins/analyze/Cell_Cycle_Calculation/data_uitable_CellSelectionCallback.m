function data_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to data_uitable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
% disp(eventdata)
handles.datatable_row = eventdata.Indices(:,1);
handles.datatable_col = eventdata.Indices(:,2);

set(hObject,'userdata',handles)

guidata(hObject, handles);
end