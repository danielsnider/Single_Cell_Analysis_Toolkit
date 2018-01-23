function output_txt = imshow_updatefnc(obj, event_obj)
% function output_txt = imshow_updatefnc(obj, event_obj, data, scatter_fig)

% taken from scatter3_datatip of Cell-Barcode
  try


    pos = get(event_obj, 'Position');
    x = pos(1);
    y = pos(2);
    i = event_obj.Target.CData(pos(2), pos(1));

    output_txt = {[sprintf('[X,Y]: [%i, %i]', pos(1), pos(2))], ...
                  [sprintf('Index: %i', i)], ...
                 };


  catch ME
    ME
  end

end
