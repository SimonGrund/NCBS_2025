########
# 
# Analysis of bulk RNA seq data using DESeq2
#
# Simon Grund Sorensen, Jakob Skou Pedersen, Søren Besenbacher, Farhad Zamani
# Aarhus University
# 
#######

### Some packages are made to improve and simplify the analysis of RNA seq
### Here we will try the most poopular one: DESeq2
library(DESeq2) 
library(tidyverse)
library(data.table)
library(tidymodels)

#Load the data
d <- fread("Data/RNA_seq_counts.gtf")

# Again we do some filtering, copying the data from 3_1_1
# Let's focus on genes that have an expression in at least 25% of the samples:
# Reformat to long format and count the number of samples that had any expression of each gene
Summary_d = pivot_longer(d, cols = -gene_id)%>%
  group_by(gene_id)%>%
  mutate(n_above_0 = sum(value > 0))%>%
  distinct(gene_id, n_above_0)

genes_to_include = filter(Summary_d, n_above_0 > 0.25*ncol(d))$gene_id
d = filter(d, gene_id %in% genes_to_include)

# To save space, we will subset down to a random set of 200 genes
set.seed(139)
d <- slice_sample(d, n = 200)

# DESeq2 needs three informations:
# 1. countData: Counts in matrix format
# 2. colData: Metainformation about the samples (columns) in countData
# 3. Design: Which column in colData to use for separating samples

# Format the countmatrix
row.names(d) = d$gene_id
d$gene_id = NULL # Remove the column from d
countData = as.matrix(d) # Convert the counts to a matrix

# Format the colData
colData = fread("Data/Metadata.tsv")

# Make sure that the order of rows matches the order of columns in the counts
colData <- colData[match(colnames(d), colData$ID), ]  

# DESeq2 (like many other softwares) doesn't like spaces,
# so let's substitude spaces in the diagnosis column with "_"
colData$diagnosis = str_replace_all(colData$diagnosis, pattern = " ", replacement = "_")

# And convert to factor to avoid any misunderstanding under the hood of DESeq2
colData$diagnosis = as.factor(colData$diagnosis)

dds <- DESeqDataSetFromMatrix(countData = countData,
                              colData = colData,
                              design = ~ diagnosis)


dds

# Lets run it! 
dds <- DESeq(dds)
res <- results(dds)
res 

# Convert to data frame so that we can keep the data tidy
res = as.data.frame(res)
res$gene_id = row.names(d)
res = res %>%
  select(gene_id, everything()) # Reorder the columns so gene_ID cmes first

head(res)


# A) 
# Do we find the same top-hit gene as when we ran the models ourselves in 3_1_1?

