library(jsonlite)
library(readr)
library(dplyr)
library(purrr)
library(dyndimred)

#####################################
###           LOAD DATA           ###
#####################################

data <- read_rds("/ti/input/data.rds")
params <- jsonlite::read_json("/ti/input/params.json")

#####################################
###        INFER TRAJECTORY       ###
#####################################

# use seed if provided
if (!is.null(params$seed) && !is.na(params$seed)) set.seed(params$seed)

# fetch expression data
expression <- data$expression

# TIMING: done with preproc
timings <- list(method_afterpreproc = Sys.time())

# perform PCA dimred
dimred <- dyndimred::dimred(expression, method = params$dimred, ndim = 2)

# transform to pseudotime using atan2
pseudotime <- atan2(dimred[,2], dimred[,1]) / 2 / pi + .5

# TIMING: done with method
timings$method_aftermethod <- Sys.time()

# return output
output <- lst(
  cell_ids = rownames(expression),
  pseudotime,
  do_scale_minmax = FALSE,
  dimred,
  timings
)

#####################################
###     SAVE OUTPUT TRAJECTORY    ###
#####################################
write_rds(output, "/ti/output/output.rds")
