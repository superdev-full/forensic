%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/plotsgm.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:plotsgm.m 2002/11/6 19:5

function plotsgm(tax,fax,X,color,dbrng,beta);
%function plotsgm(tax,fax,X,color,dbrng,pow);
% plotsgm(color); --- change from default (jet) to inverse gray;
if nargin<5,
	dbrng=100;
end
if nargin<4|isempty(color)
	color='jet';
end

if (strcmp(upper(color),'GRAY'))|(strcmp(upper(color),'GREY'))
	colormap(flipud('gray'));
else
	colormap('jet');
end
if nargin==6 & ~isempty(beta)
	brighten(beta);
end
xmx=max(X(:));
xmn=xmx-dbrng;
imagesc(tax,fax,max(X,xmn));
axis('xy');




