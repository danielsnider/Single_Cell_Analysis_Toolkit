function img = fun(plugin_name, plugin_num, img, correction_path)
  if isempty(correction_path)
      return
  end
  correction_mat = load(correction_path); % load correction
  img = img - correction_mat; % do correction
end