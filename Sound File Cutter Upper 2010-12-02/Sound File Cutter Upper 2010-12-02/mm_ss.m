function [minutes_seconds_string] = mm_ss(seconds)

minutes_string = num2str(floor(seconds / 60), '%02.0f');

seconds_string = num2str(floor(rem(seconds, 60)), '%02.0f');

tenths_hundredths_string = num2str(floor(rem(seconds, 1) * 100), '%02.0f');

minutes_seconds_string = [minutes_string, '-' seconds_string, '-', tenths_hundredths_string];

return