function fun(app)
  f = figure(111); clf; set(f, 'name','Image','NumberTitle', 'off')

  app.seeds{idx}
  app.labels{idx}
  app.measurements{idx}

  idx = 1
  app.figure{idx}.seeds{idx}.color = [1 0 0];
  % app.figure{idx}.label{idx}
  % app.figure{idx}.measurements{idx}
  app.figure{idx}.channels{1}.color = [1 0 0];
  app.figure{idx}.channels{2}.color = [1 0 0];
  app.figure{idx}.channels{3}.color = [1 0 0];
  app.figure{idx}.plate = 1;
  app.figure{idx}.row = 1;
  app.figure{idx}.column
  app.figure{idx}.field
  app.figure{idx}.timepoint
  

  if isfield(app.figure,'fields')
    t = 1
  end

  %% Display RGB Overlay Image
  output_image = zeros(size(app.cyto,1),size(app.cyto,2));
  % Select only cells for the selected folder
  subsetTable=subsetTable(find(strcmp(subsetTable.Folder,{app.folder})),:);

  % Show channels
  if app.displayCyto
      output_image = output_image + double(app.cyto(:,:,str2num(app.img_id)));
  end
  if app.displayReporter
      output_image = output_image + double(app.pdx(:,:,str2num(app.img_id)));
  end
  if app.displayNuc
      output_image = output_image + double(app.nuc(:,:,str2num(app.img_id)));
  end
  labelled_cyto = zeros(size(app.cyto));
  subsetTable = subsetTable(find(strcmp(subsetTable.Folder,{app.folder})),:);
  for i=1:height(subsetTable)
    PixelIdxList = cell2mat(subsetTable{i,{'PixelIdxList'}});
    labelled_cyto(PixelIdxList)=i;
  end
  
  cla(app.UIAxes);
  imshow(output_image,[],'Parent',app.UIAxes);
  hold(app.UIAxes, 'on');
  labelled_cyto_rgb = label2rgb(uint32(labelled_cyto(:,:,str2num(app.img_id))), 'jet', [1 1 1], 'shuffle');
  himage = imshow(labelled_cyto_rgb,[],'Parent',app.UIAxes);
  himage.AlphaData = 0.1;
  axis off
end
