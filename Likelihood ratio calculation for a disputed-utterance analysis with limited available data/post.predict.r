## likelihood-ratio analysis of Swedish disputed-utterance data
## Third statistical analyses in:
##   Morrison, Lindh, Curran (2013)
##   Likelihood ratio calculation for a disputed-utterance analysis with limited available data
## known to run sucessfully on R ver 2.15.2
## Genz et al mvtnorm package is required http://CRAN.R-project.org/package=mvtnorm


## read the data 

x1 = matrix(scan('x0.txt'), ncol = 3, byrow = T)
x2 = matrix(scan('x1.txt'), ncol = 3, byrow = T)
y = c(-1.19081712748878, 494,	1252)

n1 = nrow(x1)
n2 = nrow(x2)

mx1 = apply(x1, 2, mean)
mx2 = apply(x2, 2, mean)
S1 = cov(x1)*(n1-1)/n1
S2 = cov(x2)*(n2-1)/n2
k = 3
I = diag(rep(1,k))
m = 100
Beta = m*I
mu0 = rep(0, k)
alpha = k

## Multivariate t

post.mu1 = n1*mx1/(n1+m) ## technically + m*mu0 on the top line but it's zero so no diff
post.mu2 = n2*mx2/(n2+m)

alpha.n1 = alpha + 0.5*n1 - 0.5*(k - 1)
alpha.n2 = alpha + 0.5*n2 - 0.5*(k - 1)

Beta.n1 = Beta + 0.5*n1*S1 + 0.5*(n1*m)/(n1+m)*mx1%*%t(mx1)
Beta.n2 = Beta + 0.5*n2*S2 + 0.5*(n2*m)/(n2+m)*mx2%*%t(mx2)

Lambda1 = (m + n1)/(m + n1 + 1)*alpha.n1*solve(Beta.n1)
Lambda2 = (m + n2)/(m + n2 + 1)*alpha.n2*solve(Beta.n2)

d1 = dmvt(y, post.mu1, solve(Lambda1), 2*alpha.n1, log = FALSE)
d2 = dmvt(y, post.mu2, solve(Lambda2), 2*alpha.n2, log = FALSE)

cat(paste("Uninformed priors", round(log10(d1/d2),2), "\n"))

## using priors

priors = list( mu1 = c(-1.26677231260404,  604,	1043), mu2 = c(1.31222678115528,	464, 	2093),
               sigma1 = diag(c(1.57278563740326,	65,	124)^2), sigma2 = diag(c(0.224556087968045,  76,	569)^2))


post.mu1 = (n1*mx1 + m*priors$mu1)/(n1+m) 
post.mu2 = (n2*mx2 + m*priors$mu2)/(n2+m)

alpha.n1 = alpha + 0.5*n1 - 0.5*(k - 1)
alpha.n2 = alpha + 0.5*n2 - 0.5*(k - 1)

Beta.n1 = priors$sigma1 + 0.5*n1*S1 + 0.5*(n1*m)/(n1+m)*(mx1 - priors$mu1)%*%t(mx1 - priors$mu1)
Beta.n2 = priors$sigma2 + 0.5*n2*S2 + 0.5*(n2*m)/(n2+m)*(mx2 - priors$mu2)%*%t(mx2 - priors$mu2)

Lambda1 = (m + n1)/(m + n1 + 1)*alpha.n1*solve(Beta.n1)
Lambda2 = (m + n2)/(m + n2 + 1)*alpha.n2*solve(Beta.n2)

d1 = dmvt(y, post.mu1, solve(Lambda1), 2*alpha.n1, log = FALSE)
d2 = dmvt(y, post.mu2, solve(Lambda2), 2*alpha.n2, log = FALSE)

cat(paste("Informed priors", round(log10(d1/d2),2), "\n"))
        

