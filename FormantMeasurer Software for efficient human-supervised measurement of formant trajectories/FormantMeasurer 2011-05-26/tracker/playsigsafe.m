%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/playsigsafe.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:SIGIO:playsigsafe.m 2002/11/6 19:5

function playsigsafe(scale,otherargs);
% Caller to soundsc or sound..safe version
% To avoid problems with overlapping playbacks
% WARNING safe feature will not work unless all calls to playback
% go through this routine
% used by playsc and playnosc, playpadsc, playnopadsc..
% Checks for no errors on playback
% checks last time something was played (throug playsc)
% and delays till after it should be done
% version 2.0 Copyright T.M. Nearey 2002
% if scale is 1, then calls matlab soundsc, else calls sound
% other arguments to soundsc or sound are passed along in otherargs
persistent lastplayedtime lastplayeddur% keep track of when last thing started to play
if isempty(lastplayedtime)
	lastplayedtime=cputime;
	lastplayeddur=0;
end
error(nargchk(2,2,nargin));
varargin=deal(otherargs); %  peal them out to pass them on;
nvararg=size(varargin);
if nvararg<2 | scale & nvararg==2 & isequal( size(varargin{2}),[1,2])% special case for slim
	fs=10000;
else
	fs=varargin{2};
end
delay=.1;
played=0;
ntry=0;
while ~played
	elapsed=cputime-lastplayedtime;
	if elapsed>=lastplayeddur
		try
			if scale
				soundsc(varargin{:});
			else
				sound(varargin{:});
			end
			lastplayedtime=cputime;
			lastplayeddur=size(varargin{1},1)/fs;
			played=1;
		catch
			ntry=ntry+1;
			delay=max(delay,size(varargin{1},1)/fs);
			delay=delay*ntry;
			pause(delay);
			if ntry>5
				warning('Cannot play after 5 tries... giving up')
				return
			end
		end
	end
end
