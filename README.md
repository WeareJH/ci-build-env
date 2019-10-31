<h1 align="center">Magento Docker CI Build Environments</h1>

<p align="center">
    <a href="https://hub.docker.com/r/wearejh/ci-build-env/builds/" title="Stars" target="_blank">
        <img src="https://img.shields.io/docker/stars/wearejh/ci-build-env.svg?style=flat-square" />
    </a>
    <a href="https://hub.docker.com/r/wearejh/ci-build-env/builds/" title="Pulls" target="_blank">
        <img src="https://img.shields.io/docker/pulls/wearejh/ci-build-env.svg?style=flat-square" />
    </a>
    <a href="https://hub.docker.com/r/wearejh/ci-build-env/builds/" title="Automated" target="_blank">
        <img src="https://img.shields.io/docker/automated/wearejh/ci-build-env.svg?style=flat-square" />
    </a>
    <a href="https://hub.docker.com/r/wearejh/ci-build-env/builds/" title="Build Status" target="_blank">
        <img src="https://img.shields.io/docker/build/wearejh/ci-build-env.svg?style=flat-square" />
    </a>
</p>

---

Docker images for CI build environments. Supported PHP versions are `7.1`, `7.2`  and `7.3`

## Pull / Run

```
# Replace {VERSION} witht the PHP version required
docker pull wearejh/ci-build-env:{VERSION}
docker run --rm -it wearejh/ci-build-env:{VERSION} sh
```

## Building

```
# Replace {VERSION} with the required PHP version to build
./build.sh {VERSION}
```

