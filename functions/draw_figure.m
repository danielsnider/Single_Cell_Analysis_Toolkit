function fun(image_name)
  f = figure(111); clf; set(f, 'name','Image','NumberTitle', 'off');
  img = imread(image_name);
  imshow(img,[]);
end