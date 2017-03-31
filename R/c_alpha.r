C.ALPHA <- function(x, centre, region, which.snps = rep(TRUE, ncol(x)), p.asympt=FALSE) {
  L <- alleles.by.group(x, centre, which.snps)
  N <- colSums(L$minor)
  M <- colSums(L$major)
  p <- sweep( L$minor + L$major, 2, (N + M ), "/" )
  Sc <- (sweep(p, 2, N, "*") - L$minor)**2 - sweep(p*(1-p), 2, N, "*")
  Ca <- colSums(Sc)
  sp2 <- oz:::colSumsSq(p)
  Vc <- 2 * N * ( (N-3) * sp2^2 + (N-1) * sp2 - 2 * (N-2) * oz:::colSumsCub(p) )
  Ca_Sum <- .Call("oz_sum_by_group", PACKAGE = "oz", Ca, region[which.snps])
  Vc_Sum <- .Call("oz_sum_by_group", PACKAGE = "oz", Vc, region[which.snps])
  if(p.asympt==TRUE){
    S <- data.frame(gpe=levels(region), stat=Ca_Sum/sqrt(Vc_Sum), p=pnorm( Ca_Sum/sqrt(Vc_Sum) , lower.tail=FALSE))}
  else{  
    S <- Ca_Sum/sqrt(Vc_Sum)}
  return (S)
}