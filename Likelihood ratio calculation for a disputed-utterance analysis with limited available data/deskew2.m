function [tranformed_data, angle, shift] = deskew2(data)
% Designed to reduce skew of VOT data from two plosives where one is lead than the other lag VOT
% Uses an arctan tranform with angle and phase chosed via a simplex algorithm to minimise mean skew
% Assumes input is a cell containing two vectors, one for each plosive
% Each vector contains a set of VOT measurments in ms
%
% transform is arctan(theta * (v + phi)) so phi is a shift in ms rather than in phase

% initial parameters for optimization
angle = 0;
shift = 0;


% cost function to minimised by simplex search
% paper says it is mean skewness of both caterories (dropped divide by 2 beacuse it is unneccesary)
% note: params(1) = angle, params(2) = shift 
cost_skew = @(params)...
    abs(skewness(atan( params(1) * (data{1}(:) + params(2)) )))...
    + abs(skewness(atan( params(1) * (data{2}(:) + params(2)) )));

% simplex search
angle_shift = fminsearchbnd(cost_skew, [angle shift]);

% optimized parameters
angle = angle_shift(1);
shift = angle_shift(2);

% transform the data
tranformed_data = cell(1, 2);
for II = 1:2
    tranformed_data{II} = atan( angle * (data{II}(:) + shift) );
end

