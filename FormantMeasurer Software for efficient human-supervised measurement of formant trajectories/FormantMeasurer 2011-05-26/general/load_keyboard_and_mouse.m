% load_keyboard_and_mouse

[var_name var_value] = textread('KeyboardMouse.ini','%s\t%s', 'whitespace', '\t');
for Ivar = 1:length(var_name)
    var_test = str2double(var_value{Ivar});
    if isnan(var_test)
        var_value{Ivar} = double(var_value{Ivar});
    else
        var_value{Ivar} = var_test;
    end
    assignin('caller', var_name{Ivar}, var_value{Ivar}); % assign strings to vars
end

