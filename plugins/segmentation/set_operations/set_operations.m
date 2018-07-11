function result = func(plugin_name, plugin_num, A, operation, B)

  is_3D = false;
  new_bwlabel = @bwlabel;
  if ndims(A) == 3
    is_3D = true;
    new_bwlabel = @bwlabeln;
  end

  if strcmp(operation,'Subtraction')
    result = A;
    result(B>0)=0;
  elseif strcmp(operation,'Intersect')
    result = A & B;
  elseif strcmp(operation,'Symmetric Difference')
    result = xor(A,B);
  elseif strcmp(operation,'Union')
    result = A;
    result(B>0)=1;
  end

  result = new_bwlabel(result);
end