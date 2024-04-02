function true_or_false = str2logical(str)

switch str
    case {'true', '1'}
        true_or_false = true;
    case {'false', '0'}
        true_or_false = false;
    otherwise
        error('Input to function str2logical must be a string containing one of: true, 1, false, 0')
end

return
