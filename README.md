# OpenRFSense Image
This repository contains a custom [pi-gen](https://github.com/RPi-Distro/pi-gen) stage and necessary automation to create a system image based on Raspberry Pi OS Lite (ex Raspbian).
The system comes preconfigured with:
- Anything in the Raspberry Pi OS Lite system (debian, systemd, GNU core programs)
- [es-sensor](https://github.com/openrfsense/es-sensor) and [es-sensor-decoders](https://github.com/openrfsense/es-sensor-decoders)
- OpenRFSense node software (web UI, internal API and MQTT messaging, see repo)

# Building
> `pi-gen` does provide a build system in Docker ([see README](https://github.com/RPi-Distro/pi-gen/#docker-build)) but it requires `qemu-static-*` packages on the host, and those are extremely distro-dependent. At the time of writing the official build process only works on Debian, which is used in the VM.

[Vagrant](https://www.vagrantup.com/) is required. The image is built in a provisioned virtual machine to avoid polluting the host machine and provide a distro-independent build environment.

You will first have to write yourself a `config` file using the provided example (`config.example`). You can just rename or copy the example file without modifying it, but it's absolutely **not recommended**. The example file contains the necessary documentation for each variable.

To start a build job, use:

```shell
$ ./build.sh
```

By default, a 64bit ARM image will be built. If you need a 32bit image (older Raspberry Pi or other 32bit ARM boards), use the following command:

```shell
$ PIGEN_BITS=32 ./build.sh
```

If you want to allocate more resources for the VM, you can set the following environment variables:
- `PIGEN_CPUS`: number of processors to give the VM (default: all CPU cores except 2)
- `PIGEN_RAM`: megabytes of RAM to give the VM (default: 8192)