See also '_ReadMe.txt'

The enclosed scripts and functions are for calculating estimates of the credible interval for the likelihood-ratio output from a forensic-comparison system using the revised procedure. See:

	Morrison, G. S. (in press 2011). Measuring the validity and reliability of forensic likelihood-ratio systems. Science & Justice, XX, xxx–xxx. doi:10.1016/j.scijus.2011.03.002



- See the paper above for differences between the earlier and revised procedures.The procedure for generating properly formatted data differs. Example data are provided '20s cal.mat' and '40s cal.mat' in folder 'system output - revised S&J procedure'


- Use 'precision_non_parametric_revised.m' to non-parametrically estimate the credible interval over the range of values in the data, and to produce scatter plots and Tippett plots, and to calculate Cllr. The 'cllr.m' function (and associated functions) in Niko Brümmer's FoCal Toolkit <http://sites.google.com/site/nikobrummer/focal> must be in the path.



- Use 'precision_parametric_revised.m' to parametrically estimate the credible interval.


30 March 2011
Geoffrey Stewart Morrison
http://geoff-morrison.net