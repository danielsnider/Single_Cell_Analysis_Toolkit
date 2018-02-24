function [params, algorithm] = fun()

  algorithm.name = 'Cell Cycle';
  algorithm.help = 'Calculate Cell Cycle Length using Least Linear Squares Fitting.';
  algorithm.image = 'Cell_Cycle_Duration.gif';
  algorithm.maintainer = 'Justin Sing <justincsing@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'ResultTable';
  params(n).default = '';
  params(n).help = 'Current Loaded ResultTable to do analysis on.';
  params(n).type = 'ResultTable_Box';
  
  n = n + 1;
  params(n).name = 'Measurement';
  params(n).default = '';
  params(n).help = 'Enter the measurment name used in Excel Plate Map. I.e "TimePoint"';
  params(n).type = 'text';

  n = n + 1;
  params(n).name = 'Plotting';
  params(n).default = '';
  params(n).help = 'Choose what plots you want';
  params(n).type = 'listbox';
  params(n).options = {'None', 'MicroPlate'};
  
  n = n + 1;
  params(n).name = 'Row Name';
  params(n).default = '';
  params(n).help = 'Choose what metadata you want for the Row Labels';
  params(n).type = 'WellMetaInfo_List';
  params(n).options = {'None'};
  
  n = n + 1;
  params(n).name = 'Column Name';
  params(n).default = '';
  params(n).help = 'Choose what metadata you want for the Column Labels';
  params(n).type = 'listbox';
  params(n).options = {'None'};
  
end
