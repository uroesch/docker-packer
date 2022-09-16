# Docker Image for Packer builds with QEMU

![gitlab avatar](icons/gitlab-avatar.png)

Docker container for building packer images with QEMU and Ansible.

The repository also contain a `docker-packer` script which is a wrapper
around the packer which segregates the packer `artifacts` directory into a
temporary directory. This makes it possible to build the same OS in parallel.
E.g when running in a CD/CI pipeline.

## Installed Tools

  - rake (ruby)

  - ansible (python3)

  - packer

  - kvm (qemu)

  - noVNC

## docker-packer

### Usage

``` console
  Usage:
    docker-packer [-h|-V] | command

  Options:
    -h | --help         This message
    -V | --version      Display version and exit

  Descriptions:
    Wrapper script for use with docker.io/uroesch/packer container.
    Mounts the current working directory 'iso', 'images', 'artifacts'
    into the docker container and runs the provided command as
    pass through inside the container.
```

### Examples

Change into your packer project directory and run the script
`docker-packer` followed by the `packer` command. E.g.

``` console
docker-packer packer build -parallel-builds=1 ubuntu.pkr.hcl
```
