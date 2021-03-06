centroid2exp <- function(centroid, vd) {

    # do nornmalization as the same as in training dat aset
    vd <- m.f.s(list(vd), fdr.cutoff = 1, filter.cutoff = 1, perform.mad = FALSE)[[2]][[1]]
    gene.sig = intersect(rownames(centroid), rownames(vd))

    if (!isTRUE(all.equal(sort(rownames(centroid)), sort(gene.sig)))) {
        stop("missing prediction features in your expression dataset\n p")  # to valide data without missing data
    }
    vd = t(scale(t(vd[gene.sig, ])))
    centroid = centroid[gene.sig, ]
    vclass <- c()
    vcor <- c()
    for (i in seq_len(ncol(vd))) {
        d = vd[, i]
        c.cor = c()
        pv = c()
        for (j in colnames(centroid)) {
            centroidj = centroid[, j]
            corj = cor.test(centroidj, d, use = "complete", method = "pearson")
            c.cor[j] = corj$estimate
            pv[j] = corj$p.value
        }
        maxk = which.max(c.cor)
        group = names(maxk)
        vcor = rbind(vcor, c(colnames(vd)[i], group, c.cor[maxk], pv[maxk]))
        if (c.cor[maxk] > 0.1) {
            vclass[colnames(vd)[i]] = group
        } else {
            vclass[colnames(vd)[i]] = "Unclassified"
        }
        # vclass[colnames(vd)[i]]=group
    }
    return(list(overlap.gene = gene.sig, cluster = vclass, correlation = vcor, normalized.matrix = vd))
}
