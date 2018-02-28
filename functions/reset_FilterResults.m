function fun(app)
  app.ResultTable_filtered = [];
  app.FilterKeepFirst.Value = Inf;
  app.FilterKeepLast.Value = Inf;
  if istable(app.ResultTable)
    app.NumberBeforeFiltering.Value = height(app.ResultTable);
    app.NumberAfterFiltering.Value = height(app.ResultTable);
  end
  app.FiltersTextArea.Value = {''};
  app.FilterReductionTextArea.Value = {''};
  app.Button_ViewFilteredData.Visible = 'off';
end