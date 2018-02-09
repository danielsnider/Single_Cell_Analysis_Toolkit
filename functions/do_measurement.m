function result = do_measurement(app, plate, meas_num, algo_name)
algo_params = {};

% Create list of algorithm parameter values to be passed to the plugin
if isfield(app.measure{meas_num},'fields')
  for idx=1:length(app.measure{meas_num}.fields)
    algo_params(length(algo_params)+1) = {app.measure{meas_num}.fields{idx}.Value};
  end
end

% Collect numbers of segments to measure
if isfield(app.measure{meas_num},'SegmentListbox')
  for param_num=1:length(app.measure{meas_num}.SegmentListbox)
    segments_to_measure = app.measure{meas_num}.SegmentListbox{param_num}.Value;

    % Create struct of input segments to be passed to the plugin. Where the key is the name of the segment and value is the image content.
    segment_data = {};
    for seg_num=segments_to_measure
      seg_name = app.segment{seg_num}.Name.Value;
      if strcmp(seg_name,'')
        seg_name = sprintf('Segment %i', seg_num);
      end
      seg_data = app.segment{seg_num}.result;
      segment_data.(genvarname(seg_name)) = seg_data;
    end
    algo_params(length(algo_params)+1) = {segment_data};
  end
end

% Collect names of channels to measure
param_types = { ... % known names of UI components
  'ChannelDropDown', ...
  'ChannelListbox' ...
};
for param_type=param_types
  if isfield(app.measure{meas_num},param_type)
    for param_num=1:length(app.measure{meas_num}.(param_type{:}))
      channels_to_measure = app.measure{meas_num}.(param_type{:}){param_num}.Value;

      % Keep only the channels which exist in the plate
      if ~isempty(channels_to_measure)
        channels_to_measure = intersect(channels_to_measure,plate.chan_names);
      end

      % Create struct of input channels to be passed to the plugin. Where the key is the name of the channel and value is the image content.
      img_data = {};
      for idx=1:length(channels_to_measure)
        chan_name = channels_to_measure{idx};
        chan_num = find(strcmp(plate.chan_names,chan_name));
        chan_data = app.image(chan_num).data;
        img_data.(genvarname(chan_name)) = chan_data;
      end
      if ~isempty(img_data)
        algo_params(length(algo_params)+1) = {img_data};
      end
    end
  end
end



% Call algorithm
result = feval(algo_name, algo_params{:});
% app.measure{meas_num}.result = result;

end