
<!-- README.md is generated from README.Rmd. Please edit that file -->

# crcrdm: High-Performance Computing and Robust Decision Making tools for Cancer Screening Models

<!-- badges: start -->

[![Build & R-CMD
Check](https://github.com/c-rutter/crcrdm/workflows/R-CMD-check/badge.svg)](https://github.com/c-rutter/crcrdm/actions)
[![Build & R-CMD Check -
full](https://github.com/c-rutter/crcrdm/workflows/R-CMD-check-full/badge.svg)](https://github.com/c-rutter/crcrdm/actions)
[![Test
Coverage](https://github.com/c-rutter/crcrdm/workflows/test-coverage/badge.svg)](https://github.com/c-rutter/crcrdm/actions)
[![codecov](https://codecov.io/gh/c-rutter/crcrdm/branch/master/graph/badge.svg?token=G4E73T9WOO)](https://codecov.io/gh/c-rutter/crcrdm)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://www.tidyverse.org/lifecycle/#stable)
<!-- badges: end -->

Characterizing the robustness of policy recommendations to uncertain
assumptions is a crucial concern of modelers. While the computational
cost of uncertainty analyses can be high, High-Performance Computing
(HPC) is increasingly ubiquitous and accessible. Nevertheless, using HPC
tools involves a steep learning curve, which may hinder their adoption.

This repository houses `crcrdm` – an R package designed to facilitate
the analysis of Cancer Screening Models using HPC resources. crcrdm
provides an interface between your model and a parallel back-end - an
HPC workflow system that orchestrates concurrent model runs. Currently,
we use this package with EMEWS. This package aims to make it easier to
define and efficiently run large experimental designs, reducing the need
to create ad-hoc analytical code for each analysis.

The package includes features useful in ongoing analyses performed with
the CRC-SPIN model. First, it partitions the memory usage of models to a
manageable size (e.g., the same model run is parallelized across
different computing processes and nodes). The package also supports
multi-model experimental designs. This package may also help facilitate
modeling transparency by separating the analytical workflow from the
model.

This package implements the `crcmodel` and the `crcexperiment` R6
classes and can be used to perform Robust Decision Making Analyses of
multiple cancer screening models using High-Performance Computing
resources. The package supports large-scale computational tasks that
have historically been deemed unfeasible for microsimulation models,
such as defining and conducting Probabilistic Sensitivity Analyses
(PSAs) or robustness analyses of large models and large combinations of
parameter sets.

## Installation

This package can be installed from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("c-rutter/crcrdm")
```

## Status

This package is being actively used by the crcspin model, which itself
is not contained in the package. The user pool for this package is small
and we have no plans of releasing it to CRAN at this time. If you would
like to use it, get in touch.

## Documentation

A documentation page is available [at this
link](https://c-rutter.github.io/crcrdm). This documentation page
describes the package main classes and their methods.

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
