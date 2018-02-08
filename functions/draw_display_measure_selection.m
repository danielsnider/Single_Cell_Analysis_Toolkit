function fun(app)
  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  if any(ismember(fields(app),'ResultTable')) && istable(app.ResultTable)
    if ~isempty(app.ResultTable.Properties.VariableNames)
      names = app.ResultTable.Properties.VariableNames;

      % Remove column names that are got into the table because it is image or plate metadata
      % NOTE: this may remove actual measure names where there is a name collision? there is a trade off here between clean UI and unintentional confusion, I'm choosing clean UI (fewer items in the measures dropdown list)
      plate_meta = fields(app.plates(plate_num).metadata)';
      image_meta = fields(app.plates(plate_num).img_files(1))';
      other_bad_names = {'PlateName', 'ImageName'};
      bad_names = [plate_meta image_meta other_bad_names];

      % Remove bad names
      names=names(~ismember(names,bad_names))

      % Set new values
      app.DisplayMeasureDropDown.Items = names;
    end
  end
end
