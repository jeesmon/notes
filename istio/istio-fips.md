# Istio FIPS

Notes:

* `--define boringssl=fips` option is only available on Linux-x86_64: https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/security/ssl#fips-140-2

* Need a powerful machine to build envoy/istio in a reasonable time. Using`c6id.metal` on AWS, you can build it under 30mnts.
https://www.envoyproxy.io/docs/envoy/latest/faq/build/speed

* Verify build with
```
envoy --version
envoy  version: db8a88da7a0a3b8259a2f6b6ee4a806c23795a9f/1.24.2-dev/Modified/RELEASE/BoringSSL-FIPS

pilot-agent version
version.BuildInfo{Version:"1.16-dev", GitRevision:"f6d7bf648e571a6a523210d97bde8b489250354b-dirty", GolangVersion:"go1.19.4 X:boringcrypto", BuildStatus:"Modified", GitTag:"1.16.1"}

pilot-discovery version
version.BuildInfo{Version:"1.16-dev", GitRevision:"f6d7bf648e571a6a523210d97bde8b489250354b-dirty", GolangVersion:"go1.19.4 X:boringcrypto", BuildStatus:"Modified", GitTag:"1.16.1"}
```

Helpful Docs:

* https://github.com/istio/istio/issues/37118
* https://github.com/tetratelabs/istio/blob/tetrate-workflow/tetrateci/docs/fips.md
* https://github.com/istio/istio/issues/31519
