# Quick Reference Guide - NCBS 2025 Course Modules

## 📚 Module Overview & Key Concepts

### **Day 1: Data Science Foundations**

#### **1.1 - Data Visualization I** (Beginner)

**Time:** ~60-90 min  
**Key Concepts:**

- Basic R programming (variables, data.frames)
- ggplot2 fundamentals
- Aesthetics (aes) vs fixed parameters
- Geoms: histogram, scatter, smooth

**Module Parts:**

- **PART 1:** R Programming Basics - Variables, data frames, and R fundamentals
- **PART 2:** ggplot2 Introduction - Grammar of graphics and basic visualizations

**Key Functions:**

```r
ggplot(data, aes(x, y))
geom_point(), geom_histogram(), geom_smooth()
```

---

#### **1.2.1 - Importing Data** (Beginner)

**Time:** ~30-45 min  
**Key Concepts:**

- File formats (.rds, .csv, .tsv, .xlsx)
- Data type conversion
- glimpse() vs skim()
- Exporting data

**Module Parts:**

- **PART 1:** Reading Data - Loading files from various formats
- **PART 2:** Data Type Conversion and Exporting - Converting types and saving data

**Key Functions:**

```r
read_rds(), read_csv(), read_delim(), read_excel()
write_table(), write_csv(), write_rds()
glimpse(), skim()
```

---

#### **1.2.2 - Data Wrangling** (Beginner-Intermediate)

**Time:** ~90-120 min  
**Key Concepts:**

- Filter rows, select columns
- Group and summarize
- Create new variables (mutate)
- Handle missing values (NA)
- Pipe operator (%>%)

**Module Parts:**

- **PART 1:** Basic Wrangling - Filter, select, mutate, and pipe basics
- **PART 2:** Advanced Operations - Grouping, summarizing, and complex transformations

**Key Functions:**

```r
filter(), select(), mutate(), group_by(), summarise()
slice_max(), slice_min()
```

---

#### **1.2.3 - Visualization II** (Intermediate)

**Time:** ~90-120 min  
**Key Concepts:**

- Advanced plot types (box, violin, bar)
- Color scales (continuous vs discrete)
- Faceting (small multiples)
- Saving plots
- Customizing labels and themes

**Module Parts:**

- **PART 1:** Advanced Plot Types - Box, violin, and bar plots
- **PART 2:** Customization - Colors, themes, and labels
- **PART 3:** Faceting - Small multiples for grouped comparisons
- **PART 4:** Advanced Topics and Exporting - Proportions and saving plots

**Key Functions:**

```r
geom_boxplot(), geom_violin(), geom_bar()
facet_wrap(), facet_grid()
scale_color_viridis_c(), scale_colour_brewer()
ggsave()
```

---

#### **1.3 - Dimension Reduction** (Intermediate-Advanced)

**Time:** ~90-120 min  
**Key Concepts:**

- Why dimension reduction?
- PCA (linear method)
- t-SNE (non-linear method)
- Variance explained
- Choosing between methods

**Module Parts:**

- **PART 1:** Principal Component Analysis (PCA) - Linear dimension reduction and interpretation
- **PART 2:** t-SNE (Non-Linear Dimension Reduction) - Non-linear methods for complex patterns

**Key Functions:**

```r
prcomp()
Rtsne()
augment()
```

**When to Use:**

- **PCA:** Linear relationships, interpretability, speed
- **t-SNE:** Finding clusters, complex patterns, visualization

---

#### **1.4 - Clustering** (Intermediate-Advanced)

**Time:** ~75-90 min  
**Key Concepts:**

- Supervised vs unsupervised learning
- K-means clustering
- Hierarchical clustering
- Dendrograms
- Choosing number of clusters

**Module Parts:**

- **PART 1:** K-Means Clustering - Partition-based clustering and optimization
- **PART 2:** Hierarchical Clustering - Tree-based clustering and dendrograms

**Key Functions:**

```r
kmeans()
hclust(), dist()
cutree()
ggdendrogram()
```

**When to Use:**

- **K-means:** Fast, know K, spherical clusters
- **Hierarchical:** Explore structure, unknown K, small datasets

---

### **Day 2: Machine Learning with Tidymodels**

#### **2.1 - Linear Regression & Tidymodels** (Intermediate)

**Time:** ~90-120 min  
**Key Concepts:**

- Supervised learning
- Train-test split
- Linear regression
- Model evaluation (RMSE, R²)
- Coefficient interpretation

**Module Parts:**

- **PART 1:** Setup and Data Preparation - Loading data, splitting, and EDA
- **PART 2:** Building Models - Creating and fitting linear regression models
- **PART 3:** Testing and Evaluation - Making predictions and assessing performance

**Key Functions:**

```r
initial_split(), training(), testing()
linear_reg() %>% fit()
augment(), tidy()
rmse(), rsq()
```

---

#### **2.2 - Classification & Cross-Validation** (Intermediate-Advanced)

**Time:** ~120-150 min  
**Key Concepts:**

- Classification vs regression
- Logistic regression
- Recipes and workflows
- ROC curves and AUC
- Cross-validation
- Stratification

**Module Parts:**

- **PART 1:** Data Preparation - Stratified splits and preprocessing recipes
- **PART 2:** Model Building and Training - Logistic regression with workflows
- **PART 3:** Model Evaluation - ROC curves, AUC, and confusion matrices
- **PART 4:** Cross-Validation - K-fold CV for robust performance estimates

**Key Functions:**

```r
recipe(), prep(), bake()
workflow()
logistic_reg()
vfold_cv()
roc_curve(), roc_auc(), autoplot()
fit_resamples()
```

**Metrics:**

- **AUC:** 0.5 (random) to 1.0 (perfect)
- **Accuracy:** Simple but can mislead with imbalanced data

---

#### **2.3 - Regularization** (Advanced)

**Time:** ~120-150 min  
**Key Concepts:**

- Overfitting prevention
- LASSO (L1) - feature selection
- Ridge (L2) - shrinkage
- Elastic Net - combination
- Hyperparameter tuning
- Variable importance

**Module Parts:**

- **PART 1:** Setup and Model Definition - Introduction to regularization and LASSO setup
- **PART 2:** Hyperparameter Tuning - Grid search and cross-validation for penalty selection
- **PART 3:** Final Model and Evaluation - Finalizing the best model and interpretation

**Key Functions:**

```r
logistic_reg(penalty = tune(), mixture = ?)
tune_grid()
select_best(), show_best()
finalize_workflow()
vip()
```

**Mixture Values:**

- **1:** LASSO (feature selection)
- **0:** Ridge (all features)
- **0-1:** Elastic Net (compromise)

---

#### **2.4 - Random Forest** (Advanced)

**Time:** ~90-120 min  
**Key Concepts:**

- Ensemble methods
- Decision trees
- Out-of-bag error
- Hyperparameters (trees, mtry)
- Variable importance
- Comparing models

**Module Parts:**

- **PART 1:** Setup and Building Model - Random forest fundamentals and model creation
- **PART 2:** Evaluation and Comparison - Performance metrics and comparison with other models
- **PART 3:** Advanced Topics - Variable importance and hyperparameter tuning

**Key Functions:**

```r
rand_forest(trees, mtry, mode)
set_engine("ranger")
extract_fit_engine()
vip()
```

**Hyperparameters:**

- **trees:** More is better (to a point)
- **mtry:** Number of features per split (√p for classification)

---

## 🎯 Quick Decision Guide

### **"Which Visualization Should I Use?"**

- **One continuous variable:** Histogram, density plot
- **Two continuous variables:** Scatter plot
- **One continuous, one categorical:** Box plot, violin plot
- **Two categorical variables:** Bar plot (stacked or grouped)
- **Multiple groups:** Faceting with facet_wrap()

### **"Which Dimension Reduction?"**

- **Want interpretability?** → PCA
- **Want to find clusters?** → t-SNE
- **Linear relationships?** → PCA
- **Complex patterns?** → t-SNE
- **Need speed?** → PCA

### **"Which Clustering Method?"**

- **Know number of clusters?** → K-means
- **Want to explore structure?** → Hierarchical
- **Large dataset?** → K-means
- **Small dataset?** → Hierarchical
- **Spherical clusters?** → K-means

### **"Which ML Model?"**

- **Continuous outcome?** → Linear regression
- **Binary outcome?** → Logistic regression
- **Need interpretability?** → Linear/Logistic regression
- **Many features?** → LASSO/Elastic Net
- **Non-linear patterns?** → Random Forest
- **Feature selection needed?** → LASSO
- **Best accuracy?** → Try multiple, compare

---

## 🔧 Common Tidymodels Workflow

```r
# 1. Split data
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = outcome)
train_data <- training(data_split)
test_data <- testing(data_split)

# 2. Create recipe
data_recipe <- recipe(outcome ~ ., data = train_data) %>%
  step_naomit(all_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_center(all_numeric_predictors()) %>%
  step_scale(all_numeric_predictors())

# 3. Define model
model_spec <- logistic_reg() %>% set_engine("glm")

# 4. Create workflow
model_workflow <- workflow() %>%
  add_recipe(data_recipe) %>%
  add_model(model_spec)

# 5. Fit model
model_fit <- model_workflow %>% fit(data = train_data)

# 6. Make predictions
predictions <- augment(model_fit, test_data)

# 7. Evaluate
predictions %>% roc_auc(truth = outcome, .pred_TRUE)
```

---

## 💡 Pro Tips

### **General R Tips:**

1. **Use Ctrl/Cmd + Enter** to run code lines
2. **Use View()** to see data in spreadsheet format
3. **Use ?function_name** for help
4. **Save your work frequently**

### **Data Wrangling Tips:**

1. **Always glimpse() first** to understand your data
2. **Handle NAs early** with step_naomit() or na.rm = TRUE
3. **Use descriptive names** for better readability
4. **Comment your code** liberally

### **Modeling Tips:**

1. **Always split train-test** before doing anything
2. **Never test on training data** (will overestimate performance)
3. **Use cross-validation** for hyperparameter tuning
4. **Standardize features** for regularization and comparisons
5. **Try multiple models** and compare
6. **Visualize results** - plots reveal issues numbers hide

### **Debugging Tips:**

1. **Read error messages** carefully (usually helpful!)
2. **Check data types** with glimpse() or str()
3. **Run code line-by-line** to isolate issues
4. **Use print() statements** to check intermediate results
5. **Google the error** - someone else has had it!

---

## 📖 Recommended Resources

### **Books:**

- **R for Data Science** (Hadley Wickham) - [r4ds.hadley.nz](https://r4ds.hadley.nz/)
- **Tidy Modeling with R** - [tmwr.org](https://www.tmwr.org/)

### **Cheat Sheets:**

- ggplot2: [rstudio.com/resources/cheatsheets](https://www.rstudio.com/resources/cheatsheets/)
- dplyr: Same link as above
- tidymodels: Same link as above

### **Online Communities:**

- Stack Overflow: [stackoverflow.com](https://stackoverflow.com/questions/tagged/r)
- RStudio Community: [community.rstudio.com](https://community.rstudio.com/)
- Twitter #rstats

---

## 🆘 Common Errors & Solutions

### **Error: object 'x' not found**

**Solution:** Variable not defined. Check spelling and make sure you ran the line that creates it.

### **Error: could not find function "function_name"**

**Solution:** Package not loaded. Run `library(package_name)` first.

### **Error: unexpected '?' in "code"**

**Solution:** You haven't replaced the `?` placeholder! Fill in the missing code.

### **Warning: Removed X rows containing missing values**

**Solution:** Expected! ggplot drops NAs. Use `na.omit()` or specify `na.rm = TRUE` if needed.

### **Error: Can't subset columns that don't exist**

**Solution:** Column name misspelled or doesn't exist. Check with `names(data)`.

### **Model performance is terrible (AUC ~ 0.5)**

**Solution:**

1. Check if data is loaded correctly
2. Verify train-test split worked
3. Check for data leakage
4. Try different features
5. Check class balance

---

**Happy Coding! 🎉**

Remember: Everyone gets errors. The difference between beginners and experts is that experts know how to debug them!
