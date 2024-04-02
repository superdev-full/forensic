%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/parse.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:filetools:parse.m 2002/11/6 19:5

function p=parse(string,delimiters);
%function p=parse(string,delimiters);
%  Parse STRING according to delimiters.  PARSE returns a string matrix in
%  which each row is a subsection of STRING bounded by delimiters.  By
%  default, DELIMTERS is any blankspace character.
% Vers 2.0 uses repeated calls to strtok and strvcat
% Vers 2.1 empty string handled
error(nargchk(1,2,nargin));
if isempty(string)
	p='';
	return
end
if (min(size(string))~=1)|~isstr(string)
        error('STRING must be a vector string.');
end

if nargin<2|isempty(delimiters);
        delimiters=char([9:13,32]);
end
pt=[];
while ~isempty(string)
	[ptt,string]=strtok(string,delimiters);
	pt=strvcat(pt,ptt);
end
p=pt;
