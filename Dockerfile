FROM dynverse/dynwrapr:v0.1.0

ARG GITHUB_PAT

COPY definition.yml example.h5 run.R /code/

ENTRYPOINT ["/code/run.R"]
