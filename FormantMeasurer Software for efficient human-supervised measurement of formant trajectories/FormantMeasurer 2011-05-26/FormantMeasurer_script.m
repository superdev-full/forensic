% FormantMeasurer
% © Geoffrey Stewart Morrison & Terrance M. Nearey
% Release 2011-05-26
% tested in Matlab R2010a running under Windows 7
% see pdf documentation

addpath('./general', './tracker', './pitch', './synthesiser', './drawing', './intensity')
clear all
global nextb
tic

FormantMeasurer

rmpath('./general', './tracker', './pitch', './synthesiser', './drawing', './intensity')
