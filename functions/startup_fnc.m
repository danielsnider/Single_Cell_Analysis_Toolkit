function fun(app,createCallbackFcn)
  set(0,'DefaultFigureWindowStyle','docked');
  warning('off','images:initSize:adjustingMag');
  warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
  addpath(genpath('functions'));
  addpath(genpath('plugins'));
  
  % Initialize variables
  init_variables(app);

  
  % Select tab to display on opening
  app.TabGroup.SelectedTab = app.Tab_Input;
  
  

  browse_button_pushed(app,createCallbackFcn); % trigger for testing
  
end