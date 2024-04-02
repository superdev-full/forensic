%  Saved from C:\NeareyMLTools\GraphTools\splitfig2313.m 2006/10/12 15:18

function [ax1,ax2]=splitfig2313
%[ax1,ax2]=splitfig2313
% set up subplot axes top 1/5 and bottom 4/5 of screen
% Select with subplot(ax1), subplot(ax2) respectively

p23top=[ 0.13          0.41          0.78          0.50];
ax1=subplot('position',p23top);
ax2=subplot(3,1,3);
