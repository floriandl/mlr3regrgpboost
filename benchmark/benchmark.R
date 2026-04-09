library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(mlr3tuning)
library(ggplot2)
library(mlr3regrgpboost)
library(sp)


data("ChickWeight")
task_chick <- as_task_regr(ChickWeight, target = "weight", id = "chickweight")
data("meuse", package = "sp")
meuse_dt <- meuse[, c("x", "y", "dist", "soil", "zinc")]
task_meuse <- as_task_regr(meuse_dt, target = "zinc", id = "meuse_spatial")

task_list <- list(task_chick, task_meuse)

pipeline_base <- po("removeconstants") %>>% po("encode")
learner_glmnet <- as_learner(pipeline_base %>>% lrn("regr.cv_glmnet", id = "CV_Glmnet"))

learner_gpboost <- LearnerRegrGPBoost$new()
learner_gpboost$id <- "GPBoost"
learner_gpboost$param_set$values$nrounds <- 500
learner_gpboost$param_set$values$learning_rate <- 0.05 
learner_gpboost$param_set$values$max_depth <- 6 
learner_gpboost$param_set$values$num_leaves <- 64

learner_featureless <- lrn("regr.featureless", id = "Featureless")
learner_knn <- lrn("regr.kknn", id = "KNN")
learner_knn$param_set$values$k <- to_tune(1, 10)
at_knn <- auto_tuner(
  learner = learner_knn,
  tuner = tnr("grid_search", resolution = 10),
  resampling = rsmp("cv", folds = 3),
  measure = msr("regr.mse")
)

learner_list <- list(
  learner_gpboost,
  learner_featureless,
  learner_glmnet,
  at_knn
)

cv <- rsmp("cv", folds = 5)

grid <- benchmark_grid(
  tasks = task_list,
  learners = learner_list,
  resamplings = cv
)
bmr <- benchmark(grid)

results <- bmr$score(msrs(c("regr.rmse", "regr.mse")))

plot_dt <- results[, .(
  task_id,
  learner_id,
  iteration,
  rmse = regr.rmse
)]


p <- ggplot(plot_dt, aes(x = rmse, y = learner_id)) +
  geom_point() +
  facet_grid(task_id ~ .) +
  theme_bw() +
  labs(
    title = "Benchmark performance: GPBoost vs Baselines",
    subtitle = "5-Fold cross-validation error rates",
    x = "Prediction Error (RMSE)",
    y = "Algorithm"
  )


ggsave("./benchmark/benchmark_results_gpboost.png", plot = p, width = 10, height = 6)
