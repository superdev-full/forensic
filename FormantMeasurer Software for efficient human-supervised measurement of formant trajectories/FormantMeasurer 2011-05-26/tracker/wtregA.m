%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/wtregA.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:tmnstats:wtregA.m 2002/11/6 19:5

function [p,yhat,res,pcov,df] = wtregA(x,y,w)
% modified  for correct covariance estimate (df)
% This weighting is correct
%  [p,yhat,res,pcov,df] =  wtregA(x,y,w)
% weighted fit
if nargin<3,
w=1;
end
w=w(:);
if length(w)<=1
	w=w*ones(size(y));
end
[n,q]=size(x); %size(y); size(w);
% Solve least squares problem.
q_ones=ones(1,size(x,2));
% Square roots of weights are used in the transformation of x and y
p = (sqrt(w(:,q_ones)).*x) \( sqrt(w).*y);
if nargout>1
	yhat=x*p;
end

if nargout>2
	res = (y- yhat).*sqrt(w); % Weighted Residuals
end
df=n-q;
if nargout>3
%    Draper and smith 66 p 79
	 R = (x')*(x.*w(:,q_ones));
	 pcov = sum(res.^2)/df*pinv(R);    % Errors of the fit
% pause
% sig2 is sum(res.^2)
end



