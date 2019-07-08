Pi.matrix <- function(group, formula, data, ref.level){
    group <- if (!is.factor(group)) factor(group, levels=unique(group))
    if (is.numeric(ref.level)) ref.level <- as.character(ref.level)
    if (!(ref.level %in% levels(group))) stop("'ref.level' is not a level of 'group'")
    
    if (missing(data)) {
      stop("Needs data to calculate probailities")
    }else{
      if (nrow(data) != length(group)) { stop("'data' has wrong dimensions") }
    }
    
    alt.levels <- levels(group)[levels(group) != ref.level]
   
    data.reg <- as.data.frame(data)
    if(missing(formula)){
      formula <- as.formula(paste("~", paste(colnames(data), collapse = "+")))}
    
    data.reg <- cbind(ind.pheno = group, data.reg)
    rownames(data.reg) <- NULL
    data.reg <- mlogit.data(data.reg, varying = NULL, shape = "wide",  choice = "ind.pheno", alt.levels = levels(group))
      
    z <- as.character(formula)
    if (z[1] != "~" | length(z) != 2)  stop("'formula' should be a formula of the form \"~ var1 + var2\"")
    z <- z[2]
    my.formula <- mFormula(as.formula(paste("ind.pheno ~ 0 | ", z)))
    fit <- tryCatch(mlogit(my.formula, data = data.reg, reflevel = ref.level), error = identity, warning = identity)
    
    if (is(fit, "error")) {
      pi.matrix <- matrix(NA, ncol=nlevels(group), nrow=nrow(data), byrow=TRUE, dimnames=list(rownames(data), levels(group)))
    }else{
      pi.matrix <- matrix(fit$model$probabilities, ncol=nlevels(group), nrow=nrow(data), byrow=TRUE, dimnames=list(rownames(data), levels(group)))
    }
    
    return(pi.matrix)
}

