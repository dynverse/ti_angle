#!/usr/bin/env Rscript

requireNamespace("dyncli", quietly = TRUE)
task <- dyncli::main()

requireNamespace("dyndimred", quietly = TRUE)
library(purrr, warn.conflicts = FALSE)
library(dynwrap, warn.conflicts = FALSE)

#####################################
###           LOAD DATA           ###
#####################################

parameters <- task$parameters
expression <- task$expression

# TIMING: done with preproc
timings <- list(method_afterpreproc = Sys.time())

#####################################
###        INFER TRAJECTORY       ###
#####################################

# perform PCA dimred
dimred <- dyndimred::dimred(expression, method = parameters$dimred, ndim = 2)

# transform to pseudotime using atan2
pseudotime <- atan2(dimred[,2], dimred[,1]) / 2 / pi + .5

# TIMING: done with method
timings$method_aftermethod <- Sys.time()

#####################################
###     SAVE OUTPUT TRAJECTORY    ###
#####################################
output <-
  wrap_data(
    cell_ids = rownames(expression)
  ) %>%
  add_cyclic_trajectory(
    pseudotime = pseudotime,
    do_scale_minmax = FALSE
  ) %>%
  add_dimred(
    dimred = dimred
  ) %>%
  add_timings(
    timings = timings
  )

dyncli::write_output(output, task$output)
