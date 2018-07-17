function cmap = get_n_length_cmap(map_name, num_desired_colors)
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
end