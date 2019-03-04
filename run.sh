#!/usr/local/bin/Rscript

library(readr, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
library(purrr, warn.conflicts = FALSE)
library(dyndimred, warn.conflicts = FALSE)
library(dynwrap, warn.conflicts = FALSE)
library(dyncli, warn.conflicts = FALSE)

#####################################
###           LOAD DATA           ###
#####################################

task <- dyncli::main(args = commandArgs(trailingOnly = TRUE))

params <- task$params
expression <- task$expression

#####################################
###        INFER TRAJECTORY       ###
#####################################

# TIMING: done with preproc
timings <- list(method_afterpreproc = Sys.time())

# perform PCA dimred
dimred <- dyndimred::dimred(as.matrix(expression), method = params$dimred, ndim = 2)

# transform to pseudotime using atan2
pseudotime <- atan2(dimred[,2], dimred[,1]) / 2 / pi + .5

# TIMING: done with method
timings$method_aftermethod <- Sys.time()

# return output
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

#####################################
###     SAVE OUTPUT TRAJECTORY    ###
#####################################
dyncli::write_h5(output, task$output)
