# Load required libraries
library(ggtree)
library(ggplot2)
library(tidyverse)
library(readxl)
library(ape)

# ----- Paths (edit to your local copies) -----
data_dir <- "./data"
out_dir  <- "./figures"

# ----- Load Data -----
tree <- ape::read.tree(file.path(data_dir, "WGS-isolate-tree.tre"))

metadata_tree <- read.csv(file.path(data_dir, "metadata_tree_kegg.csv"),
                          header = TRUE, stringsAsFactors = FALSE)
rownames(metadata_tree) <- metadata_tree$isolate_id

pheno_data <- read_excel(file.path(data_dir, "Assay_results.xlsx"))

# ----- Prepare Data -----
pheno_data <- pheno_data %>%
  mutate(isolate_number = as.character(isolate_number))

# Convert to long format
bubble_data <- pheno_data %>%
  select(isolate_number, GTDB_hit_iso_number,
         N_fixing, S_Oxid, S_Red, IAA_production, P_solubility) %>%
  pivot_longer(
    cols = c(N_fixing, S_Oxid, S_Red, IAA_production, P_solubility),
    names_to = "assay",
    values_to = "pheno"
  )

# Define colors and labels
assay_colors <- c(
  "N_fixing" = "#477B95FF",
  "S_Oxid" = "#B87038FF",
  "S_Red" = "#C09848FF",
  "IAA_production" = "#7C778CFF",
  "P_solubility" = "#315B88FF"
)

assay_labels <- c(
  "N_fixing" = "N-Fixation",
  "S_Oxid" = "S-Oxidation",
  "S_Red" = "S-Reduction",
  "IAA_production" = "IAA Production",
  "P_solubility" = "P-Solubilization"
)

bubble_data$assay <- factor(bubble_data$assay,
                            levels = c("N_fixing", "S_Oxid", "S_Red", "IAA_production", "P_solubility"))

# ----- Get Tip Order from Tree -----
p_tree_temp <- ggtree(tree) %<+% metadata_tree
tip_order <- rev(get_taxa_name(p_tree_temp))

# Add y positions based on tree order
bubble_data <- bubble_data %>%
  mutate(y_pos = match(isolate_number, str_extract(tip_order, "\\d+"))) %>%
  filter(!is.na(y_pos))

# ----- Calculate Positions -----
bubble_offset <- 0.5
column_width <- 2.5
circle_radius <- 0.4

bubble_data_h <- bubble_data %>%
  mutate(
    x_offset = as.numeric(assay),
    x_center = bubble_offset + (x_offset - 0.5) * column_width,
    y_center = y_pos
  )

# Background squares for all positions
background_data <- bubble_data_h %>%
  select(x_center, y_center, assay) %>%
  distinct() %>%
  mutate(
    xmin = x_center - circle_radius * 1.2,
    xmax = x_center + circle_radius * 1.2,
    ymin = y_center - circle_radius * 1.2,
    ymax = y_center + circle_radius * 1.2
  )

# Split by phenotype result
bubble_positive <- bubble_data_h %>% filter(pheno == 1)
bubble_negative <- bubble_data_h %>% filter(pheno == 0)

# ----- Create Bubble Plot -----
plot_bubbles_only <- ggplot() +
  # Background squares
  geom_rect(data = background_data,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = "#F5F5F5", color = "#E0E0E0", linewidth = 0.1) +
  # Filled circles for positive phenotype
  geom_point(data = bubble_positive,
             aes(x = x_center, y = y_center, fill = assay),
             shape = 21, size = 3.7, color = "black", stroke = 0.25) +
  # Empty circles for negative phenotype
  geom_point(data = bubble_negative,
             aes(x = x_center, y = y_center),
             shape = 21, size = 3.7, fill = "white", color = "#E0E0E0", stroke = 0.25) +
  # Color scale
  scale_fill_manual(values = assay_colors, name = "Trait", labels = assay_labels) +
  # Column labels
  annotate("text",
           x = bubble_offset + (1:5 - 0.5) * column_width,
           y = max(bubble_data_h$y_pos) + 2,
           label = assay_labels,
           angle = 45, hjust = 0, vjust = 0.5, size = 3.5, fontface = "bold") +
  coord_fixed(ratio = 1,
              xlim = c(0, bubble_offset + 5 * column_width + 0.5),
              ylim = c(0, max(bubble_data_h$y_pos) + 3)) +
  labs(
    title = "Phenotypic Assay Results for Plant Growth-Promoting Traits",
    subtitle = "n=61 isolates",
    caption = expression(paste(bold("\u25CF"), " Positive assay result | ", bold("\u25CB"), " Negative assay result"))
  ) +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

print(plot_bubbles_only)

# Save bubble plot
ggsave(file.path(out_dir, "phenotype_bubbles_only.svg"),
       plot_bubbles_only,
       width = 8, height = 10, dpi = 300, bg = "white")

# Save tree separately
plot_tree_only <- ggtree(tree) %<+% metadata_tree +
  geom_tiplab(aes(label = sprintf("%s_%s", species, Isolate_number)),
              size = 2.5,
              hjust = 0) +
  theme_tree2()

ggsave(file.path(out_dir, "phylo_tree_only.svg"),
       plot_tree_only,
       width = 10, height = 10, dpi = 300, bg = "white")
