# Docker Image for Packer builds with QEMU

Docker container for building packer images with QEMU.

## Installed Tools
 
* rake (ruby)
* ansible (python3)
* packer
* kvm (qemu) 
* noVNC

## Usage

Change into your packer project directory and run the script
`docker-packer` follwed by the `packer` command. E.g.

```
docker-packer packer build -parallel-builds=1 ubuntu.pkr.hcl
```

