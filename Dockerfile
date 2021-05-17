FROM ubuntu:latest AS base
MAINTAINER joxcat
ENV ROOTDIR=/notebooks

ENV BUILD_DEPS=curl
RUN apt-get update -y
RUN apt-get install -y $BUILD_DEPS

# Install gophernotes
# https://github.com/gopherdata/gophernotes

# Install iruby
# https://github.com/SciRuby/iruby

# Install ielixir
# https://github.com/pprzetacznik/IElixir

# Install matlab
# https://github.com/calysto/matlab_kernel

# Install ocaml
# https://github.com/akabe/ocaml-jupyter

# Install Elm
# https://github.com/abingham/jupyter-elm-kernel
WORKDIR /build/elm
RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz \
    && gunzip elm.gz \
    && chmod +x elm \
    && mv elm /usr/local/bin/
WORKDIR /build
RUN pip install elm_kernel \
    && python -m elm_kernel.install

# Install Emu86
# https://github.com/gcallah/Emu86/tree/master/kernels

# Install coq
# https://github.com/EugeneLoy/coq_jupyter

# Install TS / JS
# https://github.com/yunabe/tslab

# Install Rust
# https://github.com/google/evcxr/tree/main/evcxr_jupyter

# Install Clojure
# https://github.com/clojupyter/clojupyter

# Install Java
# https://github.com/SpencerPark/IJava

# Cleanup
RUN apt-get remove $BUILD_DEPS
RUN apt-get clean

VOLUME $ROOTDIR
WORKDIR $ROOTDIR
EXPOSE 8888
CMD [ "jupyter", "notebook", "--no-browser", "--allow-root", "--ip=0.0.0.0" ]

FROM base
COPY . $ROOTDIR
