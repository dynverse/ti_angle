FROM dynverse/dynwrap:r

ADD . /code

LABEL version 0.1.2

ENTRYPOINT Rscript /code/run.R
