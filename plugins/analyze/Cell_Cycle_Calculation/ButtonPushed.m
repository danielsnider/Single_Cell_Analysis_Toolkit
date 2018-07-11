% Create the function for the ButtonPushedFcn callback
function ButtonPushed(hObject)
        uiresume(hObject)
        hObject.Visible = 'off';
%         close(hObject) 
end