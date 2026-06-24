# NetCore product Linux installers

![CI](https://github.com/netcore-jsa/unimus-linux-installer/actions/workflows/ci.yml/badge.svg)

This repository contains the sources for the official NetCore j.s.a. Linux installers.  
These installers are used by Unimus and Unimus Core.

### TL;DR
Requirements: `bash` (plus `docker` for the container-based integration tests).
```text
./build.sh test                                             # assemble runnable scripts into target/
./test/unit/run-tests.sh                                    # fast unit tests (no docker)
./test/run-test-container.sh -c ubuntu:18.04 -p unimus -u   # real install test in docker
``` 

### How do the installers work?

Installers are split between shared code (in the `common` directory), and product-specific code 
(each in the appropriate per-product directory). You can check the `src` directory for the actual installer sources.

The `build.sh` script takes the shared and per-product code and generates complete and runnable bash 
installer scripts for each of our products.

### Supported distributions

The installers are tested - via the Docker integration suite - on the following
x86_64 distributions:

| Family        | Versions                                                              |
|---------------|-----------------------------------------------------------------------|
| AlmaLinux     | 10, 9, 8                                                              |
| Amazon Linux  | 2023, 2, AMI (1)                                                     |
| CentOS        | Stream 10, Stream 9, 8, 7, 6.10                                      |
| Debian        | 13 (trixie), 12 (bookworm), 11 (bullseye), 10 (buster), 9 (stretch), 8 (jessie) |
| Oracle Linux  | 10, 9, 8, 7                                                          |
| RHEL          | 10, 9, 8, 7, 6                                                       |
| Rocky Linux   | 10, 9, 8.5, 8.4                                                      |
| Ubuntu        | 26.04, 24.04, 22.04, 20.04, 18.04, 16.04, 14.04, 12.04              |

On ARM hosts, Raspbian (Buster, Stretch, Jessie) is also covered.

**Java:** the installer selects a supported OpenJDK at install time, ranging from
OpenJDK 8 on older releases up to OpenJDK 21 on the newest (EL10, etc.); on
Amazon Linux 2023 it uses Amazon Corretto, and on Debian it falls back to the
Eclipse Adoptium repo where the distro lacks a suitable package.

**End-of-life releases:** distributions whose upstream mirrors have been retired
(CentOS 6-8, Debian 8-10, Ubuntu 12.04, RHEL 6) are still tested - the test
harness repoints the container's package sources to the relevant archive/vault
mirrors. This is test scaffolding only; the installer itself never modifies a
system's repositories, so installing on such a release requires the machine to
already have working (archived) repos.

### Building the installers

How to build runnable installer scripts:
```text
./build.sh test
cd target
ls -l
tree
```

### Testing the installers

There are two layers of tests.

**Unit tests (no Docker)** exercise the installer logic in isolation - build/assembly,
argument parsing, the Java-version detection regex, the per-OS parameter contracts and
OS detection / repo routing. They need only `bash`:
```text
./test/unit/run-tests.sh
```

**Integration tests (Docker)** perform real installs inside containers for the Linux
distributions we support. Please make sure you have Docker working before running these.

How to run an integration test:
* run the script to spawn a test container:
```text
./test/run-test-container.sh
```
* Select the distribution you want to test from the menu
  
* Select which product to install from the menu

### Unattended (automated) testing

You can pull all officially supported images using the `pull-docker-images.sh` script.

Test scripts support unattended (automated) installation.  
You can pass the following arguments to the `run-test-container.sh` script:
```text
-c [image-name]             image to spawn the container from
-p [unimus|unimus-core]     product to install (Unimus or Unimus Core)
-u                          run the product installer in unattended mode
-d                          run the installer in debug mode
```

### Continuous integration

Every push to `master` and every pull request runs [GitHub Actions](.github/workflows/ci.yml):
it assembles the scripts, runs the unit test suite, and lints the shell scripts with ShellCheck.

### Contributing
We welcome any Pull Requests or ideas for improvement / feedback.

If you wish to contribute, you will want to look at the `src` and `test` directories.
We will only accept new distribution additions if they are fully testable (the distribution must be added to the Docker scripts in `test`).
When adding a distribution, also make sure the per-OS handling in `src/common/os-params` covers it
(package manager, Java packages, any repo setup), and consider extending the unit tests in `test/unit`.
