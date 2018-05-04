#include <Rcpp.h>
#include <RcppParallel.h>
#include <iostream>
#include <ctime>
#include "gaston.h"
#include "statistics_class.h"
#include "allelecounter.h"

using namespace Rcpp;
using namespace RcppParallel;

class sumfst : public Stats {
  public:

  sumfst(const XPtr<matrix4> pA, LogicalVector which_snps, IntegerVector SNPgroup, IntegerVector ind_group)
  : Stats(pA, which_snps, SNPgroup, ind_group) { }

  void compute_stats() {
    if(nb_snps == 0 || nb_snp_groups == 0) {
      return;
    }
    // comptages alléliques
    allelecounter X(&data[0], ncol, true_ncol, nb_snps, nb_ind_groups, ind_group);
    parallelReduce(0, nb_snps, X);
 
    // calcul de la stat, d'abord par SNP sum n^2/(n+m)  et sum n+m 
    std::vector<double> S1(nb_snps), S2(nb_snps);
    for(size_t i = 0; i < nb_snps; i++) { // boucle sur les SNP
      for(size_t g = 0; g < nb_ind_groups; g++) { // sur les groupes d'invidus
        double n = (double) X.R[2*(i*nb_ind_groups + g)];   // = nb d'alleles 1 dans groupe g+1
        double m = (double) X.R[2*(i*nb_ind_groups + g)+1]; // = nb d'alleles 0 dans groupe g+1
        S1[i] += n*n/(n+m);
        S2[i] += n+m; 
      }
    }
 
    // calcule la somme des stats par région génomique
    for(int i = 0; i < nb_snp_groups; i++) stats[i] = 0;
    for(int i = 0; i < nb_snps; i++) {
      if(S2[i] > 0) // pas de données !!
        stats[ snp_group[i] - 1 ] += S1[i]/S2[i];
    }
  }

};

List sum_fst(XPtr<matrix4> p_A, LogicalVector which_snps, IntegerVector region, IntegerVector group, int A_target, int B_max) {

  sumfst B(p_A, which_snps, region, group);
  if(B_max > 0) {
    return B.permute_stats(A_target,B_max);
  } else {
    B.compute_stats();
    List L;
    L["statistic"] = B.stats;
    return L;
  }
}

//[[Rcpp::export]]
List ex_sum_fst(XPtr<matrix4> p_A, LogicalVector which_snps, IntegerVector region, IntegerVector group, IntegerVector g) {

  sumfst B(p_A, which_snps, region, group);

  return B.exact_p_value(g);
}



RcppExport SEXP oz_sum_fst(SEXP p_ASEXP, SEXP which_snpsSEXP, SEXP regionSEXP, SEXP groupSEXP, SEXP A_targetSEXP, SEXP B_maxSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< XPtr<matrix4> >::type p_A(p_ASEXP);
    Rcpp::traits::input_parameter< LogicalVector >::type which_snps(which_snpsSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type region(regionSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type group(groupSEXP);
    Rcpp::traits::input_parameter< int >::type A_target(A_targetSEXP);
    Rcpp::traits::input_parameter< int >::type B_max(B_maxSEXP);
    rcpp_result_gen = Rcpp::wrap(sum_fst(p_A, which_snps, region, group, A_target, B_max));
    return rcpp_result_gen;
END_RCPP
}

RcppExport SEXP oz_ex_sum_fst(SEXP p_ASEXP, SEXP which_snpsSEXP, SEXP regionSEXP, SEXP groupSEXP, SEXP gSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< XPtr<matrix4> >::type p_A(p_ASEXP);
    Rcpp::traits::input_parameter< LogicalVector >::type which_snps(which_snpsSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type region(regionSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type group(groupSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type g(gSEXP);
    rcpp_result_gen = Rcpp::wrap(ex_sum_fst(p_A, which_snps, region, group, g));
    return rcpp_result_gen;
END_RCPP
}
