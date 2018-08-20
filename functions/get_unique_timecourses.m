function timecourses = fun(app)
  imgs_to_process = get_images_to_process(app);

  if ~isfield(imgs_to_process,'row') || ~isfield(imgs_to_process,'column') || ~isfield(imgs_to_process,'row')
    title = 'Unsupported Request'
    msg = 'Finding the unique time courses in your image set cannot be performed because the images available do not have the required row, column, and field information. An example image type that has this information and would work is ''IncuCyte'', ''OperettaSplitTiffs'', and ''CellomicsTiffs''';
    throw_application_error(app,msg,title);
  end
 
  uniq_sets = unique([imgs_to_process.row; imgs_to_process.column; imgs_to_process.field]','rows');
  
  timecourses = struct();
  for ii=1:size(uniq_sets,1)
    row = uniq_sets(ii, 1);
    column = uniq_sets(ii, 2);
    field = uniq_sets(ii, 3);
    timecourses(ii).row = row;
    timecourses(ii).column = column;
    timecourses(ii).field = field;

    % Get all the timepoints that exist at this row, column, and field position.
    timepoint_imgs = imgs_to_process([imgs_to_process.row] == row & [imgs_to_process.column] == column & [imgs_to_process.field] == field);
    timecourses(ii).timepoints = [timepoint_imgs.timepoint];

    timecourses(ii).plate_num = timepoint_imgs(1).plate_num;
  end


end