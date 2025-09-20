#
# Rock R Server Dockerfile with DataSHIELD Survival profile
#
# Based on: https://github.com/datashield/docker-rock
#

FROM datashield/rock-base:6.3-R4.3

# Define package versions for reproducibility
ENV DSURVIVAL_VERSION v2.3.0-dev

# Rock library path
ENV ROCK_LIB /var/lib/rock/R/library

# Install DataSHIELD packages with specific versions

# dsSurvival (survival analysis functions)
RUN Rscript -e "remotes::install_github('datashield/dsSurvival', ref = '$DSURVIVAL_VERSION', dependencies = TRUE, upgrade = FALSE, lib = '$ROCK_LIB')"

# Fix ownership (Rock runs as non-root user)
RUN chown -R rock $ROCK_LIB