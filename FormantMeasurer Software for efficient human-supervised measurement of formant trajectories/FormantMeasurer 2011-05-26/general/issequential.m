function k = issequential(x)
% tests whether x(1)<x(2), x(3)<x(4), etc.

k = true;
for ii = 2:2:length(x)
    if x(ii) <= x(ii-1)
        k = false;
        break
    end
end

return