function AcousticRecording_function

% When compiling, manually include the following function (is only called from a callback):
% testuserid.m

% the following line will not compile - coment it out and use File>Set Path to add the current folder and subfolder to the path
addpath('.\m_files\');

AcousticRecording

% the following line will not compile
rmpath('.\m_files\');

return