function fun(app, state)

  if strcmp(state,'busy')
    app.BusyLamp.Color = [0.95 0.25 .1]; % red
    app.BusyLampLabel.Text = 'Busy';
    app.BusyLampLabel.Position = [802,17,28,22];
  elseif strcmp(state,'not busy')
    app.BusyLamp.Color = [0.47 0.8 .19]; % green
    app.BusyLampLabel.Text = 'Not Busy';
    app.BusyLampLabel.Position = [780,17,50,22];
  end

  pause(.1); % Give UI time to update
end