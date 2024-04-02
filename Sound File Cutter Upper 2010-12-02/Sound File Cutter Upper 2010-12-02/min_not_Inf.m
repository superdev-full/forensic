function x_min = min_not_Inf(x)
% Miniumum value expcluding -Inf
II_Inf = isinf(x);
x_min = min(x(~II_Inf));
end
