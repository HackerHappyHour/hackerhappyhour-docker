## Version 1.0.0

Since this module was forked from `garethr/docker`, the changes listed below
are changes from the latest release of `garethr/docker` at the time we forked.

The v1 release of this module will officially drop support for puppet 3. This module
will support puppet 5, but should run without difficulty on puppet 4.

### Removals

- `docker::docker_cs`. Replaced by `docker::edition`

### Deprecations

- `docker::version`. Version specifications can now be passed via the `docker::ensure` parameter
