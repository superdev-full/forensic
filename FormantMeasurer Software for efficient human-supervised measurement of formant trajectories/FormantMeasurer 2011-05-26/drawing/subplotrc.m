%  Saved from C:\NeareyMLTools\GraphTools\subplotrc.m 2006/10/12 15:18

function h=subplotrc(mr,nc,r,c)
% function h=subplotrc(mr,nc,r,c)
% select the r-th row and c-th column of matlab subplot layout
% subplot(mr,nc)
% Copyright 2003 TMN
% If called with one argument == 'tight' (in any case), then tight mode is applied till turned
% off (Tight mode = narrow boarders)
% If tight, it calls the TMN hacked subroutint subplot_tight
persistent mode
if isempty(mode)
    mode='REGULAR';
end
if nargin==1
    if isequal(upper(mr),'TIGHT')
        mode='TIGHT';
    else
        mode='REGULAR';
    end
    return
end

ith=c+nc*(r-1);
if isequal(mode,'TIGHT')
    th=subplot_tight(mr,nc,ith);
else
th=subplot(mr,nc,ith);
end
if nargout>0
    h=th;
end
