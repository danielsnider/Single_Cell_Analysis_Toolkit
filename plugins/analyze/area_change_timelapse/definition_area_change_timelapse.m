function [params, algorithm] = fun()

  algorithm.name = 'Area Change Analysis';
  algorithm.help = 'This plugin visualizes the changes of segmented area of objects over time. Each colored line respresents an object''s perimeter at a point in time. The first timepoint is blue and the last timepoint is red with a color gradient in between.';
  algorithm.image = 'area_change_timelapse.png';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Operate On';
  params(n).help = 'Choose whether to analyze the currently displayed image and it''s timelapse set of images, or to analyze all timelapes (takes much longer).';
  params(n).type = 'operate_on';
  params(n).options = {'Current Time Course', 'All Time Courses'};
  params(n).default = 'Current Time Course';

  n = n + 1;
  params(n).name = 'Segment';
  params(n).default = 'The region of interest that will be analyzed';
  params(n).help = '';
  params(n).type = 'segment_dropdown';

  n = n + 1;
  params(n).name = 'Image Channel';
  params(n).default = 'The image of interest for visualization purposes.';
  params(n).help = '';
  params(n).type = 'image_channel_dropdown';
  params(n).optional = true;

  n = n + 1;
  params(n).name = 'Save Visualization to Disk';
  params(n).default = false;
  params(n).help = 'A rainbow growth visualization will be saved to disk.';
  params(n).type = 'checkbox';

  n = n + 1;
  params(n).name = 'Max Dynamic Range (%)';
  params(n).default = 99.5;
  params(n).help = 'Choose to brighten the image for viewing only so that pixels above the value set here become full brightness.';
  params(n).type = 'numeric';
  params(n).limits = [0.001 100];

  n = n + 1;
  params(n).name = 'Remove Abridged Tracking';
  params(n).default = false;
  params(n).help = 'Objects that are not seen present in all timepoints are removed when this option is checked.';
  params(n).type = 'checkbox';

  n = n + 1;
  params(n).name = 'Minimum Growth';
  params(n).default = '1.5%';
  params(n).help = 'Don''t count objects that grow less than this amount. Enter between -999% and 999%.';
  params(n).type = 'text';
  params(n).optional = true;
  params(n).optional_default_state = true;

  n = n + 1;
  params(n).name = 'Save Growth Plot to Disk';
  params(n).default = false;
  params(n).help = 'A growth plot will be saved to disk.';
  params(n).type = 'checkbox';

  n = n + 1;
  params(n).name = 'Manually Filter Organoids';
  params(n).default = 'Off';
  params(n).help = 'By manually clicking on organiods you can choose whether to keep or remove them.';
  params(n).type = 'dropdown';
  params(n).options = {'Click to Keep','Click to Remove','Off'};

  n = n + 1;
  params(n).name = 'Save Results To';
  params(n).default = '';
  params(n).help = 'The output folder to save statistics, plots, and visualizations.';
  params(n).type = 'text';

end
