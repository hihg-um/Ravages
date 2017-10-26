geno.simu.controls <- function(maf.controls, nb.controls){
  x.controls <- matrix(rbinom(nb.controls*length(maf.controls), 2, maf.controls), byrow=TRUE, nrow=nb.controls) 
  x.controls <- as.bed.matrix(x.controls)
  x.controls@ped$pheno <- 0 ; x.controls@ped$famid <- x.controls@ped$id <- paste("T", seq(1, nb.controls), sep="")
  return(x.controls)
}


geno.simu.case <- function(maf.case, nb.case){
  x.case <- matrix(rbinom(nb.case*length(maf.case), 2, maf.case), byrow=TRUE, nrow=nb.case) 
  x.case <- as.bed.matrix(x.case)
  x.case@ped$pheno <- 1 ; x.case@ped$id <- x.case@ped$famid <- paste("C", seq(1,nb.case), sep="")
  return(x.case)
}