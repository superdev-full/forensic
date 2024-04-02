function y = interpolate1(x, length_new)
length_original = length(x);
t_interp=[1:length_original/length_new:length_original]';
if length(t_interp) == length_new - 1, t_interp = [t_interp; t_interp(end)]; end %occasionally get rounding errors - note: using step size length_original/(length_new+1) results in rounding errors in other direction
y = interp1(x, t_interp);
end
