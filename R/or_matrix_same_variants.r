# Différents OR mais mêmes variants
OR.matrix.same.variant <- function(n.variants, OR.del, OR.pro = 1/OR.del, prob.del, prob.pro) {
  if(length(OR.del) != length(OR.pro))
    stop("Dimensions mismatch")
  OR <- cbind(1, OR.del, OR.pro, deparse.level = 0)
  # neutral, deleterious or protective
  v <- sample(1:3, n.variants, TRUE, c(1-prob.del-prob.pro, prob.del, prob.pro))
  t(apply(OR, 1, function(or) or[v]))
}
#example
#0R.matrix(20 , c(2,4), c(0.5,0.25), 0.2, 0.1)
