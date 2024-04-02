function w = train_llr_fusion_regularized(targets, non_targets, prior, kappa, df)
%
% Revised version by Geoffrey Stewart Morrison 2017-06-05
% http://geoff-morrison.net/
%
% Regularizes, either to prevent numerical problems in cases of complete separation in the training data, 
% or to deliberatly shrink the slope and hence the log(LR) output when the weights are used with lin_fusion.
% An explantion is provided in Morrison (2017) Shrunk likelihood ratios / Bayes factors for quantifying strength of forensic evidence
% A maximally uninformative uniform distribution is added like an uninformative Bayesian prior.
% The strength of the "prior" distributions is controlled by 'kappa' which is scaled in pseudodata points,
% e.g., setting 'kappa' to 5 would mean that the strength of the prior is equivalent to 5 data points.
% Heuristic: use kappa <= 0.1 to avoid numerical problems, kappa >= 1 to induce shrinkage
% Default value for 'kappa' is 0, i.e., same as original 'train_llr_fusion' function.
%
% 'df' is pseudo degrees of freedom, for example, if 100 scores were created by comparing recordings from 10 speakers 'df' could be set to 10.
% If no 'df' is specified, the default in the above example would be 100.
% 
% This code was adapted from Niko Brümmer's 'train_llr_fusion' function in his FoCal toolkit
% at https://sites.google.com/site/nikobrummer/focal 

%  Train Linear fusion with prior-weighted Logistic Regression objective.
%  The fusion output is encouraged by this objective to be a well-calibrated log-likelihood-ratio.
%  I.E., this is simultaneous fusion and calibration.
%
%  Usage:
%    w = TRAIN_LLR_FUSION(targets,non_targets,prior)
%    w = TRAIN_LLR_FUSION(targets,non_targets)
%   
%  Input parameters:
%    targets:     a [d,nt] matrix of nt target scores for each of d systems to be fused. 
%    non_targets: a [d,nn] matrix of nn non-target scores for each of the d systems.
%    prior:       (optional, default = 0.5), a scalar parameter between 0 and 1. 
%                 This weights the objective function, by replacing the effect 
%                 that the proportion nt/(nn+nt) has on the objective.
%                 For general use, omit this parameter (i.e. prior = 0.5).
%                 For NIST SRE, use: prior = effective_prior(0.01,10,1);
%
%  Output parameters:
%    w: a vector of d+1 fusion coefficients. 
%         The first d coefficients are the weights for the d input systems.
%         The last coefficient is an offset (see below).
%
%  Fusion of new scores:
%    see: LIN_FUSION.m
%                                 
%

%  This code is an adapted version of the m-file 'train_cg.m' as made available by Tom Minka
%  at http://www.stat.cmu.edu/~minka/papers/logreg/.

max_iter = 1000; %originally coded as 1000

if nargin < 3 || isempty(prior)
   prior = 0.5;
end

if nargin < 4 || isempty(kappa)
    kappa = 0;
end

nt = size(targets,2);
nn = size(non_targets,2);
ntnn = nt+nn;
prop = nt/ntnn;

if nargin < 5 || isempty(df)
    df = ntnn;
end


if kappa == 0 % original
    weights = [(prior/prop)*ones(1,nt),((1-prior)/(1-prop))*ones(1,nn)];
    x = [[targets;ones(1,nt)],-[non_targets;ones(1,nn)]];
    offset = logit(prior)*[ones(1,nt),-ones(1,nn)];
else % regularize
    weights_temp = [(prior/prop)*ones(1,nt),((1-prior)/(1-prop))*ones(1,nn)];
    weight_flat_prior = kappa / (2*df);
    weights_temp_flat_priors = weight_flat_prior*ones(1,ntnn*2);
    weights = [weights_temp, weights_temp_flat_priors];
    
    x_temp = [[targets;ones(1,nt)],-[non_targets;ones(1,nn)]];
    x = [x_temp, x_temp, -x_temp];
    
    offset_temp = logit(prior)*[ones(1,nt),-ones(1,nn)];
    offset = [offset_temp, offset_temp, -offset_temp]; %?
    
    
%     weight_flat_prior = kappa / (2*df);
% 
%     x_temp = [[targets; ones(1,nt)], -[non_targets; ones(1,nn)]];
%     x = [x_temp, x_temp, -x_temp];
%     
%     prop_targets = nt / ntnn;
%     prop_non_targets = 1 - prop_targets;
% 
%     prior_adjusted_targets = prior/prop_targets;
%     prior_adjusted_non_targets = (1-prior)/prop_non_targets;
% 
%     weights_temp = [prior_adjusted_targets*ones(1,nt), prior_adjusted_non_targets*ones(1,nn)];
%     weights_temp_flat_priors = weights_temp*weight_flat_prior;
%     weights = [weights_temp, weights_temp_flat_priors, weights_temp_flat_priors];
% 
%     offset_temp = logit(prior)*[ones(1,nt),-ones(1,nn)];
%     offset = [offset_temp, offset_temp, -offset_temp];
end

w = zeros(size(x,1),1);

% [d,n] = size(x);
old_g = zeros(size(w));
for iter = 1:max_iter
  old_w = w;
  % s1 = 1-sigma
  s1 = 1./(1+exp(w'*x+offset));
  g = x*(s1.*weights)';
  if iter == 1
    u = g;
  else
    u = cg_dir(u, g, old_g);
  end
  
  % line search along u
  ug = u'*g;
  ux = u'*x;
  a = weights.*s1.*(1-s1);
  uhu = (ux.^2)*a';
  w = w + (ug/uhu)*u;
  old_g = g;
  if max(abs(w - old_w)) < 1e-5 % originally coded as 1e-5
     break
  end
end
if iter == max_iter
  warning('not enough iters')
end
