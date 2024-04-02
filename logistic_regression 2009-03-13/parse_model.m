function [stim_matrix, var_string] = parse_model(temp_stim_matrix, stimcols, model_string)
    Ivar = 0;
    while ~isempty(model_string)
        Ivar = Ivar + 1;
        [var_string{Ivar}, model_string] = strtok(model_string, '+');
    end %while ~isempty(model_string)
    stim_matrix = NaN(size(temp_stim_matrix,1), Ivar);
    for Icol = 1:Ivar
        if strfind(var_string{Icol}, '*')
            model_substring = var_string{Icol};
            Isubvar = 0;
            while ~isempty(model_substring)
                Isubvar = Isubvar + 1;
                [var_substring{Isubvar}, model_substring] = strtok(model_substring, '*');
            end %while ~isempty(model_substring)
            stimcol_to_multiply = NaN(1,Isubvar);
            for Isubcol = 1:Isubvar
                stimcol_to_multiply(Isubcol) = strmatch(var_substring{Isubcol}, stimcols);
            end %for Isubcol = 1:Isubvar
            stim_matrix(:,Icol) = temp_stim_matrix(:, stimcol_to_multiply(1));
            for Isubcol = 2:Isubvar
                stim_matrix(:,Icol) = stim_matrix(:,Icol) .* temp_stim_matrix(:, stimcol_to_multiply(Isubcol));
            end %for Isubcol = 2:Isubvar
        else
            stimcol_to_add = strmatch(var_string{Icol}, stimcols);
            stim_matrix(:,Icol) = temp_stim_matrix(:, stimcol_to_add);
        end %if strfind(var_string{Icol}, '*')
    end %for Icol = 1:Ivar
return
    
