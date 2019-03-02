# Unimus Linux installer

This repository contains the sources for the official Unimus Linux installer.

### Building the installer
You can check the `src` directory for the actual installer sources.

How to build runnable installer scripts:
```
./build.sh test
cd target
ls -l
```

### Testing the installer

In `test` you can find the scripts that utilize Docker to test the installer on various Linux distributions that we support.
Please make sure you have Docker working before running the test scripts.

How to test the installer:
* run the script to spawn a test container:
```
./test/run-test-container.sh
```
* Select the distribution you want to test in the menu.
  
* After you get the bash prompt in your selected distribution, run:
```
/root/unimus-installer/install.sh
```

### Contributing
We welcome any Pull Requests or ideas for improvement / feedback.

If you wish to contribute, you will want to look at the `src` and `test` directories.
We will only accept new distribution additions if they are fully testable (the distribution must be added to the Docker scripts in `test`).
