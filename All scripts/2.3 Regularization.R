########
# 
# Supervised Learning III - Regularization (LASSO, Ridge, Elastic Net)
#
# Simon Grund Sorensen, Jakob Skou Pedersen, Søren Besenbacher, Farhad Zamani
# Aarhus University
# 
########

################################################################################
#### PART 1: Setup and Model Definition ####
################################################################################

################################################################################
#### SECTION 1: Introduction to Regularization ####
################################################################################

# WHAT IS REGULARIZATION?
# Regular logistic regression can overfit by giving too much weight to variables.
# Regularization adds a "penalty" for large coefficients, encouraging simpler models.
#
# THREE TYPES:
# 1. LASSO (L1): Can shrink coefficients to exactly zero (feature selection!)
#    - mixture = 1
# 2. RIDGE (L2): Shrinks coefficients but never to zero
#    - mixture = 0  
# 3. ELASTIC NET: Combination of LASSO and Ridge
#    - mixture = 0 to 1
#
# PENALTY parameter (λ): Controls strength of regularization
# - λ = 0: No regularization (regular logistic regression)
# - λ large: Strong regularization (simpler model, fewer features)

## Load libraries
library(tidyverse)   # Data manipulation and visualization
library(tidymodels)  # Modeling framework
library(skimr)       # Data summaries
library(vip)         # Variable importance plots

tidymodels_prefer()

################################################################################
#### SECTION 2: Load and Prepare Data ####
################################################################################

chd_full <- read_rds("Data/chd_full.rds")
skim(chd_full)

################################################################################
#### SECTION 3: Train-Test Split and Cross-Validation ####
################################################################################

set.seed(222)

# Split data with stratification:
# Replace ? with 'chdfate'
chd_split <- initial_split(chd_full, prop = 3/4, strata = ?)

# EXERCISE A: Create train and test sets
chd_train <- training(chd_split)
chd_test <- testing(chd_split)  # Replace ? with 'chd_split'

# EXERCISE B: Create cross-validation folds for tuning
set.seed(345)
cv_folds <- vfold_cv(chd_train, v = 10)
cv_folds

################################################################################
#### SECTION 4: Preprocessing Recipe ####
################################################################################

# Same recipe as before, but now centering/scaling is CRITICAL for regularization!
# Why? Regularization penalizes large coefficients. Variables with larger scales
# would be penalized more without standardization.

chd_rec <- 
  recipe(chdfate ~ ., data = chd_train) %>%
  update_role(id, new_role = "ID") %>%
  step_naomit(all_predictors(), all_outcomes()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors()) %>%
  step_center(all_numeric_predictors()) %>%  # Essential for regularization!
  step_scale(all_numeric_predictors())       # Essential for regularization!

chd_rec

################################################################################
#### SECTION 5: LASSO Regression with Tuning ####
################################################################################

# Define a LASSO model with tunable penalty:
# - penalty = tune(): We'll test many penalty values
# - mixture = 1: Pure LASSO (0 = Ridge, 0.5 = Elastic Net)
lasso_model <- 
  logistic_reg(penalty = tune(), mixture = 1) %>% 
  set_engine("glmnet")  # glmnet is fast for regularized models

# Create workflow:
lasso_workflow <- 
  workflow() %>%
  add_model(lasso_model) %>%
  add_recipe(chd_rec)

################################################################################
#### PART 2: Hyperparameter Tuning ####
################################################################################

################################################################################
#### SECTION 6: Creating a Grid of Penalty Values ####
################################################################################

# Create 50 penalty values to test (from very small to very large):
penalty_grid <- grid_regular(penalty(), levels = 50)

# View the grid:
print(penalty_grid, n = 50)

# Visualize the penalty values (logarithmic scale):
plot(penalty_grid$penalty, main = "Penalty Values to Test", 
     ylab = "Penalty", xlab = "Index")

################################################################################
#### SECTION 7: Hyperparameter Tuning with Cross-Validation ####
################################################################################

# Fit the model with EVERY penalty value, using cross-validation:
# This trains 50 penalty values × 10 folds = 500 models!
lasso_tuning_results <- 
  lasso_workflow %>% 
  tune_grid(cv_folds,
            grid = penalty_grid,
            control = control_grid(save_pred = TRUE))

lasso_tuning_results

# EXERCISE A: Examine the tuning results
# Use collect_metrics() to see performance for each penalty value
# First, check the help:
?collect_metrics

# Now collect and view metrics:
tuning_metrics <- lasso_tuning_results %>% 
  collect_metrics()

tuning_metrics


################################################################################
#### SECTION 8: Visualizing the Penalty-Performance Trade-off ####
################################################################################

# EXERCISE B: Plot how AUC changes with penalty
# Let's break down each line to understand what it does:

penalty_plot <- 
  lasso_tuning_results %>% 
  collect_metrics() %>%              # Get all metrics
  filter(.metric == "roc_auc") %>%   # Keep only AUC (not accuracy)
  ggplot(aes(x = penalty, y = mean)) +  # Plot penalty vs mean AUC
  geom_point() +                     # Add points for each penalty value
  geom_line() +                      # Connect points with a line
  ylab("Area under the ROC Curve") +
  scale_x_log10(labels = scales::label_number()) +  # Log scale for x-axis
  geom_vline(xintercept = 0.01, linetype = "dashed", color = "red") +
  labs(title = "Model Performance vs Regularization Penalty")

penalty_plot

# EXERCISE C: Interpret the plot
# As penalty increases (moving right):
# - What happens to model performance initially?
# - What happens when penalty gets too large?
# - Why does this happen?
#
# Hint: Large penalty → more coefficients shrink to zero → simpler model
# Your observations:
# 

################################################################################
#### SECTION 9: Selecting the Best Model ####
################################################################################

# We've trained many models. Now we need to pick the best one!

# View the top 15 models:
top_15_models <-
  lasso_tuning_results %>% 
  show_best("roc_auc", n = 15) %>% 
  arrange(penalty)

top_15_models

# Select THE best model:
best_penalty <- lasso_tuning_results %>%
  select_best("roc_auc")

best_penalty

# EXERCISE D: Understand the difference
# - show_best(n): Returns a table of the top n models
# - select_best(): Returns only the single best model (as a 1-row tibble)
#
# Try running show_best with n = 1 and compare to select_best():
lasso_tuning_results %>% show_best("roc_auc", n = 1)

# They're similar, but select_best() is designed for the next step...

# - How does the best penalty compare to the extremes?
# - What happens to AUC with very small or very large penalties?


################################################################################
#### PART 3: Final Model and Evaluation ####
################################################################################

################################################################################
#### SECTION 10: Finalizing the Model with Best Penalty ####
################################################################################

# "Finalize" the workflow by inserting the best penalty value:
final_workflow <-
  lasso_workflow %>% 
  finalize_workflow(best_penalty)

# Now train on full training set and evaluate on test set:
final_fit <- 
  final_workflow %>%
  last_fit(chd_split)  # Automatically trains on train, tests on test

final_fit

################################################################################
#### SECTION 11: Evaluate Final Model Performance ####
################################################################################

# EXERCISE E: Collect metrics from the final model
# Replace ? with 'collect_metrics'
final_fit %>%
  collect_metrics()

# These are the final test set performance metrics!

# EXERCISE F: Plot the ROC curve
# Replace ? with 'autoplot'
final_fit %>%
  collect_predictions() %>% 
  roc_curve(chdfate, .pred_TRUE) %>% 
  autoplot()

################################################################################
#### SECTION 12: Understanding Variable Importance ####
################################################################################

# EXERCISE G: Which variables matter most?

# View coefficients:
final_coefficients <- final_fit %>% 
  extract_fit_parsnip() %>% 
  tidy()

final_coefficients

# Notice: Some coefficients are exactly ZERO!
# LASSO performed automatic feature selection!

# Visualize variable importance:
final_fit %>% 
  extract_fit_parsnip() %>% 
  vip(lambda = as.numeric(best_penalty[1, 1])) +
  labs(title = "Variable Importance in LASSO Model")

# REFLECTION QUESTIONS:
# 1. Which variables have the largest absolute coefficients?
# 2. Which variables were shrunk to zero (excluded)?
# 3. Do the important variables make biological sense?
# 4. Would you exclude any variables and re-run?
# Your thoughts:
# 

################################################################################
#### SECTION 13: Bonus - Exploring Other Regularization Types ####
################################################################################

# BONUS EXERCISE: Try different regularization methods!

# Ridge Regression (mixture = 0):
# - Shrinks coefficients but never to exactly zero
# - Good when all variables are potentially relevant
# ridge_model <- logistic_reg(penalty = tune(), mixture = 0) %>% set_engine("glmnet")

# Elastic Net (mixture = 0.5):
# - Compromise between LASSO and Ridge
# - Often works well in practice
# elastic_model <- logistic_reg(penalty = tune(), mixture = 0.5) %>% set_engine("glmnet")

# Try repeating the analysis with mixture = 0 or mixture = 0.5!
# How do the results compare?

################################################################################
#### KEY TAKEAWAYS ####
################################################################################

# 1. Regularization prevents overfitting by penalizing large coefficients
# 2. LASSO (L1) can shrink coefficients to exactly zero (feature selection)
# 3. Ridge (L2) shrinks all coefficients but keeps all features
# 4. Elastic Net combines benefits of both
# 5. Penalty strength (λ) must be tuned using cross-validation
# 6. Always standardize features before regularization!
# 7. Variable importance plots help interpret which features matter most

# NEXT: We'll explore Random Forests - a very different approach!
