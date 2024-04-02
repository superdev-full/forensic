function [tranformed_data, angle] = deskew1(data)
% Designed to reduce skew of VOT data from two plosives where one is lead than the other lag VOT
% Uses an arctan tranform with angle and phase chosed via a simplex algorithm to minimise mean skew
% Assumes input is a cell containing two vectors, one for each plosive
% Each vector contains a set of VOT measurments in ms
%
%
% transform is arctan(theta*v)


% initial parameters for optimization
angle = 0;


% cost function to minimised by simplex search
cost_skew = @(param)...
    abs(skewness(atan( param * data{1}(:) )))...
    + abs(skewness(atan( param * data{2}(:) )));

% simplex search
angle = fminsearch(cost_skew, angle);


% transform the data
tranformed_data = cell(1, 2);
for II = 1:2
    tranformed_data{II} = atan( angle * data{II}(:) );
end

