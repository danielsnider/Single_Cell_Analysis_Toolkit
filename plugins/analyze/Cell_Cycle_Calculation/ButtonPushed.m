% Create the function for the ButtonPushedFcn callback
function ButtonPushed(hObject,varargin)
        uiresume(hObject)
        
disp("Button Pushed")        

if any(contains(varargin,{'invisible'}))
    hObject.Visible = 'off';
end

if any(contains(varargin,{'close'}))
        close(hObject) 
end

if any(contains(varargin,{'resume'}))
        uiresume
end

end