function fun(plugin_name, plugin_num, operate_on, segments, imgs, save_vis_to_disk, max_dyn_range, remove_abridged_object_tracking, save_growth_plot, save_path, save_mag)

  % Check if save path is empty, ask the human
  if isempty(save_path)
    save_path = uigetdir('\','Choose a folder to save analysis to');
  end
  if isequal(save_path,false)
      save_path = '.';
  end

  save_mag = sprintf('-m%d', save_mag); % convert to an argument that export_fig accepts

  num_timepoints = length(segments);

  ImageName = segments(1).info.ImageName;

  %% Eliminate Orphan Segments (remove segments not seen at all timepoints)
  % Elimate objects whos centroids don't lie within objects that exist at all timepoints
  if remove_abridged_object_tracking
    filtered_segments = struct();
    for tid=1:num_timepoints
      seg = bwlabel(segments(tid).data);
      filtered_segment = seg;
      stats=regionprops('table',seg,'Centroid','Area');
      for idx=1:height(stats)
        if stats.Area(idx) > 5000
          continue % large objects are likely to be unshapely groups of objects and this algo may not work
        end
        centroid = round(stats.Centroid(idx,:));
        y = centroid(1);
        x = centroid(2);
        for ttid=1:num_timepoints
          bound = segments(ttid).data;
          if ~bound(x,y)
            % DELETE OBJECT, it's centroid doesn't lie within objects that exist at all timepoints
            filtered_segment(seg==idx)=0;
          end
        end
      end
      filtered_segments(tid).data = filtered_segment;
      filtered_segments(tid).info = segments(tid).info;
    end
  else
    filtered_segments = segments; %% testing when off
  end

  % Visualize area change
  if ~isequal(imgs,false)
    for tid=1:num_timepoints
      img = imgs(tid).data;
      num_images = length(filtered_segments);
      num_desired_colors = num_images;
      vis_cmap = get_n_length_cmap('jet', num_desired_colors);
      ImageName = filtered_segments(tid).info.ImageName;

      f = figure(plugin_num+4494+tid); clf; set(f,'name',sprintf('t=%d',tid),'NumberTitle', 'off');
      if min(img(:)) < prctile(img(:),max_dyn_range)
          min_max = [min(img(:)) prctile(img(:),max_dyn_range)];
      else
          min_max = [];
      end
      imshow(img,[min_max]);
      hold on
      % Display color overlay (different color for each boundary line)
      for img_id=1:tid
        seg = filtered_segments(img_id).data;
        labelled_perim = imdilate(bwperim(seg),strel('disk',1));
        labelled_rgb = label2rgb(uint32(labelled_perim), vis_cmap(img_id,:), [1 1 1]);
        himage = imshow(im2uint8(labelled_rgb),[min_max]);
        himage.AlphaData = labelled_perim*1;
      end

      txt = sprintf('t=%d', tid);
      h = text(15,15,txt,'Color',[.8 .8 .8],'FontSize',22,'Clipping','on','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');
      txt = sprintf('%s', ImageName);
      h = text(15,size(img,1)-45,txt,'Color',[.8 .8 .8],'FontSize',8,'Clipping','on','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');

      if save_vis_to_disk
        pause(0.1)
        fig_name = sprintf('%s/%s_visualization_%d.png',save_path, ImageName, tid);
        export_fig(fig_name,save_mag);
      end
    end
  end

  % Calulate area and normalize
  areas = [];
  norm_areas = [];
  for tid=1:num_timepoints
    seg = filtered_segments(tid).data;
    seg = seg > 0;
    areas(tid) = sum(seg(:));
    norm_areas(tid) = areas(tid) ./ areas(1); % divide all by the first point
  end



  %% Plot
  f = figure(plugin_num+3499); clf; set(f,'name',plugin_name,'NumberTitle', 'off');
  plot(1:length(norm_areas),norm_areas,'LineWidth',1.5)
  hold on

  % Style
  set(gca,'FontSize',12);
  set(gca,'Color',[.95 .95 .95 ]);
  set(gcf,'Color',[1 1 1 ]);
  grid on;
  axis tight;
  box off;
  set(gca,'GridAlpha',1);
  set(gca,'GridColor',[1 1 1]);
  % Make smaller tick names;
  Fontsize = 12;
  xl = get(gca,'XLabel');
  xlFontSize = get(xl,'FontSize');
  xAX = get(gca,'XAxis');
  set(xAX,'FontSize', Fontsize);
  set(xl, 'FontSize', xlFontSize);
  xl = get(gca,'YLabel');
  xlFontSize = get(xl,'FontSize');
  xAY = get(gca,'YAxis');
  set(xAY,'FontSize', Fontsize);
  set(xl, 'FontSize', xlFontSize);
  % Titles
  title('Growth over Time','Interpreter','none','FontName','Yu Gothic UI Light');
  xlabel('Time (a.u.)', 'Interpreter','none','FontName','Yu Gothic UI');
  ylabel('Normalized Area (%)', 'Interpreter','none','FontName','Yu Gothic UI');
  h=suptitle('Organoid Swelling');
  set(h,'FontSize',18,'FontName','Yu Gothic UI');
  yt = yticks;
  yt = yt*100;
  ticklabels=sprintfc('%g%%',yt);
  yticklabels(ticklabels);
  set(gca,'TickLabelInterpreter','none');

  % Save plot
  if save_growth_plot
    pause(0.1)
    fig_name = sprintf('%s/%s_growth_plot.png',save_path,ImageName);
    export_fig(fig_name,save_mag);
  end


  %% Save Statistics
  ResultTable = table();
  ResultTable.Imagename = segments(1).info.ImageName;
  ResultTable.row = segments(1).info.row;
  ResultTable.column = segments(1).info.column;
  ResultTable.field = segments(1).info.field;
  if isstruct(segments(1).info.well_info_struct)
    for meta_name = fields(segments(1).info.well_info_struct)'
      meta_name = meta_name{:};
      ResultTable.(meta_name) = segments(1).info.well_info_struct.(meta_name);
    end
  end
  ResultTable.Area_Pixel_Count = areas;
  ResultTable.Area_Normalized_Change = norm_areas;
  Experiment_Name = sprintf('%s, Row %d, Column %d, Field %d, Image Name %s',segments(1).info.well_info_string, segments(1).info.row, segments(1).info.column, segments(1).info.field, segments(1).info.ImageName); % ex.     '0.128 Forskolin mM, Something L-Arg (1mM), Treatment??? (Arg), Row 1, Column 1, Field 1, Image Name CBLG-3776-1NW7_180627130001i3t001A01f01d1.TIF'
  ResultTable.Experiment_Name = Experiment_Name;
  save_file = sprintf('%s/%s_results.csv',save_path,ImageName);
  writetable(ResultTable,save_file)

  %% Combine this result into an existing table
  % NOTE: Not safe for parallel processing
  all_results_file = sprintf('%s/all_results.csv',save_path);
  if exist(all_results_file,'file') ~= 2
    % Create an 'all_results.csv' file with this one entry
    writetable(ResultTable,all_results_file)
  else
    % Check if entry exists in the result table for this time course
    allResults = readtable(all_results_file);
    thisResult = readtable(save_file);
    data_loc = find(ismember(allResults.Experiment_Name,Experiment_Name)); % location of this time course data in the CSV file
    [allResults, thisResult] = append_missing_columns_table_pair(allResults, thisResult);
    if isempty(data_loc)
      allResults = [allResults; thisResult]; % append this result
    else
      allResults(data_loc,:) = thisResult; % update this result
    end
    writetable(allResults,all_results_file) % save all results to CSV
  end

  %% Rainbow Visualization
  % vis _ID_ timepoint_1.png
  % vis _ID_ timepoint_1.gif
  %% Normalize and Measure Areas
  %% Plot Area Change
  % plot1.png
  %% Save Statistics
  % Results _ID_ Area Change Timelapse.csv
  % AllResults Area Change Timelapse.csv



end