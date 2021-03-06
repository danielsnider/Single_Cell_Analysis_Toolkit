function [params, algorithm] = fun()

  algorithm.name = 'Store Parent Segment ID';
  algorithm.help = 'For each primary segment seen, record what "parent" segment it falls within. The primary segment in this plugin is called the child segment. The centroid of each child segment is used as the location to look for the existance of a parent segment. The parent segment''s unique ID is stored in the UUID format.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';
  algorithm.supports_3D_and_2D = true;
  
  n = 0;
  n = n + 1;
  params(n).name = 'Parent Segment';
  params(n).default = '';
  params(n).help = 'The parent segment you wish to record for each child segment.';
  params(n).type = 'segment_listbox';

  n = n + 1;
  params(n).name = 'Child Segment / Primary Segment';
  params(n).default = '';
  params(n).help = 'Each child segment will be stored with a parent ID as an additional piece of information. This must be a parent segment!';
  params(n).type = 'segment_listbox';

end
