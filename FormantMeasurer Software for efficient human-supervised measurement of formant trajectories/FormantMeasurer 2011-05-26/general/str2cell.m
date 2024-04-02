function cell_str = str2cell(str)

cell_str = {};
I_cell = 0;
while ~isempty(str)
    I_cell = I_cell + 1;
    [cell_str{I_cell}, str] = strtok(str);
end