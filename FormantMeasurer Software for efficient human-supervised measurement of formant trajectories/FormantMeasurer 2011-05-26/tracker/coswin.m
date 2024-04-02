%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/coswin.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:coswin.m 2002/11/6 19:5

function win=coswin(nwin,p);
%	win=coswin(nwin,p);
	win= (.5 - .5*cos(2*pi*(0:nwin-1)'/(nwin-1))).^p;
return
