FROM dynverse/dynwrap:r

ADD . /code

LABEL version 0.1.5

ENTRYPOINT Rscript /code/run.R
