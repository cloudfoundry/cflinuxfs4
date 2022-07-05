# Cloud Foundry stack: cflinuxfs4

This is a work-in-progress rootfs that would be eventually moved to https://github.com/cloudfoundry/cflinuxfs4

This stack is derived from Ubuntu 22.04 LTS (Jammy Jellyfish)

# Dependencies

* GNU make
* Docker

# Creating a rootfs tarball

To create a rootfs for the cflinuxfs4 stack:

```shell
make
```

This will create the `cflinuxfs4.tar.gz` file, which is the artifact used as the rootfs in Cloud Foundry deployments.
