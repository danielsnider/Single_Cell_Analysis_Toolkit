function MeasureTable = func(plugin_name, plugin_num, chan1, chan2, seg, type_of_coefficient)
  % TODO: Known issue: if the number of labels varies between segments you'll end up with NaNs for missing things. The core issue is that this plugin assumes there to be the same number of segments per segment channel.

  MeasureTable = table();

  % Pull out data from struct. Example struct could be 'seg.Pero = [1024 x 1360 x 5]'
  chan1_name = fields(chan1);
  chan1_name = chan1_name{1}; % expecting only one field as defined by the plugin definition
  chan1 = chan1.(chan1_name); % expecting only a matrix of the segmented objects

  chan2_name = fields(chan2);
  chan2_name = chan2_name{1}; % expecting only one field as defined by the plugin definition
  chan2 = chan2.(chan2_name); % expecting only a matrix of the segmented objects

  seg_name = fields(seg); % Pull out segmentation data
  seg_name = seg_name{1}; % expecting only one field as defined by the plugin definition
  seg = seg.(seg_name); % expecting only a matrix of the segmented objects

  % Check if there are any objects, return if not
  if max(seg(:))==0
    return
  end

  MOCs = [];
  for idx = 1:max(seg(:))
    % Get intensities on both channels for one object
    object = seg == idx;
    indicies = find(object);
    chan1_vect = double(chan1(indicies));
    chan2_vect = double(chan2(indicies));

    % Calculate Mander's Overlap Coefficient (MOC)
    MOC_numerator = sum(chan1_vect .* chan2_vect);
    MOC_denominator = sqrt(sum(chan1_vect.^2) .* sum(chan2_vect.^2));
    MOC = MOC_numerator / MOC_denominator;
    MOCs = [MOCs; MOC];
  end

  MeasureTable{:,['MendersOverlapCoef_' matlab.lang.makeValidName(chan1_name) '_and_' matlab.lang.makeValidName(chan2_name) '_in_' matlab.lang.makeValidName(seg_name)]}=MOCs;

  %% Trying to do chan1 on chan2 but... Bug in math reported here: https://mail.google.com/mail/u/0/#sent/KtbxLxgdjfNxTGvQmVvWjCmgsmRJBlcnxB
  % chan1_vect_ = chan1_vect; % more math needed here
  % chan2_vect_ = chan2_vect; % more math needed here
  % MOC_denominator_chan1 = sum(chan1_vect_.^2);
  % MOC_denominator_chan2 = sum(chan2_vect_.^2);
  % MOC_chan1_on_2 = MOC_numerator / MOC_denominator_chan1;
  % MOC_chan2_on_1 = MOC_numerator / MOC_denominator_chan2;

end