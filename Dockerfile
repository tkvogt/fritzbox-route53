FROM debian:latest AS builder
RUN apt-get update && apt-get install --assume-yes git curl make gcc g++ libgmp-dev zlib1g-dev awscli
# Install Stack.
RUN curl --location https://www.stackage.org/stack/linux-x86_64 > stack.tar.gz && \
  tar xf stack.tar.gz && \
  cp stack-*-linux-x86_64/stack /usr/local/bin/stack && \
  rm -f -r stack.tar.gz stack-*-linux-x86_64/stack && \
  stack --version

# Install GHC.
RUN stack setup && stack exec -- ghc --version

WORKDIR /build
COPY . /build
# Install dependencies.
RUN stack build --only-dependencies

# Build project.
RUN stack build --copy-bins --local-bin-path /usr/local/bin

# Run project.
ENV HOST 0.0.0.0
ENV PORT 8090
EXPOSE 8090
ENTRYPOINT ["/usr/local/bin/fritzbox-route53"]
