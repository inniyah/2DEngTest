ARG BASE_CONTAINER=jupyter/tensorflow-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Miriam Ruiz <miriam@debian.org>"

USER root

RUN \
    apt-get update && apt-get install -y \
        build-essential \
        pkg-config \
        python3 \
        cython3 \
        imagemagick \
        python3-pythonmagick \
        libcairo2-dev && \
    apt-get upgrade -y && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

RUN \
    pip install --quiet 'pygame' && \
    pip install --quiet 'pycairo' && \
    pip install --quiet 'mido' && \
    pip install --quiet 'igraph' && \
    pip install --quiet 'scikit-learn' && \
    pip install --quiet 'tensorflow-datasets' && \
    pip install --quiet 'pyyaml' && \
    pip install --quiet 'pyaml' && \
    pip install --quiet 'ruamel.yaml' && \
    pip install --quiet 'schema' && \
    pip install --quiet 'tinydb' && \
    pip install --quiet 'wand' && \
    pip install --quiet 'colorama' && \
    pip install --quiet 'coloredlogs' && \
    pip install --quiet 'progressbar2' && \
    pip install --quiet 'PyTMX' && \
    pip install --quiet 'ulvl' && \
    pip install --quiet 'invoke' && \
    pip install --quiet 'sh' && \
    pip install --quiet 'Cython' && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
