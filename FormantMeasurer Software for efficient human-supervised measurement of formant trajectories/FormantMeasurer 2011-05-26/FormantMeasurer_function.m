function FormantMeasurer_function
% FormantMeasurer
% © Geoffrey Stewart Morrison & Terrance M. Nearey
% Release 2011-05-26
% tested in Matlab R2010a running under Windows 7
% see pdf documentation

% the following line will not compile - coment it out and use File>Set Path to add the current folder and subfolders to the path
% addpath('./general', './tracker', './pitch', './synthesiser', './drawing', './intensity')

clear all
global nextb
tic

FormantMeasurer

% include the following line in the compiled version
if error_in_files, close all, input('\nPress ENTER to close this window\n'); end

% the following line will not compile
% rmpath('./general', './tracker', './pitch', './synthesiser', './drawing', './intensity')

return