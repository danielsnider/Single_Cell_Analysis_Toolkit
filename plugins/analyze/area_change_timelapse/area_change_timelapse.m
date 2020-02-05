function fun(plugin_name, plugin_num, operate_on, segments, imgs, save_vis_to_disk, max_dyn_range, remove_abridged_object_tracking, sweller_threshold, save_growth_plot, manually_filter_organoids, save_path)
  
  manually_filter_organoids

  % Check if save path is empty, ask the human
  if isempty(save_path)
    save_path = uigetdir('\','Choose a folder to save analysis to');
  end
  if isequal(save_path,false)
      save_path = '.';
  end

  mkdir(save_path);

  save_mag = '-native';

  num_timepoints = length(segments);

  ImageName = segments(1).info.ImageName;
  date_str = datestr(now,'yyyymmddTHHMMSS');
  save_path_prefix = sprintf('%s/%s_%s',save_path, date_str, ImageName);

  % Convert the human supplied sweller_threshold from '1.5%' to machine usable '1.015'
  if ~isequal(sweller_threshold,false)
    if contains(sweller_threshold,'%')
      percent_location = strfind(sweller_threshold,'%');
      sweller_threshold = sweller_threshold(1:percent_location-1); % remove '%' sign
      sweller_threshold = str2num(sweller_threshold); % convert to number
      sweller_threshold = sweller_threshold/100+1; % convert from 1.5 to 1.015
    else
      title_ = 'User Input Error';
      msg = sprintf('User caused an error in ''%s'' plugin. The input parameter ''Minimum Growth'' that the user has chosen must contain a ''%''. Please see the parameter help button for an example.', plugin_name);
      f = errordlg(msg,title_);
      err = MException('PLUGIN:input_param_error',msg);
      throw(err);
    end
  else
    sweller_threshold = -Inf;
  end

  %% Eliminate Orphan Segments (remove segments not seen at all timepoints)
  % Elimate objects whos centroids don't lie within objects that exist at all timepoints
  if remove_abridged_object_tracking & num_timepoints > 1
    segs = [];
    seg_concat = zeros(size(segments(1).data));
    for tid = 1:num_timepoints
      segs(:,:,tid) = segments(tid).data;
      seg_concat = seg_concat + double(segments(tid).data);
    end
    seg_concat = imdilate(seg_concat,strel('disk',13));
    seg_concat = seg_concat>=num_timepoints-1;
    % figure;imshow3D(seg_concat,[])

    filt_segs = segs & seg_concat;
    % figure;imshow3D(filt_segs,[])

    filt_segs=bwlabeln(filt_segs);
    stats = regionprops('table', filt_segs, 'BoundingBox');
    z_heights = stats.BoundingBox(:,6);
    bad_z_heights = z_heights < num_timepoints;
    for idx=find(bad_z_heights)'
      filt_segs(filt_segs==idx)=0;
    end
    % figure;imshow3D(filt_segs,[])

    filtered_segments = segments; %% testing when off
    for tid = 1:num_timepoints
      filtered_segments(tid).data =  filt_segs(:,:,tid);
    end
  else
    filtered_segments = segments; %% testing when off
  end

  % Calculate growth of each organoid
  organoid_areas = [];
  norm_organoid_areas = [];
  segs = [];
  for tid = 1:num_timepoints
    segs(:,:,tid) = filtered_segments(tid).data;
  end
  segs=bwlabeln(segs);
  for idx=1:max(segs(:)) % loop over each organoid
    for tid=1:num_timepoints
      organoid_areas(idx,tid)=sum(sum(segs(:,:,tid)==idx)); % area of one organoid at one timepoint
      norm_organoid_areas(idx,tid) = organoid_areas(idx,tid) ./ organoid_areas(idx,1); % divide all by the first point
    end
  end
  num_organoids = size(organoid_areas,1);

  % Get only swellers
  if num_organoids > 0
    sweller_pos = norm_organoid_areas(:,end) > sweller_threshold;
    sweller_idx = find(sweller_pos);
    sweller_organoid_areas = organoid_areas(sweller_pos,:);
    sweller_norm_organoid_areas = norm_organoid_areas(sweller_pos,:);
  else
    sweller_pos = NaN;
    sweller_idx = NaN;
    sweller_organoid_areas = NaN;
    sweller_norm_organoid_areas = NaN;
  end
  relative_sweller_norm_organoid_areas = mean(sweller_norm_organoid_areas); % mean of relative growth
  absolute_sweller_norm_organoid_areas = sum(sweller_organoid_areas) ./ sum(sweller_organoid_areas(:,1)); % mean of absolute growth

  % Calculate sweller statistics
  if num_organoids > 0
    num_sweller_organoids = size(sweller_organoid_areas,1);
    sweller_absolute_total_growth = sum(sweller_organoid_areas(:,end))/sum(sweller_organoid_areas(:,1))*100;
    sweller_mean_individual_relative_growth = mean(sweller_norm_organoid_areas(:,end))*100;
    sweller_max_individual_relative_growth = max(sweller_norm_organoid_areas(:,end))*100;
    absolute_total_growth = sum(organoid_areas(:,end))/sum(organoid_areas(:,1))*100;
    mean_individual_relative_growth = mean(norm_organoid_areas(:,end))*100;
  else
    num_sweller_organoids = 0;
    sweller_absolute_total_growth = NaN;
    sweller_mean_individual_relative_growth = NaN;
    sweller_max_individual_relative_growth = NaN;
    absolute_total_growth = NaN;
    mean_individual_relative_growth = NaN;
  end
  sweller_stats_txt = [ ...
    sprintf('number of objects that swelled more than %.3f%% --> %.1f%% (%d / %d)\n',sweller_threshold, num_sweller_organoids/num_organoids*100,num_sweller_organoids,num_organoids) ...
    sprintf('of the %d swellers --> absolute total growth = %.1f%%,\n\t mean individual growth (relative to its starting size) = %.1f%%\n\t max individual growth (relative to its starting size) = %.1f%%\n', num_sweller_organoids, sweller_absolute_total_growth, sweller_mean_individual_relative_growth, sweller_max_individual_relative_growth) ...
    sprintf('for all %d objects --> absolute total growth = %.1f%%,\n\t mean individual growth (relative to its starting size) = %.1f%%\n', num_organoids, absolute_total_growth, mean_individual_relative_growth) ...
  ]

  % Create labelled image stack of only the swellers
  sweller_segs = zeros(size(segs));
  sweller_segs(ismember(segs,sweller_idx))=1;
  non_sweller_segs = segs & ~sweller_segs;
  
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
        labelled_perim = imdilate(bwperim(seg),strel('disk',0));
        labelled_rgb = label2rgb(uint32(labelled_perim), vis_cmap(img_id,:), [1 1 1]);
        himage = imshow(im2uint8(labelled_rgb),[min_max]);
        himage.AlphaData = labelled_perim*1;
        % sweller_segs_rgb = logical(cat(3, sweller_segs(:,:,img_id), sweller_segs(:,:,img_id), sweller_segs(:,:,img_id)));
        % labelled_rgb(labelled_rgb(sweller_segs_rgb)==round(vis_cmap(img_id,:)*255)) = 179;
        % swelling_locs_rgb = labelled_rgb(sweller_segs_rgb)==round(vis_cmap(img_id,:)*255);
        % labelled_rgb(find(any(swelling_locs_rgb'))) = [0 0 0 ];

        % Overlap grey colored outlines where objects are not swelling
        non_swelling_seg = non_sweller_segs(:,:,img_id);
        labelled_perim = imdilate(bwperim(non_swelling_seg),strel('disk',0));
        labelled_rgb = label2rgb(uint32(labelled_perim), [.7 .7 .7], [1 1 1]);
        himage = imshow(im2uint8(labelled_rgb),[min_max]);
        himage.AlphaData = labelled_perim*1;
      end

      txt = sprintf('t=%d', tid);
      h = text(15,15,txt,'Color',[.8 .8 .8],'FontSize',22,'Clipping','on','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');
      txt = sprintf('%s', ImageName);
      h = text(15,size(img,1)-45,txt,'Color',[.8 .8 .8],'FontSize',8,'Clipping','on','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');

      if save_vis_to_disk
        pause(0.1)
        fig_name = sprintf('%s_visualization_%d.png',save_path_prefix, tid);
        [imageData, alpha] = export_fig(fig_name,save_mag);

        if ndims(imageData) == 2
          imageData = cat(3, imageData, imageData, imageData);
        end
      
        if ndims(imageData) == 3
          % Make GIF
          fps = 2;
          gif_name = sprintf('%s_visualization.gif',save_path_prefix);
          [imind,cm] = rgb2ind(imageData,256);
          if tid == 1
              imwrite(imind, cm, gif_name, 'gif', 'DelayTime',1/fps, 'Loopcount', inf); 
          else 
              imwrite(imind, cm, gif_name, 'gif', 'DelayTime',1/fps, 'WriteMode', 'append'); 
          end 
        end

      end
    end
  end

  % Calulate area and normalize
  areas = [];
  norm_areas = [];
  for tid=1:num_timepoints
    seg = filtered_segments(tid).data;
    seg = seg > 0;
    num_objects(tid) = max(max(bwlabel(seg)));
    areas(tid) = sum(seg(:));
    norm_areas(tid) = areas(tid) ./ areas(1); % divide all by the first point
  end




  %% Plot
  f = figure(plugin_num+3499); clf; set(f,'name',plugin_name,'NumberTitle', 'off');
  hold on
  % Plot growth of each organoid
  for idx=1:size(organoid_areas,1)
    fh = plot(1:length(norm_areas),norm_organoid_areas(idx,:),'LineWidth',1, 'HandleVisibility','off');
    % Set line color to gray if not above sweller threshold
    if norm_organoid_areas(idx,end) <= sweller_threshold
      fh.Color = [.7 .7 .7];
    end
  end
  % Plot growth of averages
  plot(1:length(norm_areas),norm_areas,'LineWidth',4,'Color','black')
  ylim([.5 2]);
  plot(1:length(norm_areas),relative_sweller_norm_organoid_areas,'LineWidth',4,'Color','yellow')
  ylim([.5 2]);
  plot(1:length(norm_areas),absolute_sweller_norm_organoid_areas,'LineWidth',4,'Color','red')
  ylim([.5 2]);
  % Style
  set(gca,'FontSize',12);
  set(gca,'Color',[.95 .95 .95 ]);
  set(gcf,'Color',[1 1 1 ]);
  grid on;
  legend({sprintf('Mean n=%d, %.1f%%',num_organoids, norm_areas(end)*100), sprintf('Mean of Swellers (relative mean growth) n=%d, %.1f%%', num_sweller_organoids, relative_sweller_norm_organoid_areas(end)*100), sprintf('Mean of Swellers (absolute total growth) n=%d, %.1f%%', num_sweller_organoids, absolute_sweller_norm_organoid_areas(end)*100)},'Location','northwest')
  % axis tight;
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
  title(ImageName,'Interpreter','none','FontName','Yu Gothic UI Light');
  xlabel('Time (a.u.)', 'Interpreter','none','FontName','Yu Gothic UI');
  ylabel('Normalized Area (%)', 'Interpreter','none','FontName','Yu Gothic UI');
  h=suptitle(sprintf('Organoid Swelling (%.1f%% grew by more than %.3g%%)', num_sweller_organoids/num_organoids*100, sweller_threshold*100-100));
  set(h,'FontSize',18,'FontName','Yu Gothic UI');
  yt = yticks;
  yt = yt*100;
  ticklabels=sprintfc('%g%%',yt);
  yticklabels(ticklabels);
  set(gca,'TickLabelInterpreter','none');
  % Label for final growth percentage
  for idx=1:size(organoid_areas,1)
    x = num_timepoints;
    y = norm_organoid_areas(idx,end);
    txt = sprintf('%.1f%%',y*100);
    th = text(x,y,txt,'Interpreter','none','FontName','Yu Gothic UI Light', 'Fontsize',10);
  end
  x = num_timepoints;
  y = norm_areas(end);
  txt = sprintf('%.1f%%',y*100);
  th = text(x+0.03,y,txt,'Interpreter','none','FontName','Yu Gothic UI Light', 'Fontsize',15,'BackgroundColor','white');
  y = relative_sweller_norm_organoid_areas(end);
  txt = sprintf('%.1f%%',y*100);
  th = text(x+0.03,y,txt,'Interpreter','none','FontName','Yu Gothic UI Light', 'Fontsize',15,'BackgroundColor','white');
  y = absolute_sweller_norm_organoid_areas(end);
  txt = sprintf('%.1f%%',y*100);
  th = text(x+0.03,y,txt,'Interpreter','none','FontName','Yu Gothic UI Light', 'Fontsize',15,'BackgroundColor','white');


  % Save plot
  if save_growth_plot
    pause(0.2)
    fig_name = sprintf('%s_growth_plot.png',save_path_prefix);
    export_fig(fig_name,save_mag);
  end


  %% Save Statistics
  ResultTable = table();
  ResultTable.Imagename = ImageName;
  ResultTable.RowColumn = ImageName(34:36);
  ResultTable.row = segments(1).info.row;
  ResultTable.column = segments(1).info.column;
  ResultTable.field = segments(1).info.field;
  if isstruct(segments(1).info.well_info_struct)
    for meta_name = fields(segments(1).info.well_info_struct)'
      meta_name = meta_name{:};
      ResultTable.(meta_name) = cell(1);
      ResultTable.(meta_name) = {segments(1).info.well_info_struct.(meta_name)};
    end
  end
  ResultTable.Number_of_Organoids= num_objects;
  num_sweller_organoids_per_timepoint = sum(sweller_organoid_areas>0);
  ResultTable.Number_of_Swelling_Organoids = num_sweller_organoids_per_timepoint;
  ResultTable.Area_Pixel_Count = areas;
  ResultTable.Area_Normalized_Change = norm_areas;
  if size(absolute_sweller_norm_organoid_areas) == size(norm_areas)
    ResultTable.Swellers_Area_Pixel_Count = absolute_sweller_norm_organoid_areas;
  else
    ResultTable.Swellers_Area_Pixel_Count = nan(size(norm_areas));
  end
  ResultTable.Swellers_Area_Normalized_Change = absolute_sweller_norm_organoid_areas;
  perc_of_swellers = num_sweller_organoids_per_timepoint./num_objects;
  growth = norm_areas.*perc_of_swellers; % scale by percent of swellers
  ResultTable.Area_Normalized_Scaled_by_Num_Swellers = growth;
  Experiment_Name = sprintf('%s, Row %d, Column %d, Field %d, Image Name %s',segments(1).info.well_info_string, segments(1).info.row, segments(1).info.column, segments(1).info.field, ImageName); % ex.     '0.128 Forskolin mM, Something L-Arg (1mM), Treatment??? (Arg), Row 1, Column 1, Field 1, Image Name CBLG-3776-1NW7_180627130001i3t001A01f01d1.TIF'
  ResultTable.AnalysisDateTime = date_str;
  ResultTable.Experiment_Name = Experiment_Name;
  save_file = sprintf('%s_results.csv',save_path_prefix);
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

    %% Convert (AllResults) all table values to cells so that a single column can have both numeric and string values
    % Reorder column names of tables to be in the same order so that joining works
    original_column_order = allResults.Properties.VariableNames;
    thisResult = thisResult(:,sort(thisResult.Properties.VariableNames));
    allResults = allResults(:,sort(allResults.Properties.VariableNames));
    % Join table and convert all table values to cells so that a single column can have both numeric and string values
    allResults = cell2table(cat(1,table2cell(allResults), table2cell(thisResult)), 'VariableNames', allResults.Properties.VariableNames);
    %% Convert (thisResult) all table values to cells so that a single column can have both numeric and string values
    original_column_order2 = thisResult.Properties.VariableNames;
    thisResult = thisResult(:,sort(thisResult.Properties.VariableNames));
    allResults = allResults(:,sort(allResults.Properties.VariableNames));
    % Join table and convert all table values to cells so that a single column can have both numeric and string values
    thisResult = cell2table(cat(1,table2cell(allResults), table2cell(thisResult)), 'VariableNames', thisResult.Properties.VariableNames);
    % Reorder table columns to the original order
    allResults = allResults(:,original_column_order);
    thisResult = thisResult(:,original_column_order2);

    % Add missing columns
    [allResults, thisResult] = append_missing_columns_table_pair(allResults, thisResult);

    if isempty(data_loc)
      % allResults = [allResults; thisResult]; % append this result % UPDATE this doesn't work with columns of different types
      allResults = allResults(:,original_column_order);
    else
      try
        allResults(data_loc,allResults.Properties.VariableNames) = thisResult(1,allResults.Properties.VariableNames); % update this result for all variables
      catch ME
        missing_save_file = sprintf('%s/MISSING_in_all_results__%s_%s_results.csv',save_path, date_str, ImageName);
        writetable(ResultTable,missing_save_file);
        error_msg = getReport(ME,'extended','hyperlinks','off');
        disp(error_msg);
        title_ = 'Error Saving Statistics to Disk';
        msg = sprintf('The analysis will continue but a well will be missing from the ''all_results.csv'' file. Please email Daniel Snider with the following three things: \n1. Your ''all_results.csv'' file. \n2. The file in the same folder named ''%s''.\n3. A screenshot of the following error:\n\n%s', missing_save_file, error_msg);
        % msg = sprintf('We ran into an issue trying to add the current well''s growth statistics to the ''all_results.csv'' file. To avoid this problem, rename ''all_results.csv'' to anything else and try again.', plugin_name);
        f = errordlg(msg,title_);
        % err = MException('PLUGIN:input_param_error',msg);
        % throw(err);
      end
    end

    % Write to disk with the option to try again if a problem comes up
    written_to_disk = false;
    while ~written_to_disk
      try
        writetable(allResults,all_results_file); % save all results to CSV
        written_to_disk = true;
      catch ME
        if contains(ME.message, 'Permission denied')
          answer = questdlg('We ran into an issue trying to add the current well''s growth statistics to the ''all_results.csv'' file. This is usually because the file is open. Please close the file and try again or skip this step.', ...
            'Save Statistics', ...
            'Try Again', 'Skip', 'Skip');
          if strcmp(answer, 'Skip')
            written_to_disk = true;
          end
        end
      end
    end

    % Create microplate heatmap for swelling (ALL Organoids)
    microplate_growth_matrix = nan(8,12);
    text_labels = cell(8,12);
    for row_num=1:height(allResults)
      col_pos = max(find(contains(allResults.Properties.VariableNames,'Area_Normalized_Change') & ~contains(allResults.Properties.VariableNames,'Sweller')));
      growth = allResults{row_num, col_pos};
      row = allResults{row_num,'row'};
      column = allResults{row_num,'column'};
      microplate_growth_matrix(row,column) = growth;
      col_pos = max(find(contains(allResults.Properties.VariableNames,'Number_of_Organoids')));
      num_organoids = allResults{row_num, col_pos};
      text_labels{row,column} = sprintf('n=%d', num_organoids);
    end
    f = figure(plugin_num+34199); clf; set(f,'name',[plugin_name ' MicroPlate'],'NumberTitle', 'off');
    microplateplot(microplate_growth_matrix,'TEXTLABELS',text_labels,'TextFontSize',10);
    % Sytle
    c=jet(100);
    colormap(c(23:90,:)); %only uses the portion of the color map
    colorbar
    h = suptitle('Organoid Swelling');
    set(h,'FontSize',18,'FontName','Yu Gothic UI');
    title('Relative area growth of all organoids','Interpreter','none','FontName','Yu Gothic UI Light')
    set(gca,'Color',[.95 .95 .95 ]);
    set(gcf,'Color',[1 1 1 ]);
    Fontsize = 16;
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
    pause(0.2)
    fig_name = sprintf('%s_microplate_plot_all.png',save_path_prefix);
    export_fig(fig_name,save_mag);

    % Create microplate heatmap for swelling (ONLY SWELLERS)
    microplate_growth_matrix = nan(8,12);
    text_labels = cell(8,12);
    for row_num=1:height(allResults)
      col_pos = max(find(contains(allResults.Properties.VariableNames,'Area_Normalized_Change') & contains(allResults.Properties.VariableNames,'Sweller')));
      growth = allResults{row_num, col_pos};
      col_pos = max(find(contains(allResults.Properties.VariableNames,'Number_of_Swelling_Organoids')));
      num_swelling_organoids = allResults{row_num, col_pos};
      growth = growth; % scale by percent of swellers
      if isnan(growth)
        growth = 1;
      end
      row = allResults{row_num,'row'};
      column = allResults{row_num,'column'};
      microplate_growth_matrix(row,column) = growth;
      text_labels{row,column} = sprintf('n=%d', num_swelling_organoids);
    end
    f = figure(plugin_num+34191); clf; set(f,'name',[plugin_name ' MicroPlate'],'NumberTitle', 'off');
    microplateplot(microplate_growth_matrix,'TEXTLABELS',text_labels,'TextFontSize',10);
    % Sytle
    c=jet(100);
    colormap(c(23:90,:)); %only uses the portion of the color map
    colorbar
    h = suptitle('Organoid Swelling');
    set(h,'FontSize',18,'FontName','Yu Gothic UI');
    title('Relative area growth of swelling organoids only','Interpreter','none','FontName','Yu Gothic UI Light')
    set(gca,'Color',[.95 .95 .95 ]);
    set(gcf,'Color',[1 1 1 ]);
    Fontsize = 16;
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
    pause(0.2)
    fig_name = sprintf('%s_microplate_plot_swellers.png',save_path_prefix);
    export_fig(fig_name,save_mag);

    % Create microplate heatmap for swelling (ONLY SWELLERS scalled by % of swellers)
    microplate_growth_matrix = nan(8,12);
    text_labels = cell(8,12);
    for row_num=1:height(allResults)
      col_pos = max(find(contains(allResults.Properties.VariableNames,'Area_Normalized_Change') & contains(allResults.Properties.VariableNames,'Sweller')));
      growth = allResults{row_num, col_pos};
      col_pos = max(find(contains(allResults.Properties.VariableNames,'Number_of_Swelling_Organoids')));
      num_swelling_organoids = allResults{row_num, col_pos};
      col_pos = max(find(contains(allResults.Properties.VariableNames,'Number_of_Organoids')));
      num_organoids = allResults{row_num, col_pos};
      perc_of_swellers = num_swelling_organoids/num_organoids;
      growth = growth*perc_of_swellers; % scale by percent of swellers
      if isnan(growth)
        growth = 0;
      end
      row = allResults{row_num,'row'};
      column = allResults{row_num,'column'};
      microplate_growth_matrix(row,column) = growth;
      text_labels{row,column} = sprintf('n=%d', num_swelling_organoids);
    end
    f = figure(plugin_num+34190); clf; set(f,'name',[plugin_name ' MicroPlate'],'NumberTitle', 'off');
    microplateplot(microplate_growth_matrix,'TEXTLABELS',text_labels,'TextFontSize',10);
    % Sytle
    c=jet(100);
    colormap(c(23:90,:)); %only uses the portion of the color map
    colorbar
    h = suptitle('Organoid Swelling');
    set(h,'FontSize',18,'FontName','Yu Gothic UI');
    title('Relative area growth of swelling organoids only with growth scaled by % of swellers vs non-swellers','Interpreter','none','FontName','Yu Gothic UI Light')
    set(gca,'Color',[.95 .95 .95 ]);
    set(gcf,'Color',[1 1 1 ]);
    Fontsize = 16;
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
    pause(0.2)
    fig_name = sprintf('%s_microplate_plot_scaled_swellers.png',save_path_prefix);
    export_fig(fig_name,save_mag);

  end


end
