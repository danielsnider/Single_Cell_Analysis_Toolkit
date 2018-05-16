function cmap = get_n_length_colormap(map_name, num_desired_colors, shuffle)
  f = figure; % set cmap size to default
  cmap = colormap(map_name);
  delete(f)
  cmap_size = size(cmap,1);
  interval = cmap_size / num_desired_colors;
  subset_cmap = [];
  for idx=1:num_desired_colors
    cmap_index = round(interval * idx);
    subset_cmap(idx,:) = cmap(cmap_index,:);
  end
  cmap=subset_cmap;

  if exist('shuffle')
    cmap = cmap(randperm(length(cmap)),:);
  end

end