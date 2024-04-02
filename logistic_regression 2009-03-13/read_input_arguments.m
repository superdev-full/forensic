% read_input_arguments.m

[var_name var_value] = textread('Logistic_Regression_input_arguments.txt','%s\t%s', 'whitespace', '\t');
for Ivar = 1:length(var_name)
    assignin('caller', var_name{Ivar}, var_value{Ivar}); % assign strings to vars
    % note: have to use 'caller' rather than 'base' if nested within function for compiled version
end