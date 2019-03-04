FROM dynverse/dynwrapr:v0.1.0

ARG GITHUB_PAT

COPY definition.yml example.R run.sh /code/

RUN R -e 'devtools::install_github("dynverse/dyncli", dependencies = TRUE)' && \
	rm -rf /tmp/*

LABEL version 0.2.0

ENTRYPOINT ["/code/run.R"]
