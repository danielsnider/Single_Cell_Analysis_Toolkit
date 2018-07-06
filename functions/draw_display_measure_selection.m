function fun(app)
  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  app.DisplayMeasureDropDown.Items = {}; % Default empty
  if any(ismember(fields(app),'ResultTable_for_display')) && istable(app.ResultTable_for_display)
    if ~isempty(app.ResultTable_for_display.Properties.VariableNames)
      names = app.ResultTable_for_display.Properties.VariableNames;

      % Remove column names that are got into the table because it is image or plate metadata
      % NOTE: this may remove actual measure names where there is a name collision? there is a trade off here between clean UI and unintentional confusion, I'm choosing clean UI (fewer items in the measures dropdown list)
      plate_meta = fields(app.plates(plate_num).metadata)';
      image_meta = fields(app.plates(plate_num).img_files(1))';
      other_bad_names = {'PlateName', 'ImageName','x_coord','y_coord','ID','WellConditions'};
      bad_names = [plate_meta image_meta other_bad_names];

      % Remove bad names
      names=names(~ismember(names,bad_names));

      % Set new values
      app.DisplayMeasureDropDown.Items = names;
    end
  end
end
