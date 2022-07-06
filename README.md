# Cloud Foundry stack: cflinuxfs4

This stack is derived from Ubuntu 22.04 LTS (Jammy Jellyfish)

## Dependencies

* GNU make
* Docker >= 20.10.9

## Creating a rootfs tarball

To create a rootfs for the cflinuxfs4 stack:

```shell
make
```

This will create the `cflinuxfs4.tar.gz` file, which is the artifact used as the rootfs in Cloud Foundry deployments.

# Creating a BOSH release from the rootfs tarball

To start, clone the [repository](https://github.com/cloudfoundry/cflinuxfs4-release) containing the cflinuxfs4-rootfs BOSH release:

```shell
git clone git@github.com:cloudfoundry/cflinuxfs4-release.git
cd cflinuxfs4-release
```

Replace the old cflinuxfs4 tarball with the new tarball created above:

```shell
rm -f config/blobs.yml
mkdir -p blobs/rootfs
cp <path-to-new-tarball>/cflinuxfs4.tar.gz blobs/rootfs/cflinuxfs4-new.tar.gz
```

Create a dev release and upload it to your BOSH deployment:

```shell
bosh create release --force --with-tarball --name cflinuxfs4-rootfs
bosh upload release <generated-dev-release-tar-file>
```

If your Diego deployment manifest has `version: latest` indicated for the `cflinuxfs4` release, then redeploying Diego will enable this new rootfs.

# Release pipeline

The generation and release of a new rootfs happens on the [cflinuxfs4](https://buildpacks.ci.cf-app.com/pipelines/cflinuxfs4) CI pipeline.
