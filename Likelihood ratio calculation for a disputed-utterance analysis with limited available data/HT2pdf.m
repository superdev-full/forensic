function [L, F, t2] = HT2pdf(y, x)
% Hotelling's T^2 distribution pdf
% INPUTS:
% y     vector of data point at which to evaluate pdf
% x     data to train distribution (variables as columns and cases as rows)
% OUTPUT:
% L     pdf value (likelihood)

% make sure y is a column vector
y = y(:);


[num_data_points, num_var] = size(x);

mean_x = mean(x,1);

cov_x = cov(x);

y_minus_mean_x = y - mean_x';

% % treat y as the specified mean in a one-sample test
% t2 = num_data_points * y_minus_mean_x' * inv(cov_x) * y_minus_mean_x;
% treat y as a second sample (of size 1) in a two-sample test
t2 = (num_data_points / (num_data_points + 1)) * y_minus_mean_x' * inv(cov_x) * y_minus_mean_x;

F = t2 * (num_data_points - num_var) / (num_data_points * (num_var - 1));

L = fpdf(F, num_var, num_data_points - num_var);