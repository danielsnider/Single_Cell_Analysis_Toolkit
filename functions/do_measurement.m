function result = do_measurement(app, plate, meas_num, algo_name)

% Create list of algorithm parameter values to be passed to the plugin
algo_params = {};
if isfield(app.measure{meas_num},'fields')
    
    for idx=1:length(app.measure{meas_num}.fields)
        algo_params(length(algo_params)+1) = {app.measure{meas_num}.fields{idx}.Value};
    end
end

% Collect numbers of segments to measure
segments_to_measure = [];
if isfield(app.measure{meas_num},'SegmentListbox')
    for param_num=1:length(app.measure{meas_num}.SegmentListbox)
        segments_to_measure = [segments_to_measure app.measure{meas_num}.SegmentListbox{param_num}.Value];
    end
end
segments_to_measure = unique(segments_to_measure);

% Collect names of channels to measure
channels_to_measure = {};
if isfield(app.measure{meas_num},'ChannelListbox')
    for param_num=1:length(app.measure{meas_num}.ChannelListbox)
        channels_to_measure{length(channels_to_measure)+1} = app.measure{meas_num}.ChannelListbox{param_num}.Value;
    end
end
if isfield(app.measure{meas_num},'ChannelDropDown')
    for param_num=1:length(app.measure{meas_num}.ChannelDropDown)
        channels_to_measure{length(channels_to_measure)+1} = app.measure{meas_num}.ChannelDropDown{param_num}.Value;
    end
end
channels_to_measure = unique(cat(1,channels_to_measure{:}));
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

% Create struct of input segments to be passed to the plugin. Where the key is the name of the segment and value is the image content.
segment_data = {};
for seg_num=1:length(segments_to_measure)
    seg_name = app.segment{seg_num}.Name.Value;
    if strcmp(seg_name,'')
        seg_name = sprintf('Segment %i', seg_num);
    end
    seg_data = app.segment{seg_num}.result;
    segment_data.(genvarname(seg_name)) = seg_data;
end
algo_params(length(algo_params)+1) = {segment_data};

% Call algorithm
result = feval(algo_name, algo_params{:});
app.measure{meas_num}.result = result;

end