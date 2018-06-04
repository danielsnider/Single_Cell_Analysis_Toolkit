function cmap = get_n_length_colormap(map_name, num_desired_colors, shuffle)
  eval(sprintf('cmap = colormap(%s(%d));', map_name, num_desired_colors));
  if exist('shuffle')
    cmap = cmap(randperm(size(cmap,1)),:);
  end
end