% generate_non_overlapping_comparisons.m
%
% © 2010 Geoffrey Stewart Morrison
% http://geoff-morrison.net
% 2010-02-16
%
% See:
%   Morrison GS, Thiruvaran T, Epps J (2010) Estimating the likelihood-ratio output of a foresnsic-voice-comparison system.
%       Proceedings of Odyssey 2010 The Speaker and Language Recognition Workshop, Brno. [submitted]
%
% Use this script to create non-overlapping sets of of likelihood ratios.
% Four recordings per speaker are assumed, allowing the creation of two non-overlapping same-speaker
% likelihood ratios, AB and CD, and four non-overlapping different-speaker likelihood ratios,
% e.g., Spk01_A-Spk02_B, Spk01_C-Spk02_D, Spk02_A-Spk01_B, Spk02_C-Spk01_D.
% Adapt as necessary.

num_speakers=100;

output_dir = '.\system output\';
output_file_name = 'system_output.mat';

LR_ss = NaN(num_speakers, 2); % will create 2 non-overlapping same-speaker likelihood ratios
indices_ss = NaN(num_speakers, 1);

num_comparisons_ds = (num_speakers^2-num_speakers)/2;
LR_ds = NaN(num_comparisons_ds, 4); % will create 4 non-overlapping different-speaker likelihood ratios
indices_ds = NaN(num_comparisons_ds, 2);

for I_speaker_alpha = 1:num_speakers
    for I_speaker_beta = 1:num_speakers
        
        % replace the following two lines with appropriate functions, suspect models, and offender data
        temp_LR_AB = get_LR(model_A{I_speaker_alpha}, data_B{I_speaker_beta});
        temp_LR_CD = get_LR(model_C{I_speaker_alpha}, data_D{I_speaker_beta});
        
        if I_speaker_beta == I_speaker_alpha % same-speaker comparisons
            indices_ss(I_speaker_alpha) = I_speaker_alpha;

            LR_ss(I_speaker_alpha, 1) = temp_LR_AB;
            LR_ss(I_speaker_alpha, 2) = temp_LR_CD;
            
        else % different-speaker comparisons
            ab = sort([I_speaker_alpha, I_speaker_beta]);
            %I_ds = num_speakers*(ab(1)-1) - sum(1:ab(1)-1) + ab(2)-ab(1);  % this gets us the correct index value
            I_ds = num_speakers*(ab(1)-1) - sum(1:ab(1)) + ab(2);
            indices_ds(I_ds, :) = ab;
            
            if I_speaker_beta > I_speaker_alpha
                LR_ds(I_ds, 1) = temp_LR_AB;
                LR_ds(I_ds, 2) = temp_LR_CD;
            else %if I_speaker_beta < I_speaker_alpha
                LR_ds(I_ds, 3) = temp_LR_AB;
                LR_ds(I_ds, 4) = temp_LR_CD;
            end
            
        end
    end
end

save([output_dir, output_file_name], 'LR_ss', 'indices_ss', 'LR_ds', 'indices_ds');
