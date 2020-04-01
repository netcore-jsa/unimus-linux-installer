# NetCore product Linux installers

This repository contains the sources for the official NetCore j.s.a. Linux installers.  
These installers are used by Unimus and Unimus Core.

### TL;DR
Requirements: `bash`, `docker`.
```text
./build.sh test
./test/run-test-container.sh -c ubuntu:18.04 -punimus -u
``` 

### How do the installers work?

Installers are split between shared code (in the `common` directory), and product-specific code 
(each in the appropriate per-product directory). You can check the `src` directory for the actual installer sources.

The `build.sh` script takes the shared and per-product code and generates complete and runnable bash 
installer scripts for each of our products.

### Building the installers

How to build runnable installer scripts:
```text
./build.sh test
cd target
ls -l
tree
```

### Testing the installers

In `test` you can find the scripts that utilize Docker to test the installer on various Linux distributions that we support.
Please make sure you have Docker working before running the test scripts.

How to test the installers:
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
-c=[image-name]             image to spawn the container from
-p=[unimus|unimus-core]     product to install (Unimus or Unimus Core)
-u                          run the product installer in unattended mode 
```

### Contributing
We welcome any Pull Requests or ideas for improvement / feedback.

If you wish to contribute, you will want to look at the `src` and `test` directories.
We will only accept new distribution additions if they are fully testable (the distribution must be added to the Docker scripts in `test`).
