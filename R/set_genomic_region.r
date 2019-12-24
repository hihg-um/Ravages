set.genomic.region <- function(x, genes = genes.b37, flank.width = 0L) {
  # ce test est OK pour les facteurs aussi
  if(typeof(x@snps$chr) != "integer") 
    stop("x@snps$chr should be either a vector of integers, or a factor with same levels as genes$Chr")
  
  # remove duplicated genes if any
  w <- duplicated(genes$Gene_Name)
  if(any(w)) {
    genes <- genes[!w,]
  }

  # check if genes is sorted by chr / starting pos
  n <- nrow(genes)
  chr1 <- genes$Chr[1:(n-1)]
  chr2 <- genes$Chr[2:n]
  b <- (chr1 < chr2) | (chr1 == chr2 & genes$Start[1:(n-1)] <= genes$Start[2:n])
  if(!all(b)) {
    genes <- genes[ order(genes$Chr, genes$Start), ]
  }
  
  # if asked define larger regions
  if(is.finite(flank.width)) flank.width <- as.integer(flank.width)
  if(flank.width > 0L) {
    M <- as.integer(max(x@snps$pos, genes$End))  # joue le rôle de la position infinie !
    b <- genes$Chr[2:n] == genes$Chr[1:(n-1)]
    #Teste si les gènes se chevauchent
    b2 <- (genes$Start[2:n] > genes$End[1:(n-1)]) # non chevauchants
    start <- ifelse(b, ifelse(b2, as.integer(0.5*(genes$Start[-1] + genes$End[-n])), genes$Start[-1]),  0L)
    end <- ifelse(b, ifelse(b2, start-1L, genes$End[-n]), M)
    if(flank.width < Inf) {
      genes$Start <- pmax( c(0L, start), genes$Start - flank.width)
      genes$End <- pmin( c(end,M), genes$End + flank.width)
    } else {
      genes$Start <- c(0L,start)
      genes$End <- c(end,M)
    }
  }

  
  R <- .Call("label_multiple_genes", PACKAGE = "Ravages", genes$Chr, genes$Start, genes$End, x@snps$chr, x@snps$pos)
  R.genename <- unlist(lapply(R, function(z) paste(levels(genes$Gene_Name)[unlist(z)], collapse=",")))  
  R.genename[which(R.genename=="")] <- NA

  x@snps$genomic.region <- R.genename

  x
}


