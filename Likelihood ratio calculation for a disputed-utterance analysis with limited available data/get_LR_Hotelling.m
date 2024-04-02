function LR = get_LR_Hotelling(train_data, test_data)
% Calculates likelihood-ratio using a Hotelling's T^2 model for each hypothesis
% train_data: cell containing two matrices, one for each hypothesis
% test_data: vector at which to calculate model pdfs

likelihood = NaN(1,2);
for I_model = 1:2
    likelihood(I_model) = HT2pdf(test_data, train_data{I_model});
end

LR = log10(likelihood(1)) - log10(likelihood(2));
