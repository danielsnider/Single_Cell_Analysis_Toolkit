function NameCallback(app, seg_num)
  %% Save list of segment names in app.segment_names
  segment_names = {};
  for n=1:length(app.segment)
    segment_names{n} = app.segment{n}.Name.Value;
    if strcmp(segment_names{n},'')
      segment_names{n} = sprintf('Segment %i', n);
    end
  end
  % Fix matlab one element things differently
  if length(segment_names) == 1 
      segment_names = {segment_names{1}};
  end
  % Save
  app.segment_names = segment_names;

  %% Update tab title
  if strcmp(app.segment{seg_num}.Name.Value,'')
    app.segment{seg_num}.tab.Title = sprintf('Segment %i', seg_num);
  else
    app.segment{seg_num}.tab.Title = sprintf('Segment %i: %s', seg_num, app.segment{seg_num}.Name.Value);
  end

  %% Update the segmentation tab with available segment values in dropdown section boxes for algorithms
  for n=1:length(app.segment)
    if isfield(app.segment{n},'SegmentDropDown')
      for drop_num=1:length(app.segment{n}.SegmentDropDown)
        %% Build list of names of segments excluing this segment
        segment_names = {};
        segment_values = [];
        % Loop over each segment getting it's name
        for y=1:length(app.segment)
          if n==y % Skip this node
            continue
          end
          c=length(segment_names)+1;
          % Save info
          segment_names{c} = app.segment{y}.Name.Value;
          segment_values = [segment_values y];
          % if segment name is empty use a default name
          if strcmp(segment_names{c},'')
            segment_names{c} = sprintf('Segment %i', y);
          end
        end
        if length(segment_names) == 1 % fix matlab one element things differently
            segment_names = {segment_names{1}};
        end

        % Set dropdown data
        app.segment{n}.SegmentDropDown{drop_num}.Items = segment_names;
        app.segment{n}.SegmentDropDown{drop_num}.ItemsData = segment_values;
      end
    end
  end

  %% Update the measurement tab with available segment values in dropdown section boxes for algorithms
  for n=1:length(app.measure)
    if isfield(app.measure{n},'SegmentDropDown')
      for drop_num=1:length(app.measure{n}.SegmentDropDown)
        % Set dropdown data
        app.measure{n}.SegmentDropDown{drop_num}.Items = app.segment_names;
        app.measure{n}.SegmentDropDown{drop_num}.ItemsData = 1:length(app.segment_names);
      end
    end
    if isfield(app.measure{n},'SegmentListbox')
      for list_num=1:length(app.measure{n}.SegmentListbox)
        % Set dropdown data
        app.measure{n}.SegmentListbox{list_num}.Items = app.segment_names;
        app.measure{n}.SegmentListbox{list_num}.ItemsData = 1:length(app.segment_names);
      end
    end
  end

  %% Update the measure tab primary segment dropdown the segment names
  app.PrimarySegmentDropDown.Items = app.segment_names;
  app.PrimarySegmentDropDown.ItemsData = 1:length(app.segment_names);

  %% Update the dipslay tab segment selection area with the segment names
  draw_display_segment_selection(app);

end