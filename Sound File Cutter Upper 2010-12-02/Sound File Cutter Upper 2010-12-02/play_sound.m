function status= play_sound(id)
%
% Version 1.0, 27 Jun 2008
%
% Dr. Phillip M. Feldman
%
%
% SYNTAX
%
% status= play_sound(id)
%
%
% OVERVIEW
%
% play_sound loads and plays the specified sound file.
%
%
% INPUTS
%
% id identifies the sound file to be loaded, and can be either a string or
% an integer.  If id equals zero, play_sound returns immediately without
% playing any sound.  If id is an integer between 1 and 6, the value is
% mapped to a Windows system sound as follows:
%
%    1: chimes
%    2: chord
%    3: ding
%    4: notify
%    5: tada
%    6: Windows XP Battery Critical
%
% If id is a string, the string may include the full path to the file.  If
% the path is not provided, play_sound looks in the current directory, and then
% in the directory C:\Windows\media.

% We start by pessimistically assuming that an error condition will occur:
status= 0;

if (nargin ~= 1)
   fprintf('play_sound requires exactly one input.');
   return;
end

if (isa(id,'numeric'))

   if (numel(id) ~= 1)
      fprintf(['When invoking play_sound with a numeric argument, please ' ...
      'specify a single\n' 'integer between 1 and 6.\n']);
      return;
   end

   if (id == 0)
      % Return without playing any sound:
      status= 1; % success
      return;
   elseif (id == 1)
      id= 'chimes.wav';
   elseif (id == 2)
      id= 'chord.wav';
   elseif (id == 3)
      id= 'ding.wav';
   elseif (id == 4)
      id= 'notify.wav';
   elseif (id == 5)
      id= 'tada.wav';
   elseif (id == 6)
      id= 'Windows XP Battery Critical.wav';
   else
      fprintf(['When invoking play_sound with a numeric argument, please ' ...
      'specify a single\n' 'integer between 1 and 6.\n']);
      return;
   end

end

% % If id does not end with the string ".wav", append this extension:
% 
% if (~strcmp(substr(id,-4,4),'.wav'))
%    id= [id '.wav'];
% end

name= id;

if (~exist(id, 'file'))
   id= ['C:\\Windows\\media\\' id];
   if (~exist(id, 'file'))
      fprintf(['The input file "%s" was not found.  (I looked in the ' ...
      'current\n' 'directory, in the Matlab path, and in ' ...
      'C:\\Windows\\media).\n'], name);
      return;
   end
end

[Y,Fs,Nbits]= wavread(id);

sound(Y, Fs);

status= 1; % success

% Copyright (c) 2006, Phillip M. Feldman
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.
