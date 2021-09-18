
<!-- README.md is generated from README.Rmd. Please edit that file -->

# crcrdm: Robust Decision Making tools for CRC models

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

<!-- badges: end -->

## Installation

This package can be installed from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("c-rutter/crcrdm")
```

## Usage

There are two main classes implemented in this package: `crcmodel` and
`crcexperiment`.

A crcmodel object can represent any colorectal cancer model with a
natural history component and a screening component. `crcspin` is **a**
`crcmodel`.

The `crcmodel` object exists so we can create a `crcexperiment` the
`crcexperiment` can include one or more models and implements functions
that help us create experimental designs with multiple models.

## Requirements for this package

This package is being created with Rapid Response funds from the CRC
CISNET group, and will support two aims:

1.  **Incorporate the SSP pathway into the CRC-SPIN model**, and
    **calibrate the CRC-SPIN model under a wide range of SSP
    assumptions.**
2.  **Characterize the robustness of a set of CRC screening strategies**
    to those assumptions.

The `crcrdm` R package will support both aims. The functions contained
in this package could be included in scripts in a one-off R project, but
we envision that this work will be useful to other projects as well,
which is why we chose to create code that can be reused across analyses.

Initially, the package will be compatible with the `crcspin` model and
the `imabc` package. However, we will build this package in a way that
could allow other modeling groups to use it with their CRC models. At a
later stage, the functions created in this package could be re-used to
other purposes as well.

This package builds from [our prior work with
COVID-19](https://github.com/RANDCorporation/covid-19-reopening-california)
and is inspired by other RDM-related packages such as
[Rhodium](https://github.com/Project-Platypus/Rhodium) and the [EMA
Workbench](https://emaworkbench.readthedocs.io/en/latest/overview.html).
However, most of the features of those packages are not helpful for CRC
models for several reasons. In CRC and health outcome models, much of
the process of addressing uncertainties lies in how models are specified
and calibrated, and these concerns are not addressed by those packages.

With that in mind, this package will need to:

1.  **Accomodate multiple models or multiple versions of the same
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
    intelligently setting calibration hyperparameters such that
    calibration or policy run tasks are divided and contained within
    wall-time limits set in Argonne’s servers. Similarly, experiment
    runs should be randomized in a way that allows preliminary
    inspection of results. For policy experiments, we should be able to
    slowly draw tradeoff curves when we have only 10% of the design run.
    This helps us to fail fast rather than waiting long runs to complete
    only to discover that something was wrong.

## Key objects: `crcmodel`, and `crcexperiment`

To the purposes of the RDM analysis, we envision two key classes:

1.  `crcmodel` : Is the basic unit and encompasses a single model
    structure. A `crcmodel` can be either calibrated or not. if it is
    calibrated, the model object can include the posterior distribution
    of its parameters.
2.  `crcexperiment` : Contains the definition of an experiment
    experiment to be applied over the crcmodels included in it.

## Original Timeline

We will complete the basic structure of this R package (iterations 1 and
2) over the summer of 2021. By the end of this summer, we should be able
to complete each step in the analysis with a preliminary SSP model.

-   Iteration 1 – Aug 21- Setting up the analytic pipeline – existing
    model and screening policies

    -   Deliverable: Code to reproduce iteration 1

-   Iteration 2 –Sept 21- First SSP model specification and sparse
    experimental design

    -   Deliverables: Model write-up, illustrative scenario results –
        should reveal if edge cases are policy-relevant.

-   Iteration 3 – Nov 21  - CISNET Annual Meeting - Revised SSP model,
    granular experimental design

    -   Deliverables: Paper Intro and Method sections, illustrative
        scenario results

-   Iteration 4 – Jan 22 – Final SSP model, granular experimental design
    finished

    -   Deliverables: First paper draft finished, illustrative scenario
        results

-   Iteration 5 – April 22 – CISNET Mid-year meeting 

    -   Deliverables: Presentation for Mid-year meeting, Paper draft
        revised.

-   Iteration 6 – June 22 – Paper write-up

    -   Deliverables: Paper draft submitted.
