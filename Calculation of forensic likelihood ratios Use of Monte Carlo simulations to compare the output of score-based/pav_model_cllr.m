function [log10LR, cllr_var] = pav_model_cllr (x_test, x_same, x_different)
% fit non-parametric pool-adjacnet-violators model and produce LR of test data
% scores must be positively correlated with strength of evidence
% returns LR value of training dataum which is nearest to test datum
% uses Niko Brümmer's Focal Toolkit

x_test_size = size(x_test);
x_test = x_test(:)';
x_same = x_same(:)';
x_different = x_different(:)';

[y_same, y_different] = opt_loglr(x_same, x_different);

x_all = [x_same, x_different];
y_all = [y_same, y_different];

num_x_test = length(x_test);
logLR = NaN(1, num_x_test);
for I_test = 1:num_x_test
    [~, II] = min(abs(x_all - x_test(I_test)));
    logLR(I_test) = y_all(II);
end
log10LR = logLR / log(10);
log10LR = reshape(log10LR, x_test_size);

cllr_var = cllr(y_same, y_different);