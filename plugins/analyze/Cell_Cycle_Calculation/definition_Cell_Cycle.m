function [params, algorithm] = fun()

  algorithm.name = 'Cell Cycle Length';
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
  params(n).help = 'Enter the measurment name used in Excel Plate Map. I.e "TimePoint".';
  params(n).type = 'text';

  n = n + 1;
  params(n).name = 'Plotting';
  params(n).default = '';
  params(n).help = 'Choose what plots you want';
  params(n).type = 'listbox';
  params(n).options = {'None', 'MicroPlate'};
  
    n = n + 1;
  params(n).name = 'Title for Plot if applicable';
  params(n).default = '';
  params(n).help = 'Enter a title name for your plot.';
  params(n).type = 'text';
  
  n = n + 1;
  params(n).name = 'Row_Name';
  params(n).default = '';
  params(n).help = 'Choose what metadata you want for the Row Labels.';
  params(n).type = 'MeasurementListBox';
  
  n = n + 1;
  params(n).name = 'Column_Name';
  params(n).default = '';
  params(n).help = 'Choose what metadata you want for the Column Labels.';
  params(n).type = 'MeasurementListBox';
  
end
