function app_struct = fun(app)
%% Convert's input's class to class struct
app_struct=struct();
app_fields = fieldnames(app);
for name_idx = 1:length(app_fields)
        name = string(app_fields(name_idx));
    app_struct.(name) = app.(name);
end
end % End of function