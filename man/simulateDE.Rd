% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Simulate.R
\name{simulateDE}
\alias{simulateDE}
\title{Simulate Differential Expression}
\usage{
simulateDE(n1=c(20,50,100), n2=c(30,60,120),
sim.settings,
DEmethod,
Normalisation,
Label = "none",
Prefilter = NULL,
Impute = NULL,
DEFilter = FALSE,
spikeIns = FALSE,
NCores = NULL,
verbose = TRUE)
}
\arguments{
\item{n1, n2}{Integer vectors specifying the number of biological replicates in each group.
Default values are n1=c(20,50,100) and n2=c(30,60,120).}

\item{sim.settings}{This object specifies the simulation setup. This must be the return object from \code{\link{SimSetup}}.}

\item{DEmethod}{A character vector specifying the DE detection method to be used.
Please consult the Details section for available options.}

\item{Normalisation}{Normalisation method to use.
Please consult the Details section for available options.}

\item{Label}{A character vector to define whether information about group labels should be used for normalisation.
This is only implemented for scran and SCnorm. Possible options include the default \code{"none"} which means that no sample group information is considered for normalisation; \code{"known"} means that the simulated group labels are used and \code{"clustering"} which applies an unsupervised hierarchical clustering to determine the group labels (for details, see \code{\link[scran]{quickCluster}}).}

\item{Prefilter}{A character vector specifying the gene expression filtering method
to be used prior to normalisation (and possibly imputation).
Default is \code{NULL}, i.e. no filtering.
Please consult the Details section for available options.}

\item{Impute}{A character vector specifying the gene expression imputation method
to be used prior to normalisation.
Default is \code{NULL}, i.e. no imputation.
Please consult the Details section for available options.}

\item{DEFilter}{A logical vector indicating whether to run DE testing on filtered and/or imputed count data.
Default is \code{FALSE}.}

\item{spikeIns}{Logical vector to indicate whether to simulate spike-ins.
Default is \code{FALSE}.}

\item{NCores}{integer positive number of cores for parallel processing.
Default is \code{NULL}, i.e. 1 core.}

\item{verbose}{Logical vector to indicate whether to show progress report of simulations.
Default is \code{TRUE}.}
}
\value{
A list with the following fields:
\item{pvalue, fdr}{3D array (ngenes * N * nsims) for p-values and FDR from each simulation.
Note that FDR values will be empty and the calculation will be done by \code{\link{evaluateDE}} whenever applicable.}
\item{mu,disp,dropout}{3D (ngenes * N * nsims) array for mean, dispersion and dropout of library size factor normalized read counts.}
\item{true.mu,true.disp,true.dropout}{3D (ngenes * N * nsims) array for true mean, dispersion and dropout of simulated read counts.}
\item{true.depth}{True simulated sequencing depth per sample.}
\item{est.sf}{Global library size factor estimates per sample.}
\item{est.gsf}{3D array (ngenes * N * nsims) for size factor estimates. These are gene- and sample-wise estimates and only for SCnorm and Linnorm normalisation.}
\item{elfc,rlfc}{3D array (ngenes * N * nsims) for log2 fold changes (LFC):
elfc is for the DE tool estimated LFC; rlfc is for the LFC estimated from the normalised read counts.}
\item{sim.settings}{The input sim.settings to which the specifications of \code{simulateDE} is added.}
\item{time.taken}{The time taken for each simulation, given for preprocessing, normalisation, differential expression testing and moment estimation.}
}
\description{
simulateDE is the main function to simulate differential expression for RNA-seq experiments.
The simulation parameters are specified with \code{\link{SimSetup}}.
The user needs to specify furthermore
the number of samples per group, preprocessing, normalisation and differential testing method.
There is also the option to consider spike-ins. \cr
The return object contains DE test results from all simulations as well as descriptive statistics.
The error matrix calculations will be conducted with \code{\link{evaluateDE}}.\cr
}
\details{
Here you can find detailed information about preprocessing, imputation, normalisation and differential testing choices.
}
\section{Prefiltering prior to imputation/normalisation}{

\describe{
\item{CountFilter}{removes genes that have a mean expression below 0.2.}
\item{FreqFilter}{removes genes that have more than 80 percent dropouts.}
}
}

\section{Imputation prior to normalisation}{

\describe{
\item{scImpute}{employs scImpute method of imputing dropouts. Imputation is only carried out for genes with more than 50 percent dropout. Please consider multiple cores to speed up computation.}
\item{DrImpute}{employs DrImpute method of imputing dropouts as implemented
in \code{\link[DrImpute]{DrImpute}}.}
\item{SAVER}{employs SAVER method of imputing dropouts as implemented
in \code{\link[SAVER]{saver}}. Imputation is only carried out for genes with more than 50 percent dropout.}
\item{Seurat}{employs Seurat method of imputing dropouts as implemented
in \code{\link[Seurat]{AddImputedScore}} using variable genes identified with \code{\link[Seurat]{FindVariableGenes}}. Imputation is only carried out for genes with more than 50 percent dropout.}
\item{scone}{employs scone method of imputing dropouts as implemented
in \code{\link[scone]{scone}} using estimated dropout probabilities of \code{\link[scone]{estimate_ziber}}.}
}
}

\section{Normalisation applied to (imputed) read count matrix}{

\describe{
\item{TMM, UQ}{employ the edgeR style normalization of weighted trimmed mean of M-values and upperquartile
as implemented in \code{\link[edgeR]{calcNormFactors}}, respectively.}
\item{MR, PosCounts}{employ the DESeq2 style normalization of median ratio method and a modified geometric mean method
as implemented in \code{\link[DESeq2]{estimateSizeFactors}}, respectively. Spike-ins can also be supplied for both methods via \code{spikeData}.}
\item{scran, SCnorm}{apply the deconvolution and quantile regression normalization methods developed for sparse RNA-seq data
as implemented in \code{\link[scran]{computeSumFactors}} and \code{\link[SCnorm]{SCnorm}}, respectively. Spike-ins can also be supplied for both methods via \code{spikeData}. Note, however that this means for scran that the normalisation as implemented in \code{\link[scran]{computeSpikeFactors}} is also applied to genes (\code{general.use=TRUE}). Please consider multiple cores to speed up computation for SCnorm.}
\item{Linnorm}{apply the normalization method for sparse RNA-seq data
as implemented in \code{\link[Linnorm]{Linnorm.Norm}}.
For \code{Linnorm}, the user can also supply \code{spikeData}.}
\item{RUV}{removes unwanted variation. There are two approaches implemented:
(1) utilizing negative control genes, i.e. spike-ins stored in \code{spikeData} (\code{\link[RUVSeq]{RUVg}}).
(2) utilizing replicate samples, i.e. samples for which the covariates of interest are considered constant.
This annotation is stored in \code{batchData} (\code{\link[RUVSeq]{RUVs}}).}
\item{Census}{converts relative measures of TPM/FPKM values into mRNAs per cell (RPC) without the need of spike-in standards.
Census at least needs \code{Lengths} for single-end data and preferably \code{MeanFragLengths} for paired-end data.
Do not use this algorithm for UMI data!}
\item{depth}{Sequencing depth normalisation.}
}
}

\section{Differential testing using raw read count matrix}{

\describe{
\item{T-Test}{A T-Test per gene is applied using log2 transformed and normalized expression values (i.e. CPM or TPM).}
\item{limma-trend, limma-voom}{apply differential testing as implemented in \code{\link[limma]{lmFit}}
followed by \code{\link[limma]{eBayes}} on counts transformed by \code{\link[limma]{voom}} or by applying mean-variance trend on log2 CPM values in \code{\link[limma]{eBayes}}.}
\item{edgeR-LRT, edgeR-QL}{apply differential testing as implemented in \code{\link[edgeR]{glmFit}}, \code{\link[edgeR]{glmLRT}} and\code{\link[edgeR]{glmQLFit}}, \code{\link[edgeR]{glmQLFTest}}, respectively.}
\item{DESeq2}{applies differential testing as implemented in \code{\link[DESeq2]{DESeq}}.}
\item{ROTS}{applies differential testing as implemented in \code{\link[ROTS]{ROTS}} with 100 permutations on transformed counts (\code{\link[limma]{voom}}).}
\item{baySeq}{applies differential testing as implemented in \code{\link[baySeq]{getLikelihoods}} based on negative binomial prior estimates (\code{\link[baySeq]{getPriors.NB}}).}
\item{NOISeq}{applies differential testing as implemented in \code{\link[NOISeq]{noiseqbio}} based on CPM values.}
\item{EBSeq}{applies differential testing as implemented in \code{\link[EBSeq]{EBTest}}.}
\item{MAST}{applies differential testing as implemented in \code{\link[MAST]{zlm}} for zero-inflated model fitting followed by \code{\link[MAST]{lrTest}} on log2 CPM values.}
\item{scde}{applies differential testing as implemented in \code{\link[scde]{scde.expression.difference}}.}
\item{BPSC}{applies differential testing as implemented in \code{\link[BPSC]{BPglm}} on CPM values.}
\item{scDD}{applies differential testing as implemented in \code{\link[scDD]{scDD}} on CPM values.}
\item{DECENT}{applies differential testing as implemented in \code{\link[DECENT]{decent}}.}
\item{edgeR-zingeR, DESeq2-zingeR}{In a first step, the posterior probabilities of the zero-inflated negative binomial component are estimated (see \code{\link[zingeR]{zeroWeightsLS}}) and used to define a weight matrix for dispersion estimation in \code{\link[edgeR]{estimateDisp}}. For the edgeR approach, the generalized model as implemented in \code{\link[edgeR]{glmFit}} is fitted. This is followed by an adapted LRT for differential testing to account for the weighting (see \code{\link[zingeR]{glmWeightedF}}). For DESeq2, the generalized linear model coefficients are estimated using \code{\link[DESeq2]{nbinomWaldTest}} and the weighting is done by setting the degrees of freedom for the T distribution.}
\item{edgeR-ZINB-WaVE, DESeq2-ZINB-WaVE}{In a first step, a zero-inflated negative binomial regression model  is fitted (see \code{\link[zinbwave]{zinbFit}}) to estimate observational weights (see \code{\link[zinbwave]{computeObservationalWeights}}) used for dispersion estimation in \code{\link[edgeR]{estimateDisp}}. For the edgeR approach, the generalized model as implemented in \code{\link[edgeR]{glmFit}} is fitted. This is followed by an adapted LRT for differential testing to account for the weighting (see \code{\link[zinbwave]{glmWeightedF}}). For DESeq2, the generalized linear model coefficients are estimated using \code{\link[DESeq2]{nbinomWaldTest}} and the weighting is done by setting the degrees of freedom for the T distribution.}
}
}

\examples{
\dontrun{
## define DE parameters and set up simulations
de.opts <- DESetup(ngenes = 10000, nsims = 25,
p.DE = 0.2, pLFC = function(x) sample(c(-1,1), size=x,replace=TRUE)*rgamma(x, 3, 3),
p.B=0.1, bLFC = function(x) rnorm(x, mean=0, sd=1.5), bPattern="uncorrelated",
sim.seed = 43856)
sim.opts <- SimSetup(desetup = de.opts,
params = kolodziejczk_param,
spike=NULL, size.factors = "equal",
downsample = FALSE, geneset = FALSE)
## run simulations
sim.res <- simulateDE(n1=c(50,96,384), n2=c(80,96,384),
sim.settings = sim.opts,
DEmethod = 'limma-trend',
Normalisation = 'scran',
Preclust = FALSE,
Prefilter = "FreqFilter",
Impute = NULL,
spikeIns = FALSE,
NCores = NULL,
verbose = TRUE)
}
}
\seealso{
\code{\link{estimateParam}},  \code{\link{insilicoNBParam}} for negative binomial parameter specifications;\cr
 \code{\link{DESetup}}, \code{\link{SimSetup}} for simulation setup;\cr
 \code{\link{evaluateDE}} for DE evaluation.
}
\author{
Beate Vieth
}
