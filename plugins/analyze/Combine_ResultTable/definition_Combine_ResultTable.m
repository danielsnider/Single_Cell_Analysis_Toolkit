function [params, algorithm] = fun()

  algorithm.name = 'Combine ResultTable';
  algorithm.help = 'Work In Progress .... Combine multiple ResultTables from the same experiment differentiated by time points.';
  algorithm.image = 'bkntjoin.gif';
  algorithm.maintainer = 'Justin Sing <justincsing@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Input';
  params(n).default = '';
  params(n).help = 'Enter the paths to the ResultTables and add the corresponding TimePoint for each ResultTable Data';
  params(n).type = 'InputUITable';
  params(n).sub_tab = 'Main';
  
%   n = n + 1;
%   params(n).name = 'Measurement';
%   params(n).default = '';
%   params(n).help = 'Enter the measurment name used in Excel Plate Map. I.e "TimePoint".';
%   params(n).type = 'text';
%   params(n).sub_tab = 'Main';
%   
%   n = n + 1;
%   params(n).name = 'Imaging Type';
%   params(n).default = '';
%   params(n).help = 'Enter the type of imaging technique used in this experiemnt. Either DPC or fixed/stained cells';
%   params(n).type = 'listbox';
%   params(n).options = {'DPC','Fixed'};
%   params(n).sub_tab = 'Main';
  
  n = n + 1;
  params(n).name = 'Pre-Processing';
  params(n).default = '';
  params(n).help = 'Do you want to pre-process the data by averaging replicate datasets or do you want to do any normalization?';
  params(n).type = 'listbox';
  params(n).options = {'None','Average Replicates','Normalize'};
  params(n).sub_tab = 'Pre-Processing';
 
  n = n + 1;
  params(n).name = 'Control Treatment';
  params(n).default = '';
  params(n).help = 'What treatment did you use as a control i.e.: DMSO';
  params(n).type = 'text';
  params(n).optional = false;
  params(n).sub_tab = 'Pre-Processing';

  n = n + 1;
  params(n).name = 'Normalize against';
  params(n).default = '';
  params(n).help = 'What do you want to normalize by?';
  params(n).type = 'WellConditionListBox';
  params(n).optional = false;
  params(n).sub_tab = 'Pre-Processing';
  
  n = n + 1;
  params(n).name = 'Plotting';
  params(n).default = '';
  params(n).help = 'Choose what plots you want';
  params(n).type = 'listbox';
  params(n).options = {'None', 'MicroPlate'};
  params(n).sub_tab = 'Plotting';
  
    n = n + 1;
  params(n).name = 'Plot Title';
  params(n).default = '';
  params(n).help = 'Enter a title name for your plot.';
  params(n).type = 'text';
  params(n).optional = false;
  params(n).sub_tab = 'Plotting';
  
  n = n + 1;
  params(n).name = 'Row_Name';
  params(n).default = '';
  params(n).help = 'Choose what metadata you want for the Row Labels.';
  params(n).type = 'MeasurementListBox';
  params(n).optional = false;
  params(n).sub_tab = 'Plotting';
  
  n = n + 1;
  params(n).name = 'Column_Name';
  params(n).default = '';
  params(n).help = 'Choose what metadata you want for the Column Labels.';
  params(n).type = 'MeasurementListBox';
  params(n).optional = false;
  params(n).sub_tab = 'Plotting';
  
end
