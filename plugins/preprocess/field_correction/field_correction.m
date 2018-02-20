function img = fun(plugin_name, plugin_num, img, correction_path)
  correction_mat = load(correction_path); % load correction
  img = img - correction_mat; % do correction
end