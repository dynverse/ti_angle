#!/usr/local/bin/Rscript

task <- dyncli::main()

library(dyncli, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
library(purrr, warn.conflicts = FALSE)
library(dyndimred, warn.conflicts = FALSE)
library(dynwrap, warn.conflicts = FALSE)

#####################################
###           LOAD DATA           ###
#####################################

params <- task$params
expression <- task$expression

# TIMING: done with preproc
timings <- list(method_afterpreproc = Sys.time())

#####################################
###        INFER TRAJECTORY       ###
#####################################

# perform PCA dimred
dimred <- dyndimred::dimred(as.matrix(expression), method = params$dimred, ndim = 2)

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
