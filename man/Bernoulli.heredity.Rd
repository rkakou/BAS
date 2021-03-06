% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modelpriors.R
\name{Bernoulli.heredity}
\alias{Bernoulli.heredity}
\title{Independent Bernoulli prior on models that with constraints for 
model hierarchy induced by interactions}
\usage{
Bernoulli.heredity(pi = 0.5, parents)
}
\arguments{
\item{pi}{Bernoulli probabibility that term is included}

\item{parents}{matrix of terms and parents with indicators of which terms
are parents for each term}
}
\description{
Independent Bernoulli prior on models that with constraints for 
model hierarchy induced by interactions
}
\seealso{
Other priors modelpriors: \code{\link{Bernoulli}},
  \code{\link{beta.binomial}},
  \code{\link{tr.beta.binomial}}, \code{\link{tr.poisson}},
  \code{\link{tr.power.prior}}, \code{\link{uniform}}
}
