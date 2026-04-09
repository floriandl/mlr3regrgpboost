# mlr3regrgpboost

GPBoost regression learner for mlr3.

## Installation

```r
remotes::install_github("floriandl/mlr3regrgpboost")
```

## Usage

```r
library(mlr3)
library(mlr3regrgpboost)

task = mlr3::tsk("mtcars")
learner = LearnerRegrGPBoost$new()
learner$train(task)
predictions = learner$predict(task)
```

## Related work

* [Course wiki](https://github.com/tdhock/2026-01-aa-grande-echelle/wiki/projets)
* [GPBoost(CRAN Archive)](https://cran.r-project.org/package=gpboost) - Core package for GPB.
* [Issue mlr3extralearners #403](https://github.com/mlr-org/mlr3extralearners/issues/357) (Tree-boosted GPBoost)

## Author

**Florian Delage** - [GitHub](https://github.com/floriandl)

## Licence

LGLP-3 License

