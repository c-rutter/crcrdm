
<!-- README.md is generated from README.Rmd. Please edit that file -->

# crcrdm: HPC and Robust Decision Making tools for Cancer Screening Models

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
resources. The package supports large-scale computational tasks that
have historically been deemed unfeasible for microsimulation models,
such as defining and conducting Probabilistic Sensitivity Analyses
(PSAs) or robustness analyses of large models and large combinations of
parameter sets.

The package is designed to support High-Performance Computing workflows
using EMEWS using the EMEWS UPF or the EQ/SQL backend. These features
allow for efficient use of High-Performance computing resources for
large-scale, long-running computational experiments.

## Installation

This package can be installed from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("c-rutter/crcrdm")
```

## Status

This package is **under development**, and will be used in Robust
Decision Making analyses that use cancer screening models. At this time,
the package is not appropriate for general use.

This repository **does not** contain code for the models used within
those analyses, and is made public to allow for automatic installation
across HPC systems and to support continuous integration workflows in
repositories that depend on this package. At this time, you **should not
use or rely on this package** unless you are involved in these
development efforts.

## Documentation

A documentation page is available [at this
link](https://c-rutter.github.io/crcrdm). This documentation page
describes the package main classes and their methods.

## Package Design and Requirements

This package builds from [our prior COVID-19
work](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0259166)
and is inspired by other RDM-related packages such as
[Rhodium](https://github.com/Project-Platypus/Rhodium) and the [EMA
Workbench](https://emaworkbench.readthedocs.io/en/latest/overview.html).
However, most of the features of those packages are not helpful for CRC
models (or health microsimulation models) for several reasons. In CRC
and health outcome models, much of the process of addressing
uncertainties lies in how models are specified and calibrated, and these
concerns are not addressed by those packages. Moreover, cohort
microsimulation models require us to simulate a natural history model
over a population before running intervention scenarios, and
uncertainties can affect both the natural history and interventions.
Therefore, these models do not benefit from the experimental designs
created in of-the-shelf packages.

With that in mind, this package will need to:

1.  **Handle experimental designs appropriate for cancer screening
    models with a natural history and a screening component:** The
    package will be designed for cancer microsimulation models with a
    natural history and a screening component.

2.  **Handle results from Bayesian Calibration**: A credible approach to
    handle uncertainty in cancer microsimulation models is to perform
    bayesian inference of unobservable parameters related to the natural
    history of the cancer. The package will accommodate one or multiple
    sets of parameters resulting from model calibration exercises.

3.  **Accommodate multiple models or multiple versions of the same
    model:** The questions we pose could require us to build multi-model
    analyses. We might have to compare the baseline specification of a
    model to new specifications (e.g., accounting for the SSP pathway).
    Using this package shouldn’t be harder than running multiple
    regressions with different functional forms.

4.  **Be EMEWS-compatible by design:** This package needs to be
    compatible with EMEWS, so we can use Argonne’s HPC systems
    efficiently. This is not too hard, but important design decisions
    need to be made and enforced such that there is a clear separation
    between specifying the model, specifying an experimental design,
    running the model for the natural history and screening components,
    then collecting results. We should be able to run any
    computation-intensive task in three modes, which roughly correspond
    to three phases of model development and use:

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

5.  **Efficiently handle long-running tasks:** Microsimulation model
    runs over thousands of parameter sets will take several thousand
    computing hours to complete and will require many terabytes of
    memory. These large-scale computational experiments can take days or
    weeks to complete, even with High-Performance Computing resources.
    Our current approaches for running large-scale experiments involve
    manual control of runs. We would like to have a better-designed
    process for these long-running tasks, and this package will
    accommodate that by intelligently setting simulation hyperparameters
    such that policy run tasks are divided and contained within
    wall-time limits and memory limits. Similarly, experiment runs
    should be randomized in a way that allows preliminary inspection of
    results. For policy experiments, we should be able to slowly draw
    tradeoff curves when we have only 10% of the design run, and we
    should be able to run the experiment over population sub-blocks
    before running it across the full population. This helps us to fail
    fast rather than waiting long runs to complete only to discover that
    something was wrong.

The `crcrdm` package fulfills these five requirements. The version 1.0
of the package fulfills requirements 1-4, and version 1.5 will fulfill
requirement 5.

## Key classes: `crcmodel`, and `crcexperiment`:

This package implements two R6 classes:

1.  `crcmodel` : Is the basic unit and encompasses a single model
    structure. A `crcmodel` can be either calibrated or not. if it is
    calibrated, the model object can include the posterior distribution
    of its parameters. A single model may contain multiple posterior
    distributions when those parameter sets were created by different
    calibration runs, with potentially different targets or priors.
2.  `crcexperiment` : Contains the definition of an experiment
    experiment to be applied over the `crcmodel`s included in it.

## Automated Tests and Test Coverage

This package is tested automatically after every commit across a few
platforms. Results from these automated checks can be found
[here](https://github.com/c-rutter/crcrdm/actions). A [test coverage
report can be found here](https://app.codecov.io/gh/c-rutter/crcrdm).
