The enclosed scripts and functions are for calculating estimates of the credible interval for the likelihood-ratio output from a forensic-comparison system. See:

	Morrison GS, Thiruvaran T, Epps J (2010) Estimating the likelihood-ratio output of a foresnsic-voice-comparison system. Proceedings of Odyssey 2010 The Speaker and Language Recognition Workshop, Brno.



- Use 'generate_non_overlapping_comparisons.m' to generate properly formatted data, or use the supplied examples, '20s cal.mat' or '40s cal.mat'.


- Use 'precision_non_parametric.m' to non-parametrically estimate the credible interval over the range of values in the data, and to produce scatter plots and Tippett plots, and to calculate Cllr. The 'cllr.m' function (and associated functions) in Niko Brümmer's FoCal Toolkit <http://sites.google.com/site/nikobrummer/focal> must be in the path.


- Use 'precision_non_parametric_at_specified_value.m' to non-parametrically estimate the credible interval at a specified value.


- Use 'precision_parametric.m' to parametrically estimate the credible interval.


23 May2010
Geoffrey Stewart Morrison
http://geoff-morrison.net