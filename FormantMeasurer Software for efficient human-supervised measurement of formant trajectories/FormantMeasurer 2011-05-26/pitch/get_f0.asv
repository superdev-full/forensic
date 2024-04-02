%get_f0

%[f0,taxf0]=BoersmaPitch(ysound{soundI},Fs_10,taxsg(1));
%[f0,taxf0]=BoersmaPitch(ysound{soundI},Fs_10,taxsg(1),taxsg(end),minf0,maxf0);

% % 1-x,2-Fs,3-tmin, 4-tmax, 5-minF0,6-maxF0,7-hopMs,8-dwinMs,9-winType,10-MaxNumCandPerFrame,
% % 11-VoicingThreshold,12-SilenceThreshold,13 -OctaveCost,14 -OctaveJumpCost 15-VoicedUnvoicedCost
% % 16-TerpMeth, 17-tol);
% OctaveJumpCost=0.5;
% [f0,taxf0]=BoersmaPitch(ysound{soundI},Fs_10,taxsg(1),taxsg(end),minf0,maxf0, 5, 1000*3/minf0, 'HANNING', 20, .4, OctaveJumpCost, .01, .04, .1);



f0_min = min_minf0 : (max_minf0 - min_minf0)/3 : max_minf0;
f0_max = min_maxf0 : (max_maxf0 - min_maxf0)/3 : max_maxf0;

num_f0_min = 4;
num_f0_max = 4;

f0 = cell(num_f0_min, num_f0_max);
f0_score = NaN(num_f0_min, num_f0_max);

f0_score_mu = log(6.5);
f0_score_sigma = 1;
f0_score_denom = pdf('norm', f0_score_mu, f0_score_mu, f0_score_sigma);
% if you don't have the Statistics Toolbox replace the line above with the following line, and create the pdf_norm function in a different file saved as pdf_norm.m
% f0_score_denom = pdf_norm(f0_score_mu, f0_score_mu, f0_score_sigma);
% function y = pdf_norm(x, mu, sigma)
% y = (1 / (sigma * sqrt(2*pi))) * exp( -(x - mu).^2 / (2*sigma^2));
% return


for I_f0_min = 1:num_f0_min
    dwinMs=1000*3/f0_min(I_f0_min);
    for I_f0_max = 1:num_f0_max
        % may be able to speed this up by pulling out some parts of BoersmaPitch and only doing them once
        [f0_temp,taxf0]=BoersmaPitch(ysound, Fs_10, taxsg(1), taxsg(end), f0_min(I_f0_min), f0_max(I_f0_max), hopMs, dwinMs, winType, MaxNumCandPerFrame, VoicingThreshold, SilenceThreshold, OctaveCost, OctaveJumpCost, VoicedUnvoicedCost, TerpMeth, tol);

        f0_temp = interp1(f0_temp,taxf0,taxsg);
        f0_temp = medsmoterp(f0_temp, 3);
        f0{I_f0_min, I_f0_max} = f0_temp;
        
        % goodness metric based on second derivative
        d_f0 = f0_temp(2:end) - f0_temp(1:end-1);
        d2_f0 = d_f0(2:end) - d_f0(1:end-1);
        
        score1 = 1/(sqrt(mean(d2_f0.^2)));
        
        score2 = log(score1);
        score3 = pdf('norm', score2, f0_score_mu, f0_score_sigma) / f0_score_denom;
        % if you don't have the Statistics Toolbox replace the line above with the following line, and create the pdf_norm function [above] in a different file saved as pdf_norm.m
%         score3 = pdf_norm(score2, f0_score_mu, f0_score_sigma) / f0_score_denom;
        
        f0_score(I_f0_min, I_f0_max) = score3;

%         plot(score2,score3)
%         set(gca, 'XTick', score2, 'XTickLabel', score1)
%         set(gcf,'Pointer','fullcross')
    end
end

haveF0 = true;