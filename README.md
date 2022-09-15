# Docker Image for Packer builds with QEMU

![gitlab avatar](icons/gitlab-avatar.png)

Docker container for building packer images with QEMU and Ansible.

## Installed Tools

  - rake (ruby)

  - ansible (python3)

  - packer

  - kvm (qemu)

  - noVNC

## Usage

Change into your packer project directory and run the script
`docker-packer` follwed by the `packer` command. E.g.

``` console
docker-packer packer build -parallel-builds=1 ubuntu.pkr.hcl
```
