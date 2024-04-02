function f = svmclassify_soft(Xnew,svm_struct)


sv = svm_struct.SupportVectors;
alphaHat = svm_struct.Alpha;
bias = svm_struct.Bias;
kfun = svm_struct.KernelFunction;
kfunargs = svm_struct.KernelFunctionArgs;

% shift and scale the data if necessary: (from svmclassify.m)
if ~isempty(svm_struct.ScaleData)
    for c = 1:size(Xnew, 2)
        Xnew(:,c) = svm_struct.ScaleData.scaleFactor(c) * ...
            (Xnew(:,c) +  svm_struct.ScaleData.shift(c));
    end
end


f = (feval(kfun,sv,Xnew,kfunargs{:})'*alphaHat(:)) + bias;



% function [out,f] = svmdecision(Xnew,svm_struct)
% %SVMDECISION evaluates the SVM decision function
% 
% %   Copyright 2004-2006 The MathWorks, Inc.
% %   $Revision: 1.1.12.4 $  $Date: 2006/06/16 20:07:18 $
% 
% sv = svm_struct.SupportVectors;
% alphaHat = svm_struct.Alpha;
% bias = svm_struct.Bias;
% kfun = svm_struct.KernelFunction;
% kfunargs = svm_struct.KernelFunctionArgs;
% 
% f = (feval(kfun,sv,Xnew,kfunargs{:})'*alphaHat(:)) + bias;
% out = sign(f);
% % points on the boundary are assigned to class 1
% out(out==0) = 1;