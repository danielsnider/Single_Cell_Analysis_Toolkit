function result = plugin_implementation(plugin_name, plugin_num, n, Exclamation)

  for i=1:n
    fprintf('Hello World%s\n', Exclamation);
  end
  result = 'here is where you return a segmentation Matrix or a measurement Table';
