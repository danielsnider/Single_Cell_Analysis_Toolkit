function [params, algorithm_name, algorithm_help] = fun()

  algorithm_name = 'Simple Scatter';
  algorithm_help = '';

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
  params(n).default = 2;
  params(n).help = 'Set the size of the points plotted.';
  params(n).type = 'numeric';
  params(n).limits = [0 Inf];


end
