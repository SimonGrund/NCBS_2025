########
# 
# Supervised Learning IV - Random Forest
# 
# Simon Grund Sorensen, Jakob Skou Pedersen, Søren Besenbacher, Farhad Zamani
# Aarhus University
# 
########

################################################################################
#### PART 1: Setup and Building Model ####
################################################################################

################################################################################
#### SECTION 1: Introduction to Random Forests ####
################################################################################

# WHAT IS A RANDOM FOREST?
# A "forest" of many decision trees that vote on the final prediction.
# 
# HOW IT WORKS:
# 1. Build many decision trees (e.g., 2000 trees)
# 2. Each tree sees a random subset of data and features
# 3. Each tree makes a prediction
# 4. Final prediction = majority vote (classification) or average (regression)
#
# ADVANTAGES:
# - Handles non-linear relationships naturally
# - Resistant to overfitting (when enough trees)
# - Works well out-of-the-box (less tuning needed)
# - Provides feature importance measures
#
# DISADVANTAGES:
# - Less interpretable than linear models
# - Can be slow to train on large datasets
# - May not extrapolate well outside training range

## Load libraries
library(tidyverse)   # Data manipulation and visualization
library(tidymodels)  # Modeling framework
library(skimr)       # Data summaries
library(ranger)      # Fast Random Forest implementation
library(vip)         # Variable importance plots

tidymodels_prefer()

################################################################################
#### SECTION 2: Load Data ####
################################################################################

chd_full <- read_rds("Data/chd_full.rds")

################################################################################
#### SECTION 3: Data Preprocessing ####
################################################################################

# Random Forests are less sensitive to scaling than linear models!
# They work directly with the raw data structure.
# 
# However, we still need to:
# 1. Remove missing values (random forests can't handle NAs in ranger)
# 2. Keep categorical variables as factors (RF handles them naturally)

# Remove rows with missing values:
chd_full_complete <- chd_full[complete.cases(chd_full), ]

# Check how many rows we kept:
cat("Original rows:", nrow(chd_full), "\n")
cat("Complete rows:", nrow(chd_full_complete), "\n")

################################################################################
#### SECTION 4: Train-Test Split ####
################################################################################

set.seed(222)
chd_split <- initial_split(chd_full_complete, prop = 3/4, strata = chdfate)

chd_train <- training(chd_split)
chd_test <- testing(chd_split)

# Verify class balance:
chd_train %>% count(chdfate) %>% mutate(prop = n/sum(n))
chd_test %>% count(chdfate) %>% mutate(prop = n/sum(n))

################################################################################
#### SECTION 5: Building a Random Forest Model ####
################################################################################

# KEY HYPERPARAMETERS:
# - trees: Number of trees in the forest (more = better, but slower)
# - mtry: Number of features randomly selected at each split
#         (default ≈ sqrt(n_features) for classification)

# Define the random forest model:
rf_model <- 
  rand_forest(
    trees = 2000,           # Build 2000 trees
    mtry = 5,               # Try 5 random features at each split
    mode = "classification" # For binary classification
  ) %>%
  set_engine("ranger", seed = 63233)  # Use ranger engine with fixed seed

# Fit the model:
# We exclude 'id' (not a predictor) and 'followup' (time variable, not relevant here)
rf_fit <- rf_model %>% 
  fit(chdfate ~ . - id - followup, data = chd_train)

rf_fit

# UNDERSTANDING THE OUTPUT:
# The ranger output shows:
# - Type of random forest (Classification)
# - Number of trees: 2000
# - Mtry: 5 (number of variables tried at each split)
# - OOB prediction error: Error estimated on "out-of-bag" samples
#   (data not used to build each tree - like built-in cross-validation!)

# Random Forests are "black boxes" - hard to interpret individual predictions.
# Let's evaluate performance to understand how well it works.

################################################################################
#### PART 2: Evaluation and Comparison ####
################################################################################

################################################################################
#### SECTION 6: Making Predictions and Evaluating Performance ####
################################################################################

# Add predictions to test data:
chd_test_predictions <- augment(rf_fit, new_data = chd_test)

glimpse(chd_test_predictions)

################################################################################
#### SECTION 7: ROC Curve and AUC ####
################################################################################

# Plot ROC curve:
rf_roc <- chd_test_predictions %>% 
  roc_curve(truth = chdfate, .pred_TRUE)

autoplot(rf_roc) +
  labs(title = "ROC Curve - Random Forest")

# Calculate AUC:
rf_auc <- chd_test_predictions %>% 
  roc_auc(truth = chdfate, .pred_TRUE)

rf_auc

################################################################################
#### SECTION 8: Additional Classification Metrics ####
################################################################################

# Beyond AUC, we can evaluate:
# - Accuracy: Proportion of correct predictions
# - MCC (Matthews Correlation Coefficient): Balanced measure for imbalanced data
# - F-measure: Harmonic mean of precision and recall

classification_metrics <- metric_set(accuracy, mcc, f_meas)
rf_metrics <- classification_metrics(
  chd_test_predictions, 
  truth = chdfate, 
  estimate = .pred_class, 
  event_level = "second"  # "second" level = TRUE
)

rf_metrics

################################################################################
#### SECTION 9: Comparing Models ####
################################################################################

# EXERCISE A: Compare Random Forest to Logistic Regression

# Previous results (from Module 2.2):
# - Logistic Regression AUC: ~0.796

# Current Random Forest AUC: (see above)

# Questions to consider:
# 1. How did performance change from logistic regression to random forest?
#    - Is AUC higher or lower?
#    - By how much?
#    Your answer:
#    

# 2. Why might it be relevant to try different modeling approaches?
#    Consider:
#    - Different models have different assumptions
#    - Some models better capture non-linear patterns
#    - Performance varies by dataset characteristics
#    - Interpretability vs accuracy trade-offs
#    Your answer:
#    

# - Does the Random Forest outperform logistic regression?
# - When might one model be preferred over the other?


################################################################################
#### PART 3: Advanced Topics ####
################################################################################

################################################################################
#### SECTION 10: Variable Importance (Bonus) ####
################################################################################

# One advantage of Random Forests: built-in variable importance!

# Extract and plot variable importance:
rf_fit %>% 
  extract_fit_engine() %>% 
  vip(num_features = 10) +
  labs(title = "Top 10 Most Important Variables")

# INTERPRETATION:
# - Higher importance = more useful for predictions
# - Importance based on how much each variable improves predictions
# - Compare to LASSO: which variables are important in both models?

################################################################################
#### SECTION 11: Tuning Random Forest (Advanced Bonus) ####
################################################################################

# We used mtry = 5, but is that optimal? We can tune it!

# Create a tuning grid:
rf_tune_model <- 
  rand_forest(trees = 1000, mtry = tune(), mode = "classification") %>%
  set_engine("ranger", seed = 63233)

# Create workflow:
rf_workflow <- workflow() %>% 
  add_formula(chdfate ~ . - id - followup) %>%
  add_model(rf_tune_model)

# Create CV folds:
set.seed(345)
cv_folds <- vfold_cv(chd_train, v = 5)

# Create tuning grid (try different mtry values):
rf_grid <- grid_regular(
  mtry(range = c(2, 8)),  # Try mtry from 2 to 8
  levels = 5
)

# Uncomment to run tuning (may take a few minutes):
# rf_tune_results <- rf_workflow %>%
#   tune_grid(cv_folds, grid = rf_grid)
# 
# # View results:
# rf_tune_results %>% collect_metrics()
# 
# # Select best:
# best_mtry <- rf_tune_results %>% select_best("roc_auc")
# best_mtry

################################################################################
#### KEY TAKEAWAYS ####
################################################################################

# 1. Random Forests build many trees and average their predictions
# 2. They handle non-linear relationships naturally
# 3. Less sensitive to scaling than linear models
# 4. Provide variable importance measures
# 5. Can be tuned (trees, mtry, min_n, etc.)
# 6. Trade interpretability for potentially better performance
# 7. Compare multiple models to find the best approach for your data!

# CONGRATULATIONS! You've completed the supervised learning modules:
# ✓ Linear Regression (Module 2.1)
# ✓ Logistic Regression & Cross-validation (Module 2.2)
# ✓ Regularization (LASSO/Ridge) (Module 2.3)
# ✓ Random Forest (Module 2.4)
#
# You now have a solid foundation in machine learning with R and tidymodels!
