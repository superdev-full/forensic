% instructions

for I=1:4
    mes=[instructions_Dir,'instructions',num2str(I,'%02.0f'),filelang];
    message([mes,'.txt'], 0, .9, 14, [mes,'.wav'], 'sync', lang_strings, [], num_logical_monitors);
end

set_up_screen
stimuli=get_stimuli(['Prompts\stimuli_practice',filelang,'.txt']);
core_str='practice\';
NumProdRounds=1;
tic;
recording_cycle
quit_now = false;
for I_monitors = 1:num_logical_monitors
    clf(I_monitors);
end

mes=[instructions_Dir,'instructions05',filelang];
message([mes,'.txt'],0,.9,14,[mes,'.wav'],'sync',lang_strings, [], num_logical_monitors);