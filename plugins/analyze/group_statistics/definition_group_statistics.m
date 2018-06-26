function [params, algorithm] = fun()

  algorithm.name = 'Group Statistics';
  algorithm.help = 'Group measurements by one or more columns, for example group by experiment, and calculate basic statistics within the group: min, max, range, mean, median, mode and more. Note that NaNs values are treated as missing values. They are removed from the input data before calculating summary statistics.';
  algorithm.image = 'group_statistics.png';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Group By';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'MeasurementListBox';

  n = n + 1;
  params(n).name = 'Summary Statistics';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'listbox';
  params(n).options = { 'Mean', ...
                        'Median', ...
                        'Mode', ...
                        'Minimum', ...
                        'Maximum', ...
                        'Range', ...
                        'Standard error of the mean', ...
                        'Standard deviation', ...
                        'Variance', ...
                        '95% confidence interval for the mean', ...
                        '95% prediction interval for a new observation'...
  };

  n = n + 1;
  params(n).name = 'For Measurements';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'MeasurementListBox';
  
  n = n + 1;
  params(n).name = 'Save CSV to';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'text';

  n = n + 1;
  params(n).name = 'Ignore Infinite Values';
  params(n).default = false;
  params(n).help = 'Discard infitite values from input data before calculating summary statistics.';
  params(n).type = 'checkbox';

  n = n + 1;
  params(n).name = 'ResultTable';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'ResultTable_Box';

end
