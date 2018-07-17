function [params, algorithm] = fun()

  algorithm.name = 'Area Change Analysis';
  algorithm.help = 'This plugin visualizes the changes of segmented area of objects over time. Each colored line respresents an object''s perimeter at a point in time. The first timepoint is blue and the last timepoint is red with a color gradient in between.';
  algorithm.image = 'area_change_timelapse.png';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Operate On';
  params(n).help = '';
  params(n).type = 'operate_on';
  params(n).options = {'Current Time Course', 'All Time Courses'};
  params(n).default = 'Current Time Course';

  n = n + 1;
  params(n).name = 'Change Over Time for Segment';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'segment_dropdown';

  n = n + 1;
  params(n).name = 'Visualize on Image Channel';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'image_channel_dropdown';
  params(n).optional = true;

  n = n + 1;
  params(n).name = 'Save Visualization to Disk';
  params(n).default = false;
  params(n).help = '';
  params(n).type = 'checkbox';

  n = n + 1;
  params(n).name = 'Max Dynamic Range (%)';
  params(n).default = 99;
  params(n).help = 'Choose to brighten the image for viewing only so that pixels above the value set here become full brightness.';
  params(n).type = 'numeric';
  params(n).limits = [0.001 100];

  n = n + 1;
  params(n).name = 'Remove Abridged Tracking';
  params(n).default = false;
  params(n).help = '';
  params(n).type = 'checkbox';

  n = n + 1;
  params(n).name = 'Save Growth Plot to Disk';
  params(n).default = false;
  params(n).help = '';
  params(n).type = 'checkbox';

  n = n + 1;
  params(n).name = 'Save Results To';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'text';

  n = n + 1;
  params(n).name = 'Save Figure at Magnification';
  params(n).default = 1;
  params(n).help = '';
  params(n).type = 'numeric';
  params(n).limits = [0.001 10];

end
