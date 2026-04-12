# Packer code to create Debian images

Build is done starting from Debian netinst images.

## Supported providers

Supported providers are
- KVM/QEMU
- Scaleway

Use the option `-only scaleway.debian` or `-only qemu.debian` to restrict which to build for.

### Scaleway

To use this build you must provide additional configuration:
- your access key, you can set it with the env var `SCW_ACCESS_KEY`
- your secret key, with `SCW_SECRET_KEY`
- project id, with `SCW_DEFAULT_PROJECT_ID`

Non secret variables can be set in `custom-variables.pkr.hcl` and used adiing the option `-var-file custom-variables.pkr.hcl` to the `build` command.

## Build image

Run this command first to install QEMU plugin
```
packer init .
```

Then build your image
```
PACKER_LOG=1 packer build -var-file debian-13.pkrvars.hcl build.pkr.hcl
```

## QEMU image use

Example of commands to import your image to your libvirt storage pool and then run it
```
sudo qemu-img convert -f qcow2 -O qcow2 output-debian-13/debian-13.qcow2 /var/lib/libvirt/images/debian-13.qcow2

virt-install \
  --connect qemu:///system \
  --name debian-13 \
  --memory 4096 \
  --vcpus 2 \
  --os-variant debian13 \
  --disk /var/lib/libvirt/images/debian-13.qcow2,bus=virtio \
  --network network=default,model=virtio \
  --graphics spice \
  --noautoconsole \
  --console pty,target_type=serial \
  --import \
  --debug
```
