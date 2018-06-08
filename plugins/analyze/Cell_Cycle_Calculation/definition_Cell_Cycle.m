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
  params(n).sub_tab = 'Main';
  
  n = n + 1;
  params(n).name = 'Old GUI?';
  params(n).default = false;
  params(n).help = 'Was the ResultTable data generated with the old GUI (O_GUI_6)?';
  params(n).type = 'checkbox';
  params(n).sub_tab = 'Main';
  
  n = n + 1;
  params(n).name = 'Measurement';
  params(n).default = '';
  params(n).help = 'Enter the measurment name used in Excel Plate Map. I.e "TimePoint".';
  params(n).type = 'text';
  params(n).sub_tab = 'Main';
  
  n = n + 1;
  params(n).name = 'Imaging Type';
  params(n).default = '';
  params(n).help = 'Enter the type of imaging technique used in this experiemnt. Either DPC or fixed/stained cells';
  params(n).type = 'listbox';
  params(n).options = {'DPC','Fixed'};
  params(n).sub_tab = 'Main';
  
  n = n + 1;
  params(n).name = 'Average Replicates';
  params(n).default = false;
  params(n).help = 'Do you want to pre-process the data by averaging replicate datasets';
  params(n).type = 'checkbox';
  params(n).sub_tab = 'Main';
 
  n = n + 1;
  params(n).name = 'Control Treatment';
  params(n).default = '';
  params(n).help = 'What treatment did you use as a control i.e.: DMSO';
  params(n).type = 'text';
  params(n).sub_tab = 'Main';
  
   n = n + 1;
  params(n).name = 'Row Treatment';
  params(n).default = '';
  params(n).help = 'What treatment was applied to the rows?';
  params(n).type = 'MeasurementListBox';
  params(n).sub_tab = 'Main';
  
  n = n + 1;
  params(n).name = 'Column Treatment';
  params(n).default = '';
  params(n).help = 'What treatment was applied to the columns?';
  params(n).type = 'MeasurementListBox';
  params(n).sub_tab = 'Main';
  
  n = n + 1;
  params(n).name = 'Nucleus Channel';
  params(n).default = '';
  params(n).help = 'Channel for Nucleus';
  params(n).type = 'MeasurementListBox';
  params(n).sub_tab = 'Fixed Imaging Args';
  
  n = n + 1;
  params(n).name = 'Cell Cycle Channel';
  params(n).default = '';
  params(n).help = 'Channel for a Cell Cycle Stage Reporter';
  params(n).type = 'MeasurementListBox';
  params(n).sub_tab = 'Fixed Imaging Args';
  
  n = n + 1;
  params(n).name = 'Cytosol Channel';
  params(n).default = '';
  params(n).help = 'Channel for cyctosol';
  params(n).type = 'MeasurementListBox';
  params(n).sub_tab = 'Fixed Imaging Args';
  
  n = n + 1;
  params(n).name = 'Nucelus Area';
  params(n).default = '';
  params(n).help = 'Measurement of the nucelus area';
  params(n).type = 'MeasurementListBox';
  params(n).sub_tab = 'Fixed Imaging Args';
  
  n = n + 1;
  params(n).name = 'Bulk Measure';
  params(n).default = '';
  params(n).help = 'What bulk measure to use to calculate Growth Rate?';
  params(n).type = 'listbox';
  params(n).options = {'TotalProt','MeanProt','MedProt','CVProt'};
  params(n).sub_tab = 'Fixed Imaging Args';
  
  n = n + 1;
  params(n).name = 'Verbose Plotting';
  params(n).default = false;
  params(n).help = 'Do you want a verbose plotting? Or do you want only relevant plots of CCL';
  params(n).type = 'checkbox';
  params(n).sub_tab = 'Plotting';
  
  n = n + 1;
  params(n).name = 'Plot Title';
  params(n).default = '';
  params(n).help = 'Enter a title name for your plot.';
  params(n).type = 'text';
  params(n).sub_tab = 'Plotting';
  
  n = n + 1;
  params(n).name = 'Row_Name';
  params(n).default = '';
  params(n).help = 'Choose what metadata you want for the Row Labels.';
  params(n).type = 'MeasurementListBox';
  params(n).sub_tab = 'Plotting';
  
  n = n + 1;
  params(n).name = 'Column_Name';
  params(n).default = '';
  params(n).help = 'Choose what metadata you want for the Column Labels.';
  params(n).type = 'MeasurementListBox';
  params(n).sub_tab = 'Plotting';
  
end
