function fun(app)
  % When this application is distributed in an executable file (exe) which is needed when the user doesn't have Matlab, some things need to happen differently

  % Disable buttons which don't work in exe mode
  app.Button_ViewMeasurements.Enable = false;
  app.Button_ViewFilteredData.Enable = false;

end