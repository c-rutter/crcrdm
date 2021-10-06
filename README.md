
<!-- README.md is generated from README.Rmd. Please edit that file -->

# crcrdm: HPC and Robust Decision Making tools for CRC models

<!-- badges: start -->

[![Build & R-CMD
Check](https://github.com/c-rutter/crcrdm/workflows/R-CMD-check/badge.svg)](https://github.com/c-rutter/crcrdm/actions)
[![Build & R-CMD Check -
full](https://github.com/c-rutter/crcrdm/workflows/R-CMD-check-full/badge.svg)](https://github.com/c-rutter/crcrdm/actions)
[![Test
Coverage](https://github.com/c-rutter/crcrdm/workflows/test-coverage/badge.svg)](https://github.com/c-rutter/crcrdm/actions)
[![codecov](https://codecov.io/gh/c-rutter/crcrdm/branch/master/graph/badge.svg?token=G4E73T9WOO)](https://codecov.io/gh/c-rutter/crcrdm)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-blue.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

This package implements the `crcmodel` and the `crcexperiment` R6
classes and can be used to perform Robust Decision Making Analyses of
multiple cancer screening models using High-Performance Computing
resources. The package supports common tasks, such as defining and
conducting Probabilistic Sensitivity Analyses (PSAs) with one or
multiple models. The package is also designed to support
High-Performance Computing workflows using EMEWS using the EMEWS EQ/SQL
backend. This feature will allow efficient use of High-Performance
computing resources for large-scale, long-running experiments that
involve simulating a population of 10 million of individuals across
thousands to millions of simulation scenarios.

## Installation

This package can be installed from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("c-rutter/crcrdm")
```

## Status

This package is under development, and will be used in Robust Decision
Making analyses that use cancer screening models.

This repository **does not** contain code for the models used within
those analyses, and is made public primarily to allow for automatic
installation across HPC systems and to support continuous integration
workflows in repositories that depend on this package. You should not
use or rely on this package unless you are involved in these development
efforts.

## Package Design and Requirements

This package builds from [our prior work with
COVID-19](https://github.com/RANDCorporation/covid-19-reopening-california)
and is inspired by other RDM-related packages such as
[Rhodium](https://github.com/Project-Platypus/Rhodium) and the [EMA
Workbench](https://emaworkbench.readthedocs.io/en/latest/overview.html).
However, most of the features of those packages are not helpful for CRC
models (or health microsimulation models) for several reasons. In CRC
and health outcome models, much of the process of addressing
uncertainties lies in how models are specified and calibrated, and these
concerns are not addressed by those packages.

With that in mind, this package will need to:

1.  **Accommodate multiple models or multiple versions of the same
    model:** The questions we pose could require us to build multi-model
    analyses. We might have to compare the baseline specification of a
    model to new specifications (e.g., accounting for the SSP pathway).
    Using this package shouldn’t be harder than running multiple
    regressions with different functional forms.

2.  **Be EMEWS-compatible by design:** This package needs to be
    compatible with EMEWS, so we can use Argonne’s HPC systems
    efficiently. This is not too hard, but important design decisions
    need to be made and enforced such that there is a clear separation
    between specifying the model, specifying a calibration exercise,
    running the calibration exercise, then collecting results. We should
    be able to run any computation-intensive task in three modes, which
    roughly correspond to three phases of model development and use:

    1.  **Running it Locally - sequentially (for testing and
        debugging):** During the first stages of model development,
        modelers are debugging their models and inspecting them in
        detail. Once the model is verified and “seems to be working”,
        they go to the next phase.

    2.  **Running it in small servers or locally - in parallel**: This
        scale (e.g. &lt; 100 h of CPU time) is more appropriate for
        small, proof-of-concept or sanity check runs. For example,
        modelers should do this before going big to test edge cases.

    3.  **HPC runs with EMEWS (&gt; 100 CPU hours):** These are useful
        to perform the actual, “production runs”.

    These three modes are important and making it easy to navigate
    between them is crucial, especially with iterative approaches like
    RDM. This should allow modelers to do their modeling work, then to
    scale it with HPC systems as they become confident in the model -
    rather than having them trying to calibrate broken models in HPC
    systems because our setup was to inflexible to allow the appropriate
    process.

3.  **Efficiently handle long-running tasks:** Actual production runs
    can take days or weeks to complete, even with HPC resources. Our
    current approaches for dealing with this involve manual control of
    runs. We would like to have a better-designed process for these
    long-running tasks, and this package can accommodate that by
    intelligently setting simulation hyperparameters such that policy
    run tasks are divided and contained within wall-time limits and
    memory limits set in Argonne’s servers. Similarly, experiment runs
    should be randomized in a way that allows preliminary inspection of
    results. For policy experiments, we should be able to slowly draw
    tradeoff curves when we have only 10% of the design run. This helps
    us to fail fast rather than waiting long runs to complete only to
    discover that something was wrong.

## Key classes: `crcmodel`, and `crcexperiment`:

To the purposes of the RDM analysis, we envision two key classes:

1.  `crcmodel` : Is the basic unit and encompasses a single model
    structure. A `crcmodel` can be either calibrated or not. if it is
    calibrated, the model object can include the posterior distribution
    of its parameters. A single model may contain multiple posterior
    distributions when those parameter sets were created by different
    calibration runs, with potentially different targets or priors.
2.  `crcexperiment` : Contains the definition of an experiment
    experiment to be applied over the `crcmodel`s included in it.
