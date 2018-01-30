function fun(app)
  % app.seeds = {};
  % app.seeds(1).name = 'Nucleus';
  % app.seeds(1).value = [10 10; 10 15; 15 15; 15 20; 20 20];

  % app.labels{idx}
  % app.seeds{idx}
  % app.measurements{idx}


  % app.image_names = {'images/example_cells/r02c02f01p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch4sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch4sk1fk1fl1.tiff'};

  if strcmp(app.SpotAlgorithmDropDown.Value, 'Off')
    seeds = [];
  else
    seeds = app.spotting.Callback(app, 'Update');
  end

  result = app.spotting.Callback(app, 'Update');
  result
  % app.spotting.fields{1}.ValueChangedFcn(app, 'Update') % trigger once
end