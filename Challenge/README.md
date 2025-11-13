# Welcome to the Prediction Challenge of the AIBBC 2025 Bioinformatics and Genomics Workshop!

Welcome to the **prediction challenge**!  
This competition explores how well machine learning models can classify biological samples based on **gene expression data** from The Cancer Genome Atlas (TCGA).


---

## Goal of the Challenge

You will build predictive models for two related tasks:

1. **Main task: Tumor vs. Normal Classification**  
   Predict whether a sample originates from tumor tissue or healthy (normal) tissue.

2. **Secondary task: Tissue Type Prediction**  
   Identify the main tissue of origin (e.g. lung, breast, liver, etc.) from gene expression data.

Your model’s success will be measured primarily by its **accuracy score**, which reflects how well your model performance on prediction.

Through this challenge you will use the knowledge gained during the course into practice!


---

## Dataset Overview

- **Source:** TCGA (The Cancer Genome Atlas)  
- **Type:** RNA-seq gene expression (raw counts)  
- **Samples:** Multiple human tissues, both normal and tumor  
- **Features:** Expression levels of thousands of genes per sample  
- **Labels:**
  - `response` = Tumor or Normal  
  - `tissue` = Tissue type (categorical)

Data are split into:
- **`tcga_train.rds`** — contains both features and target labels  
- **`tcga_test.rds`** — contains only features (for your predictions)

---

## Getting started

Go to `Prediction Challenge.Rmd` and start immediately!

---

## Submission

Submission examples are provided in this folder: `challenge_response.team_aarhus.rds` and `challenge_tissue.team_aarhus.rds`

Google Drive to load your submission will be informed during workshop.