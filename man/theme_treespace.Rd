% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/theme.R
\name{theme_treespace}
\alias{theme_treespace}
\title{Phylomorphospace theme No.1, with arrow-end axis and grey panel grid.}
\usage{
theme_treespace(...)
}
\arguments{
\item{...}{additional parameters for `ggplot2::theme`. Please use
`?ggplot2::theme()` to learn more information.}
}
\value{
a theme object with arrow-end axis
}
\description{
Phylomorphospace theme No.1, with arrow-end axis and grey panel grid.
}
\examples{
library(ggtree)
library(phytools)
library(ggtreeSpace)

tr <- rtree(15)
td <- fastBM(tr, nsim = 2)
ggtreespace(tr, td) +
    geom_tippoint() +
    theme_treespace()
}
