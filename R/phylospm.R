#' @title Plot phylogenetic scatterplot matrix.
#'
#' @description  This function creates a scatterplot matrix for comparing
#' multiple continuous traits mapped onto the same phylogenetic tree,
#' providing a visual representation of trait correlations and
#' evolutionary patterns.
#' @usage phylospm(
#' tr,
#' traits = NULL,
#' title = NULL,
#' xAxisLabels = NULL,
#' yAxisLabels = NULL,
#' tr.params = list(size = 1, colors = NULL, panel.grid = TRUE),
#' sptr.params = list(tippoint = TRUE, tiplab = FALSE, labdir = "horizonal",
#'                     panel.grid = TRUE)
#' )
#' @param tr A phylogenetic tree
#' @param traits A data frame containing multiple column of trait data
#' @param title Set the title for the phylogenetic scatterplot matrix
#' @param xAxisLabels Set the label of the x axis
#' @param yAxisLabels Set the label of the y axis
#' @param tr.params List of parameters to customize the phylogenetic tree
#' with continuous trait mapping as continuous colors on the branch.
#'
#' Users can add tip point, add tip label, set tip label direction and set
#' background gird.
#' @param sptr.params List of parameters to customize the phylomorphospaces.
#' Users can add tip point, add tip label, set tip label direction and set
#' background gird.
#'
#' @return phylospm object
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 scale_color_gradientn
#' @importFrom ggplot2 coord_cartesian
#' @importFrom ggtree ggtree
#' @importFrom ggtree geom_tippoint
#' @importFrom ggtree geom_tiplab
#' @importFrom ggplot2 coord_cartesian
#' @importFrom rlang sym
#'
#'
#' @examples
#' library(ggtree)
#' library(phytools)
#' library(ggtreeSpace)
#'
#' tr <- rtree(10)
#' a <- fastBM(tr, nsim = 4)
#'
#' phylospm(tr, a)
#' @export
phylospm <- function(tr, traits = NULL, title = NULL,
                        xAxisLabels = NULL, yAxisLabels = NULL,
                        tr.params = list(
                            size = 1,
                            colors = NULL,
                            panel.grid = TRUE
                            ),
                        sptr.params = list(
                            tippoint = TRUE,
                            tiplab = FALSE,
                            labdir = "horizonal",
                            panel.grid = TRUE
                            )) {
    options(warn = -1)

    message("Preparing phylogenetic scatterplot matrix, please wait...\n")

    if (is.null(traits)) {
        stop("Traits data is required.")
    }

    if (!is.data.frame(traits) && !is.matrix(traits)) {
        stop("The input traits data must be a data frame or matrix.")
    }

    if (is.null(tr.params$colors)) {
        tr.params$colors <- c(
            "red",
            "orange",
            "green",
            "cyan",
            "blue"
        )
    }

    if (is.null(title)) {
        title <- c("Phylogenetic Scatterplot Matrix")
    }

    default.tr.params <- list(
        size = 1,
        colors = c(
            "red",
            "orange",
            "green",
            "cyan",
            "blue"
        ),
        panel.grid = TRUE
    )
    new.tr.params <- set.params(tr.params, default.tr.params)


    default.sptr.params <- list(
        tippoint = TRUE,
        tiplab = FALSE,
        labdir = "horizonal",
        panel.grid = TRUE
    )
    new.sptr.params <- set.params(sptr.params, default.sptr.params)


    nc <- ncol(traits)
    colnames(traits) <- c(paste("V", seq_len(nc), sep = ""))
    trd <- ggtree::fortify(tr)
    anc <- apply(traits, 2, fastAnc, tree = tr)

    ftrd <- trd |>
        cbind(rbind(traits, anc))

    plst <- list()
    n <- 0
    for (i in seq_len(nc)) {
        for (j in seq_len(nc)) {
            n <- n + 1
            if (i == j) {
                suppressMessages(
                    p <- ggtree(
                        ftrd,
                        mapping = aes(color = !!sym(paste("V", i, sep = ""))),
                        continuous = "color", size = new.tr.params$size
                    ) +
                        scale_color_gradientn(
                            colors = new.tr.params$colors
                        ) +
                        coord_cartesian(default = TRUE) +
                        theme_treespace2()
                )

                p <- p + coordtrans(p, traits[, i])

                if (new.tr.params$panel.grid) {
                    p <- p + theme_bw()
                }
                plst[[n]] <- p
            }
            if (i != j) {
                p <- ggtreespace(tr, traits[, c(j, i)]) +
                    theme_treespace2()

                p <- lim_set(p, traits[, c(j, i)])

                if (new.sptr.params$tippoint) {
                    p <- p + geom_tippoint()
                }

                if (new.sptr.params$panel.grid) {
                    p <- p + theme_bw()
                }

                if (new.sptr.params$tiplab) {
                    if (new.sptr.params$labdir == "horizonal") {
                        p <- p + geom_tiplab(angle = 0)
                    }
                    if (new.sptr.params$labdir == "radial") {
                        p <- p + geom_tiplab()
                    }
                }


                plst[[n]] <- p
            }
        }
    }

    spm <- GGally::ggmatrix(plst,
        nc, nc,
        title = title,
        xAxisLabels = xAxisLabels,
        yAxisLabels = yAxisLabels,
    )

    return(spm)
}
