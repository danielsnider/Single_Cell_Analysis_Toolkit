function [params, algorithm] = fun()

  algorithm.name = 'Simple Scatter';
  algorithm.help = 'A scatter plot with simple style.';
  algorithm.image = 'simple_scatter_example.png';

  n = 0;
  n = n + 1;
  params(n).name = 'Data X-axis';
  params(n).default = '';
  params(n).help = 'Choose a measure that will be used on the X-axis.';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Data Y-axis';
  params(n).default = '';
  params(n).help = 'Choose a measure that will be used on the X-axis.';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Marker Size';
  params(n).default = 7;
  params(n).help = 'Set the size of the points plotted.';
  params(n).type = 'numeric';
  params(n).limits = [0 Inf];

  n = n + 1;
  params(n).name = 'Figure Title';
  params(n).default = '';
  params(n).help = 'Sets the title of the figure to this parameter.';
  params(n).type = 'text';


end
