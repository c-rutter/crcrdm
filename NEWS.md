# crcrdm 1.0.0.9000 (development version)

# crcrdm 1.0.2

* `experiment$write_design()` now writes to csv and json files (#32 and fixes #33) 

# crcrdm 1.0.1

* implements #28, now json file don't have to include all model inputs by @pedroliman in https://github.com/c-rutter/crcrdm/pull/29
* `crcmodel$set_posterior()` now supports weighted sample (resample = T), the full posterior (resample =F) or taking the weighted posterior mean of parameters (use_average = T) #31
* `crcexperiment$set_design(nlock_ids = 1:2)` now can be used to filter population blocks in the experimental deign @pedroliman in https://github.com/c-rutter/crcrdm/pull/27
* fixing typo by @pedroliman in https://github.com/c-rutter/crcrdm/pull/30

# crcrdm 1.0.0

* First stable version of the package.
* Implements the `crcmodel` and `crcexperiment` classes.
* `crcmodel` can be used to represent a cancer screening model with a natural history component and a screening component.
* `crcexperiment` can be used to create experimental designs with multiple models, each with multiple parameters distributions.
* `crcexperiment` also supports population blocks, which can be used to divide simulation runs in population sizes at the HPC side.
* `crcexperiment` also supports pre-defined grid experimental designs.

# crcrdm 0.1.0

* Added a `NEWS.md` file to track changes to the package.
