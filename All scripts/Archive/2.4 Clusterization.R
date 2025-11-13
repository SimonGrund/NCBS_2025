# Install dependencies ----------------------------------------------------
# install.packages('ape')
# install.packages('pheatmap')
# install.packages('tidyverse')


# Load Libraries ----------------------------------------------------------

library(cluster)
library(pheatmap)
library(ape)
library(tidyverse)


# Import and Analyze Distance matrix -------------------------------------------------------------------------


distance <- read.table('Data/dist.tabular', header=T, sep="\t", row.names = 1)
rownames(distance)<-str_remove_all(rownames(distance),'.vcf')
colnames(distance)<-str_remove_all(colnames(distance),'.vcf')

# Visualize Distance matrix

pheatmap::pheatmap(distance,breaks = seq(0,50,length.out=101),
                   color = colorRampPalette(c('red','yellow','white'))(100),
                   display_numbers = T,
                   number_format = '%i',
                   show_colnames = F)
distance <- as.dist(distance)

# Perform clustering based on SNP distances and a SNP threshold of 10 (h=10)
clusters <- agnes(distance, diss = TRUE, method = "average")

clusters <- as.data.frame(cutree(as.hclust(clusters), h = 10))
colnames(clusters) <- "cluster_id"


# Get cluster_ids

clusters %>% 
  rownames_to_column('sample') %>% 
  group_by(cluster_id) %>% 
  filter(n()>1)->Cluster_tab



# Phylogeny ---------------------------------------------------------------



## Load Tree
ape::read.tree('Data/tree.nhx')->tree

plot(tree)


## Root tree


tree_rooted <- root(tree, "ERR313115")
# Remove the outgroup to make distances within MTB clearer
tree_rooted <- drop.tip(tree_rooted, "ERR313115")
tree_rooted$root.edge <- 0.005
plot(tree_rooted, root.edge = T, cex=0.6)

# Assign clusters

### Clusters

clusters %>% 
  rownames_to_column('sample') %>%
  group_by(cluster_id) %>% 
  mutate(clusters=ifelse(n()>1,as.character(cluster_id),'unclustered'),
         sample=str_remove(sample,'.vcf')) %>% 
  pull(clusters,name = 'sample')->mtbc_cluster


tree_cl <- tree_rooted



clusters %>% 
  rownames_to_column('sample') %>%
  group_by(cluster_id) %>% 
  mutate(cluster_c=ifelse(n()>1,'#ff0000','#000000'),
         clusters=ifelse(n()>1,as.character(cluster_id),'unclustered'),
         sample=str_remove(sample,'.vcf')) %>% 
  ungroup() %>% 
  select(cluster_c,clusters) %>% distinct() %>% 
  pull(cluster_c,name = 'clusters')->mtbc_cl_color




tree_cl$tip.label <- mtbc_cluster[tree_rooted$tip.label]

pal_cl <- as.character(mtbc_cl_color[tree_cl$tip.label])

par(mfrow = c(1, 2))
plot(tree_rooted,cex = 0.7, root.edge = TRUE)
plot(tree_cl,cex = 0.7, root.edge = TRUE,tip.color=pal_cl)



# Assign lineages to samples, as identified by TB-profiler

mtbc_lineages <- c(
  "ERR181435" = "L7",
  "ERR313115" = "canettii",
  "ERR551620" = "L5",
  "ERR1203059" = "L5",
  "ERR2659153" = "orygis",
  "ERR2704678" = "L3",
  "ERR2704679" = "L1",
  "ERR2704687" = "L6",
  "ERR5987300" = "L2",
  "ERR5987352" = "L4",
  "ERR6362078" = "L2",
  "ERR6362138" = "L2",
  "ERR6362139" = "L4",
  "ERR6362156" = "L2",
  "ERR6362253" = "L2",
  "ERR6362333" = "L2",
  "ERR6362484" = "L4",
  "ERR6362653" = "L2",
  "SRR998584" = "L5",
  "SRR13046689" = "bovis"
)

# Replace the tree labels
tree_lineages <- tree_rooted
tree_lineages$tip.label <- as.character(mtbc_lineages[tree_rooted$tip.label])

# Define some colors for the lineages

color_code_lineages = c(
  L1 = "#ff00ff",
  L2 = "#0000ff",
  L3 = "#a000cc",
  L4 = "#ff0000",
  L5 = "#663200",
  L6 = "#00cc33",
  L7 = "#ede72e",
  bovis="black",
  orygis="black")

pal_lineages <- as.character(color_code_lineages[tree_lineages$tip.label])

# Plot the old and new tree version next to each other
par(mfrow = c(1, 2))
plot(tree_rooted,cex = 0.7, root.edge = TRUE)
plot(tree_lineages,cex = 0.8, tip.color = pal_lineages, root.edge = TRUE)


# Same as before, but with DR profiles instead of lineages

mtbc_dr <- c(
  "ERR181435" = "Sensitive",
  "ERR313115" = "Sensitive",
  "ERR551620" = "MDR",
  "ERR1203059" = "Sensitive",
  "ERR2659153" = "Sensitive",
  "ERR2704678" = "Sensitive",
  "ERR2704679" = "Sensitive",
  "ERR2704687" = "Sensitive",
  "ERR5987300" = "PreXDR",
  "ERR5987352" = "PreMDR",
  "ERR6362078" = "MDR",
  "ERR6362138" = "MDR",
  "ERR6362139" = "PreMDR",
  "ERR6362156" = "PreXDR",
  "ERR6362253" = "MDR",
  "ERR6362333" = "PreXDR",
  "ERR6362484" = "PreMDR",
  "ERR6362653" = "MDR",
  "SRR998584" = "Sensitive",
  "SRR13046689" = "Other"
)


tree_dr <- tree_rooted
tree_dr$tip.label <- as.character(mtbc_dr[tree_rooted$tip.label])

color_code_dr = c(
  Sensitive = "#ff00ff",
  PreXDR = "#0000ff",
  PreMDR = "#a000cc",
  MDR = "#ff0000",
  Other = "#663200"
)

pal_dr <- as.character(color_code_dr[tree_dr$tip.label])

par(mfrow = c(1, 2))
plot(tree_lineages,cex = 0.7, root.edge = TRUE)
plot(tree_dr,cex = 0.8, tip.color = pal_dr, root.edge = TRUE)


## DATE phylogeny


#phylogenetic_distance / rate = time



# Rescale branch lengths (here called edge lenghts)
genome_size = 4411532
alignment_length = 18077
invariant_sites = genome_size - alignment_length

tree_rescaled <- tree_rooted
tree_rescaled$edge.length <- ((tree_rescaled$edge.length * alignment_length) / genome_size )
tree_rescaled$root.edge <- ((tree_rescaled$root.edge * alignment_length) / genome_size )

par(mfrow = c(1, 2))
plot(tree_rooted,cex = 0.7, root.edge = T, main = "original")
axisPhylo()
plot(tree_rescaled,cex = 0.7,root.edge = T, main = "rescaled")
axisPhylo()
dev.off()



# Let's also remove the two outlier strains, they would cause troubles and are anyway useless
tree_rescaled <- drop.tip(tree_rescaled, c("ERR1203059", "ERR5987300"))

# Estimate dates: translate phylogenetic distance into years by assuming a mutation rate and the number of generations per year
mutation_rate = 2.01e-10
generations_per_year = 200

## Ape has a function, estimate.dates(), to date a tree by assuming a specific mutation rate
node.date <- estimate.dates(
  tree_rescaled,
  node.dates = rep(0, length(tree_rescaled$tip.label)), # set sampling dates to 0
  mu = (mutation_rate * generations_per_year) # mutation rate per year
)

tree_rescaled$edge.length <- node.date[tree_rescaled$edge[, 2]] - node.date[tree_rescaled$edge[, 1]]
tree_rescaled$tip.label <- as.character(mtbc_lineages[tree_rescaled$tip.label])


par(mfrow = c(1, 1))
plot(tree_rescaled, cex = 0.6, main = "Dated phylogeny (years)")
axisPhylo()

