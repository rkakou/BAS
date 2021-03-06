make.parents.of.interactions =
  function (mf, df)
  {
#    browser()
    termnamesX = attr(terms(mf, data=df), "term.labels")
    p = length(termnamesX)
    interactions = grep(":", termnamesX)
    parents = diag(p)
    colnames(parents) = termnamesX
    rownames(parents) = termnamesX
    for (j in interactions) {
      term = interactions[j]
      main = unlist(strsplit(termnamesX[j], ":",
                                      fixed = TRUE))
        parents.of.term = main
       for (i in 2:length(main)) {
        parents.of.term = c(parents.of.term,
                           utils::combn(main, i, FUN=paste0, collapse=":"))
              }
      parents[j, parents.of.term] = 1
    }

    X = model.matrix(mf, df)
    loc = attr(X, "assign")[-1] #drop intercept

    parents = parents[loc,loc]
    rownames(parents) = colnames(X)[-1]
    colnames(parents) = colnames(X)[-1]
    return(list(X = X, parents=parents))
  }


# model.matrix(mf, data)
# attr( , "assign") has where terms are located

# mp = .make.parents.of.interactions(mf, df)



prob.heredity = function(model, parents, prob=.5) {
  p = length(model)
  got.parents =  apply(parents, 1,
           FUN=function(x){
           all(as.logical(model[as.logical(x)]))}
  )
  model.prob=0
#  browser()
  if ( all(model == got.parents)) {
    model.prob = exp(
      sum(model* log(prob) + (1 - model)*log(1.0 - prob)))
  }
  return(model.prob)
}


#' Post processing function to force constraints on interaction inclusion bas BMA objects
#'
#' This function takes the output of a bas object and allows higher order interactions to be included only if their parent lower order interactions terms are in the model, by assigning zero prior probability, and hence posterior probability, to models that do include their respective parents.
#'
#' @param object a bas linear model or generalized linear model object
#' @param prior.prob  prior probability that a term is included conditional on parents being included
#' @return a bas object with updated models, coefficients and summaries obtained removing all models with   zero prior and posterior probabilities.
#' @note Currently prior probabilities are computed using conditional Bernoulli distributions, i.e.  P(gamma_j = 1 | Parents(gamma_j) = 1) = prior.prob.  This is not very efficient for models with a large number of levels.  Future updates will force this at the time of sampling.
#' @author Merlise A Clyde
#' @keywords regression
#' @examples

#' data(Hald)
#' bas.hald = bas.lm(Y ~ .^2, data=Hald)

#' bas.hald.int = force.heredity.bas(bas.hald)
#' image(bas.hald.int)
#' @family bas methods
#' @export

force.heredity.bas = function(object, prior.prob=.5) {
    parents = make.parents.of.interactions(mf=eval(object$call$formula, parent.frame()),
                                           df=eval(object$call$data, parent.frame()))$parents
    which = which.matrix(object$which, object$n.vars)
    priorprobs = apply(which[,-1], 1,
                  FUN=function(x) {prob.heredity(model=x, parents=parents)}
                  )
    keep = (priorprobs != 0)
    object$n.models= sum(keep)
    object$sampleprobs = object$sampleprobs[keep]   # if method=MCMC ??? reweight
    object$which = object$which[keep]
    wts = priorprobs[keep]/object$priorprobs[keep]
    method = object$call$method
    if (!is.null(method)) {
      if (method == "MCMC" || method == "MCMC_new" ) {
         object$freq = object$freq[keep]
         object$postprobs.MCMC = object$freq[keep]*wts
         object$postprobs.MCMC =  object$postprobs.MCMC/sum(object$postprobs.MCMC)
        object$probne0.MCMC = as.vector(object$postprobs.MCMC %*% which[keep,])
      }}
    object$priorprobs=priorprobs[keep]/sum(priorprobs[keep])
    object$logmarg = object$logmarg[keep]
    object$shrinkage=object$shrinkage[keep]
    postprobs.RN = exp(object$logmarg - min(object$logmarg))*object$priorprobs
    object$postprobs.RN = postprobs.RN/sum(postprobs.RN)
  #  browser()
    object$probne0.RN = as.vector(object$postprobs.RN %*% which[keep,])

    object$postprobs = object$postprobs[keep]*wts/sum(object$postprobs[keep]*wts)
    object$probne0 = as.vector(object$postprobs %*% which[keep,])

    object$mle = object$mle[keep]
    object$mle.se = object$mle.se[keep]
    object$mse = object$mse[keep]
    object$size = object$size[keep]
    object$R2 = object$R2[keep]
    object$df = object$df[keep]

  return(object)
}




#data(Hald)
#bas.hald = bas.lm(Y ~ .^2, data=Hald)
#hald.models = which.matrix(bas.hald$which, n.vars=bas.hald$n.vars)

#par.Hald = make.parents.of.interactions(Y ~ .^2, data=Hald)
#prior = apply(hald.models[,-1], 1,
#              FUN=function(x) {prob.hereditary(model=x, parents=par.Hald$parents)})

#.prob.heredity(hald.models[1,-1], par.Hald$parents)
# force_heredity.bas(bas.hald)
