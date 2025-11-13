#####
# 
# Clustering in R - K-Means and Hierarchical Clustering
# 
# Simon Grund Sorensen, Jakob Skou Pedersen, Søren Besenbacher, Farhad Zamani
# Aarhus University
# 
#####

################################################################################
#### PART 1: K-Means Clustering ####
################################################################################

################################################################################
#### SECTION 1: Introduction to Clustering ####
################################################################################

# Load required packages
library(tidyverse)  # For data manipulation and visualization
library(ggdendro)   # For pretty dendrograms

# WHAT IS CLUSTERING?
# Clustering groups similar data points together without prior labels.
# It's an "unsupervised" learning method - we don't tell the algorithm
# which group each point belongs to; it discovers patterns on its own.

# Two main approaches:
# 1. K-means: Partition data into K clusters (you choose K)
# 2. Hierarchical: Build a tree showing how points group at different scales

################################################################################
#### SECTION 2: Loading Data with PCA Coordinates ####
################################################################################

# Load the data with PCA coordinates from the previous module:
chd_pca <- read_delim("Data/d_w_pca.tsv")

# Examine the data:
glimpse(chd_pca)

# We'll cluster patients based on their PCA coordinates rather than
# the original variables. This reduces noise and speeds up computation.

################################################################################
#### SECTION 3: K-Means Clustering ####
################################################################################

# K-means divides data into K clusters by:
# 1. Randomly placing K "centers"
# 2. Assigning each point to the nearest center
# 3. Moving centers to the average of their assigned points
# 4. Repeating steps 2-3 until convergence

# First, extract only the PCA columns:
pca_coords <- select(chd_pca, .fittedPC1, .fittedPC2, .fittedPC3, .fittedPC4, .fittedPC5)

# EXERCISE A: Perform k-means clustering with 4 clusters
# Replace the first ? with 'pca_coords' and the second ? with 4
kmeans_result <- kmeans(x = ?, centers = ?)

# See what's in the result:
names(kmeans_result)

# The cluster assignments are in: kmeans_result$cluster

################################################################################
#### SECTION 4: Visualizing K-Means Clusters ####
################################################################################

# Add cluster assignments to our data:
# We convert to factor so ggplot treats it as categorical (for colors)
chd_pca$cluster_kmeans <- as.factor(kmeans_result$cluster)

# EXERCISE B: Plot the clusters in PCA space
# Replace ? with 'cluster_kmeans'
ggplot(chd_pca, aes(x = .fittedPC1, y = .fittedPC2)) +
  geom_point(aes(color = ?), size = 2) +
  labs(title = "K-Means Clustering (K=4)",
       x = "PC1", y = "PC2")

# QUESTION: Try commenting out the as.factor() line above and re-run.
# What happens to the plot colors? Why?


################################################################################
#### SECTION 5: Choosing the Right Number of Clusters ####
################################################################################

# EXERCISE C: Experiment with different numbers of clusters

# Try K = 2:
kmeans_2 <- kmeans(pca_coords, centers = 2)
chd_pca$cluster_2 <- as.factor(kmeans_2$cluster)

ggplot(chd_pca, aes(x = .fittedPC1, y = .fittedPC2)) +
  geom_point(aes(color = cluster_2), size = 2) +
  labs(title = "K-Means with K=2")

# Try K = 6:
kmeans_6 <- kmeans(pca_coords, centers = 6)
chd_pca$cluster_6 <- as.factor(kmeans_6$cluster)

ggplot(chd_pca, aes(x = .fittedPC1, y = .fittedPC2)) +
  geom_point(aes(color = cluster_6), size = 2) +
  labs(title = "K-Means with K=6")

# EXERCISE D: Reflect on cluster numbers
# How many clusters are too many? Too few? What looks most meaningful?
# Consider: Do the clusters correspond to real biological groups?
# Write your answer as a comment below:
# 


################################################################################
#### PART 2: Hierarchical Clustering ####
################################################################################

################################################################################
#### SECTION 6: Hierarchical Clustering ####
################################################################################

# Hierarchical clustering builds a tree (dendrogram) showing how
# samples group together at different levels of similarity.
# Unlike k-means, you don't need to specify the number of clusters upfront!

# Step 1: Create a distance matrix
# This calculates how "different" each patient is from every other patient
distance_matrix <- dist(pca_coords)

# Step 2: Perform hierarchical clustering
# This builds the tree structure
hclust_result <- hclust(d = distance_matrix)

# View summary:
hclust_result

################################################################################
#### SECTION 7: Visualizing Hierarchical Clusters ####
################################################################################

# Create a dendrogram (tree diagram):
ggdendrogram(hclust_result) +
  labs(title = "Hierarchical Clustering Dendrogram")

# INTERPRETING THE DENDROGRAM:
# - The y-axis shows the distance at which clusters merge
# - Each leaf (bottom) is one patient
# - Height of branches shows how similar clusters are
# - Cutting the tree at different heights gives different numbers of clusters

################################################################################
#### SECTION 8: Cutting the Dendrogram ####
################################################################################

# We can "cut" the tree at different heights to get clusters:

# Cut at height 11 (few, large clusters):
clusters_h11 <- cutree(hclust_result, h = 11)
table(clusters_h11)  # How many patients in each cluster?

# Cut at height 7.5:
clusters_h7.5 <- cutree(hclust_result, h = 7.5)
table(clusters_h7.5)

# Cut at height 5 (many, small clusters):
clusters_h5 <- cutree(hclust_result, h = 5)
table(clusters_h5)

# EXERCISE: Add cutlines to the dendrogram to visualize different cuts
ggdendrogram(hclust_result) +
  geom_hline(yintercept = 11, linetype = "dashed", color = "red") +
  geom_hline(yintercept = 7.5, linetype = "dashed", color = "blue") +
  geom_hline(yintercept = 5, linetype = "dashed", color = "green") +
  labs(title = "Dendrogram with Cut Heights")

# QUESTION: What is a good place to cut the tree? Why?
# Consider: Which height gives meaningful, interpretable groups?
# 


################################################################################
#### SECTION 9: Comparing Methods ####
################################################################################

# Let's compare k-means and hierarchical clustering:
chd_pca$cluster_hclust <- as.factor(cutree(hclust_result, k = 4))

# Plot both side by side:
library(patchwork)  # For combining plots

p1 <- ggplot(chd_pca, aes(.fittedPC1, .fittedPC2, color = cluster_kmeans)) +
  geom_point() + labs(title = "K-Means (K=4)")

p2 <- ggplot(chd_pca, aes(.fittedPC1, .fittedPC2, color = cluster_hclust)) +
  geom_point() + labs(title = "Hierarchical (K=4)")

p1 + p2

################################################################################
#### KEY TAKEAWAYS ####
################################################################################

# K-Means:
# - Fast and simple
# - Need to specify K upfront
# - Sensitive to initial random placement
# - Works well for spherical clusters

# Hierarchical:
# - No need to specify K upfront
# - Shows relationships at multiple scales
# - Slower for large datasets
# - Creates a tree structure you can explore

# Choosing between them:
# - Try both and compare results!
# - K-means for large datasets or when you know K
# - Hierarchical for exploring structure or when K is unknown
