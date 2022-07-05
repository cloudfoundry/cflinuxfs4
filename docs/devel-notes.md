# Notes

## Setup

* While building the rootfs, if `apt-get` fails with the following error:
  ```
  E: Problem executing scripts APT::Update::Post-Invoke 'rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true'
  E: Sub-process returned an error code
  ```
  Then, you need to update your docker.
  You need Docker >= 20.10.9.
  This is because newer ubuntu versions use Glibc 2.34 which uses a new system call called `clone3`,
  which is not in the allowlist of the default seccomp profile for older docker versions.

  See https://github.com/moby/moby/pull/42681

## Packages

Compared to cflinuxfs3, counterparts for the following packages
could not be found:
libcloog-isl4, libparse-debianchangelog-perl, ttf-dejavu-core, ureadahead
