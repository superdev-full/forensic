%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/uigetpath.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:filetools:uigetpath.m 2002/11/6 19:5

function wholepathname=uigetpath(filterspec, dialogTitle, x,y);
%function wholepathname=uigetpath(filterspec, dialogTitle, x,y);
%  [FILENAME, PATHNAME] = UIGETFILE('filterSpec', 'dialogTitle', X, Y)
tnargin=nargin;
switch tnargin
case 0, [f,p]=uigetfile('*.*');
case 1, [f,p]=uigetfile(filterspec);
case 2, [f,p]=uigetfile(filterspec,dialogTitle);
case 3, [f,p]=uigetfile(filterspec,dialogTitle,x);
otherwise, [f,p]=uigetfile(filterspec,dialogTitle,x,y);
end
if ~isstr(f),
	wholepathname=0;
else
	wholepathname=[p,f];
end
