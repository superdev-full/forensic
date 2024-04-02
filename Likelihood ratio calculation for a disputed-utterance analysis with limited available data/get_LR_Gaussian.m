function [LR, model_mean, model_cov] = get_LR_Gaussian(train_data, test_data)
% Calculates likelihood-ratio using a single-Gaussian model for each hypothesis
% train_data: cell containing two matrices, one for each hypothesis
% test_data: vector at whcih to calculate model pdfs

model_mean = cell(1,2);
model_cov = cell(1,2);
likelihood = NaN(1,2);
for I_model = 1:2
    model_mean{I_model} = mean(train_data{I_model}, 1);
    model_cov{I_model} = cov(train_data{I_model}, 1);

    likelihood(I_model) = mvnpdf(test_data, model_mean{I_model}, model_cov{I_model});
end

LR = log10(likelihood(1)) - log10(likelihood(2));