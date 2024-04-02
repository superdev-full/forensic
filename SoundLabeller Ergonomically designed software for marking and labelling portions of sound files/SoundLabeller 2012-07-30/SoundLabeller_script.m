% SoundLabeller
% Release 2011-04-03
% © Geoffrey Stewart Morrison
% http://geoff-morrison.net
%
% see documentation in pdf


% initialise
clear all
global nextb
addpath('.\m_files');
tic

SoundLabeller

% clean up
%close(hfullscreen);
rmpath('.\m_files');