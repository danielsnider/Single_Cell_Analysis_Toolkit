function [output]=str2bool(string)
try
    if strcmpi(string,'false') || strcmpi(string,'f')
        output = false;
    else
        output = true;
    end
catch
    sprintf('%s is not a valid string representation that can be converted into true or false.', stirng)
end
end