ISTIO_VERSION=${ISTIO_VERSION:-1.16.1}

git clone https://github.com/istio/proxy.git --depth 1
pushd proxy
git fetch --tags
git checkout "${ISTIO_VERSION}"

# Compile envoy with FIPS: https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/security/ssl#fips-140-2
echo "build --define boringssl=fips" >> .bazelrc
BUILD_WITH_CONTAINER=1 make build_wasm build build_envoy exportcache

popd

git clone https://github.com/istio/istio.git --depth 1
pushd istio
git fetch --tags
git checkout "${ISTIO_VERSION}"

# Pre-built binaries need to copied with SHA in name, otherwise build process will download it from gc bucket
# https://github.com/istio/istio/blob/1.16.1/bin/init.sh#L105

# Populate the git version for istio/proxy (i.e. Envoy)
PROXY_REPO_SHA="${PROXY_REPO_SHA:-$(grep PROXY_REPO_SHA istio.deps  -A 4 | grep lastStableSHA | cut -f 4 -d '"')}"

# Copy locally built binaries
mkdir -p out/linux_amd64/release
cp -f ../proxy/out/linux_amd64/envoy out/linux_amd64/release/envoy-${PROXY_REPO_SHA}
cp -f out/linux_amd64/release/envoy-${PROXY_REPO_SHA} out/linux_amd64/release/envoy
cp -f ../proxy/out/linux_amd64/stats.wasm out/linux_amd64/release/stats-${PROXY_REPO_SHA}.wasm
cp -f out/linux_amd64/release/stats-${PROXY_REPO_SHA}.wasm out/linux_amd64/release/stats-filter.wasm
cp -f ../proxy/out/linux_amd64/stats.compiled.wasm out/linux_amd64/release/stats-${PROXY_REPO_SHA}.compiled.wasm
cp -f out/linux_amd64/release/stats-${PROXY_REPO_SHA}.compiled.wasm out/linux_amd64/release/stats-filter.compiled.wasm
cp -f ../proxy/out/linux_amd64/metadata_exchange.wasm out/linux_amd64/release/metadata_exchange-${PROXY_REPO_SHA}.wasm
cp -f out/linux_amd64/release/metadata_exchange-${PROXY_REPO_SHA}.wasm out/linux_amd64/release/metadata-exchange-filter.wasm
cp -f ../proxy/out/linux_amd64/metadata_exchange.compiled.wasm out/linux_amd64/release/metadata_exchange-${PROXY_REPO_SHA}.compiled.wasm
cp -f out/linux_amd64/release/metadata_exchange-${PROXY_REPO_SHA}.compiled.wasm out/linux_amd64/release/metadata-exchange-filter.compiled.wasm

# Patch Makefile to use BoringCrypto: https://github.com/tetratelabs/istio/blob/tetrate-workflow/tetrateci/docs/fips.md
sed -i'' -e 's/GOOS=linux/CGO_ENABLED=1 GOEXPERIMENT=boringcrypto GOOS=linux/' Makefile.core.mk

# Envoy built with BoringSSL requires libc++ installed in the docker image
# Patch pilot/docker/Dockerfile.proxyv2 to install libc++
cat > Dockerfile.proxyv2.patch << EOF
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y libc++1 \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /tmp/* /var/tmp/* \
  && rm -rf /var/lib/apt/lists/*
EOF
sed -i'' '/FROM ${BASE_DISTRIBUTION/r Dockerfile.proxyv2.patch' pilot/docker/Dockerfile.proxyv2
rm Dockerfile.proxyv2.patch

# Build pilot and proxy
make docker.pilot docker.proxyv2
