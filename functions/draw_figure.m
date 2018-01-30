function fun(image_name)
  f = figure(111); clf; set(f, 'name','Image','NumberTitle', 'off');
  img = imread(['images/example_cells/' image_name]);
  imshow(img,[]);
end