function ret = func(app)
  if isempty(app.ChooseplatemapEditField.Value)
    msg = sprintf('You haven''t chosen any images yet. Please go to the ''Input'' tab and click the ''Browse'' button to choose images.', app.ChooseplatemapEditField.Value);
    uialert(app.UIFigure,msg,'No Images Loaded Yet', 'Icon','warn');
    ret = true;
    return
  end
  ret = false;
end