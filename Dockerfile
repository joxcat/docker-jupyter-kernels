FROM alpine:3.13
MAINTAINER joxcat

RUN set -x \
    && apk --no-cache add \
        alpine-sdk \
        ca-certificates \
        python3 \
        py3-pip \
        su-exec \
        gcc \
        git \
        pkgconfig \
        libzmq \
        zeromq-dev \
        musl-dev \
        python3-dev \
        libffi-dev \
        zlib-dev \
        make \
    && pip install --upgrade pip==21.1.1 \
    && ln -s /usr/bin/python3.7 /usr/bin/python \
    ## jupyter notebook
    && ln -s /usr/include/locale.h /usr/include/xlocale.h \
    && pip install 'jupyterlab>=3.0.0,<4.0.0a0' jupyterlab-lsp notebook pyzmq tornado ipykernel ipywidgets pyzmq

# Install gophernotes
# https://github.com/gopherdata/gophernotes
ENV GOPATH /go
RUN apk add --no-cache go
RUN env GO111MODULE=on go get github.com/gopherdata/gophernotes@v0.7.2
RUN mkdir /usr/share/jupyter/kernels/gophernotes \
    && cd /usr/share/jupyter/kernels/gophernotes \
    && cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@v0.7.2/kernel/* "." \
    && chmod +w ./kernel.json \
    && sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json

# Install iruby
# https://github.com/SciRuby/iruby
RUN apk add --no-cache \
    ruby \
    ruby-dev \
    ruby-rdoc
RUN gem install ffi-rzmq
RUN gem install iruby --pre
RUN iruby register --force

# Install ielixir
# https://github.com/pprzetacznik/IElixir
ENV MIX_ENV=prod MIX_HOME=/opt/mix HEX_HOME=/opt/hex PATH=/opt/mix:${PATH}
RUN apk add --no-cache \
    elixir \
    erlang
RUN mkdir -p /opt \
    && mix local.rebar --force \
    && mix local.hex --force \
    && git clone --depth 1 https://github.com/pprzetacznik/IElixir.git /opt/ielixir \
    && cd /opt/ielixir \
    && mix deps.get && MIX_ENV=prod mix compile
RUN echo '{"argv":["/opt/ielixir/start_script.sh","{connection_file}"],"display_name":"Elixir","language":"Elixir"}' \
    | python3 -m json.tool > /opt/ielixir/resources/ielixir/kernel.json \
    && cp -r /opt/ielixir/resources/ielixir /usr/share/jupyter/kernels

# Install matlab
# https://github.com/calysto/matlab_kernel
RUN pip install matlab_kernel

# Install ocaml
# https://github.com/akabe/ocaml-jupyter
RUN apk add --no-cache opam \
    && opam init --yes --disable-sandboxing \
    && opam install --yes jupyter \
    && opam install--yes jupyter-archimedes \
    && ocaml-jupyter-opam-genspec \
    && cp -r "$(opam var share)/jupyter" /usr/share/jupyter/ocaml

# Install Elm
# https://github.com/abingham/jupyter-elm-kernel
RUN pip install elm_kernel

# Install Emu86
# https://github.com/gcallah/Emu86/tree/master/kernels
RUN pip install emu86 \
    && python -m kernels.intel.install

# Install coq
# https://github.com/EugeneLoy/coq_jupyter

# Cleanup
RUN cd - \
    && find /usr/lib/python* -name __pycache__ | xargs rm -r \
    && rm -rf \
        /root/.[acpw]* \
        ipaexg00301* \
    && rm -rf /var/cache/apk/*

VOLUME /notebooks
WORKDIR /notebooks
EXPOSE 8888
CMD [ "jupyter", "notebook", "--no-browser", "--allow-root", "--ip=0.0.0.0" ]
