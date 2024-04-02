%  Saved from C:\NeareyMLTools\matklatt80\cascade.m 2006/10/12 15:18

function [b,a]=cascade(bp,ap,bz,az);
%function [b,a]=cascade(bp,ap,bz,az);
% cascade (convolve) coefficients for cascaded filters
% This should be enough to cascade anything you want together
% Into one big filter if you like
b=1;
a=1;
if ~isempty(bp)
	b=casc1(bp);
end

if nargin<2, return; end

if ~isempty(ap)
	a=casc1(ap);
end

if nargin<3; return;end

if ~isempty(bz)
	b=casc1(bz,b)
end

if nargin<4; return;end

if ~isempty(az)
	a=casc1(az,a);
end

return

function bt=casc1(b,b2)

bt=b(1,:)

if nargin>1,
	bt=conv(b2,bt);
end
	for i=2:size(b,1)
		bt=conv(bt,b(i,:));
	end
return

