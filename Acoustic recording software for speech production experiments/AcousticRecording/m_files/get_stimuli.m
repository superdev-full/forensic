function stimuli=get_stimuli(stim_file);
% Reads in tab delimited text file
% Columns:  1          2           3               4        5               6
%           Filename   TargetWord  SoundsLikeWord  NoRhyme  SILDoulosIPA93  SAMPA   

if nargin==0, stim_file='.\Prompts\stimuli_core_e.txt'; end

fid=fopen(stim_file);
temp_stimuli=textscan(fid,'%s %s %s %s %s %s');%, 'delimiter','\t'); 
fclose(fid);

num_cols=length(temp_stimuli);
num_rows=length(temp_stimuli{1});
stimuli=cell(num_rows,num_cols);
for Icol=1:num_cols
    stimuli(:,Icol)=temp_stimuli{Icol};
end

% stimuli=textread(stim_file,'%s',-1);
% 
% stimuli=reshape(stimuli,6,size(stimuli,1)/6)';

return