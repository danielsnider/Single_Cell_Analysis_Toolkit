function [params, algorithm] = fun()

  algorithm.name = 'Count Consecutive Values';
  algorithm.help = 'Count the amount of consecutive time a chosen metric is within a chosen threshold, for each uniquely tracked object ID.';
  algorithm.image = 'calculate_dwell_time.png';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Value to analyze';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Count if value is below';
  params(n).default = 1;
  params(n).help = '';
  params(n).type = 'numeric';
  params(n).optional = true;
  params(n).optional_default_state = true;
  
  n = n + 1;
  params(n).name = 'Count if value is above';
  params(n).default = 1;
  params(n).help = '';
  params(n).type = 'numeric';
  params(n).optional = true;
  params(n).optional_default_state = false;

  n = n + 1;
  params(n).name = 'Tracking ID';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Store Extra Info';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';
  params(n).optional = true;

  n = n + 1;
  params(n).name = 'Save CSV to';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'text';

  n = n + 1;
  params(n).name = 'ResultTable';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'ResultTable_Box';

end
