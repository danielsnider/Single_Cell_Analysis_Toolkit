function fun(app)
  if any(ismember(fields(app),'ResultTable')) && istable(app.ResultTable)
    if ~isempty(app.ResultTable.Properties.VariableNames)
      app.DisplayMeasureDropDown.Items = app.ResultTable.Properties.VariableNames;
    end
  end
end
