


####---- User Input ----####

## Set local Github repository as working directory
setwd("Single_Cell_Brain_Tumor_Atlas/Post_Processing_H5_ISCVA")
## Load Functions from Customized ISCVAM H5 File
source("Script/Generate_ISCVA_H5.R")

## Desired project name
Project_Name <- "GSE84465_GBM"

## Seurat H5 file
h5_file <- "Input/GSE84465_h5friendly.h5seurat"

## Specify the output folder path
output_folder <- "Output/"




####---- Load Packages ----####
# Define the list of packages to install
packages <- c("dplyr", "Seurat", "rhdf5", "SeuratDisk")
# Load in the necessary packages 
invisible(lapply(packages, library, character.only = TRUE))



####---- Run Script ----####

# Load H5 Seurat Compliant File
seurat_obj <- LoadH5Seurat(h5_file,
                             assays = c("integrated", "RNA"),
                             reductions = c("pca", "tsne", "umap", "rpca"),
                             graphs = NULL,
                             images = NULL,
                             meta.data = TRUE,
                             commands = FALSE,
                             verbose = FALSE)

# Create Seurat.list
seurat.list <- list(all = list(seurat = seurat_obj, covs = seurat_obj@meta.data))

# Convert Seurat.list to H5 File
output_h5_file_name <- file.path(output_folder, paste0(Project_Name,"_ISCVA.h5"))
write.h5(seurat.list = seurat.list, fn = output_h5_file_name)

# Check Dimensions of the H5 File
h5 <- H5Fopen(output_h5_file_name)
h5ls(h5)

# Check Covs in ISCVA Format
colnames(h5$'/artifacts/all/covs')

# Check DiscreteCovs and ContinuousCovs
h5$'/artifacts/all/discreteCovs'
h5$'/artifacts/all/continuousCovs'

# Close the H5 File
h5closeAll()
