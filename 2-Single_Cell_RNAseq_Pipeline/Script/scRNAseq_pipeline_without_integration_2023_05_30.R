



####---- User Input ----####

## Set local Github repository as working directory
setwd("Single_Cell_Brain_Tumor_Atlas/Single_cell_pipeline")

## Desired project name
Project_Name <- "GSE84465_GBM"

# Define the path to the count file
Count_file <- "Input/GSE84465_GBM_All_data.csv.gz"

# Specify the output folder path
output_folder <- "Output/"






####---- Load Packages ----####

packages <- c("dplyr","Seurat","patchwork","readr","DoubletFinder","celldex","Matrix",
              "fields","SeuratDisk","SeuratData","SingleR","SingleCellExperiment")
invisible(lapply(packages, library, character.only = TRUE))






####---- Run Script ----####

# Read the count file
counts <- read.csv2(Count_file, sep = "", header = TRUE, row.names = 1)

# Define a function for quality control (QC) using Seurat
qc.seurat <- function(seurat, species, nFeature) {
  mt.pattern <- case_when(
    species == "Human" ~ "^MT-",
    species == "Mouse" ~ "^mt-",
    TRUE ~ "^MT-"
  )
  ribo.pattern <- case_when(
    species == "Human" ~ "^RP[LS]",
    species == "Mouse" ~ "^Rp[ls]",
    TRUE ~ "^RP[LS]"
  )
  
  # Calculate percentage of mitochondrial and ribosomal genes
  seurat[["percent.mt"]] <- PercentageFeatureSet(seurat, pattern = mt.pattern, assay = "RNA")
  seurat[["percent.rp"]] <- PercentageFeatureSet(seurat, pattern = ribo.pattern, assay = "RNA")
  
  # Filter cells based on QC criteria
  seurat[, seurat[["percent.mt"]] <= 20 & seurat[["nFeature_RNA"]] >= nFeature]
}

# Create a Seurat object and perform QC
seurat_obj <- CreateSeuratObject(counts = counts)

seurat_obj <- qc.seurat(seurat_obj, "Human", 500)

# Normalize data using LogNormalize method
seurat_obj <- NormalizeData(seurat_obj, normalization.method = "LogNormalize", scale.factor = 10000)

# Calculate cell cycle scores
seurat_obj <- CellCycleScoring(object = seurat_obj, g2m.features = cc.genes$g2m.genes, s.features = cc.genes$s.genes)

# Find highly variable features
seurat_obj <- FindVariableFeatures(seurat_obj, selection.method = "vst", nfeatures = 2000)

# Scale data by regressing out unwanted sources of variation
seurat_obj <- ScaleData(seurat_obj, vars.to.regress = c("nFeature_RNA", "percent.mt"), verbose = FALSE)
scaled_count <- seurat_obj@assays$RNA@scale.data

# Perform dimensionality reduction and clustering
seurat_obj <- RunPCA(seurat_obj, npcs = 30, verbose = FALSE, seed.use = 42)
seurat_obj <- RunTSNE(seurat_obj, reduction = "pca", dims = 1:30, seed.use = 1)
seurat_obj <- RunUMAP(seurat_obj, dims = 1:10, verbose = FALSE, seed.use = 42)
seurat_obj <- FindNeighbors(seurat_obj, reduction = "pca", dims = 1:30)
seurat_obj <- FindClusters(seurat_obj, resolution = c(0.10, 0.15, 0.25,0.75))

# Find doublets using DoubletFinder
suppressMessages(require(DoubletFinder))
nExp <- round(ncol(seurat_obj) * 0.04)  # expect 4% doublets
seurat_obj <- doubletFinder_v3(seurat_obj, pN = 0.25, pK = 0.09, nExp = nExp, PCs = 1:10)

# Load reference databases from celldex
hpca.ref <- celldex::HumanPrimaryCellAtlasData()
dice.ref <- celldex::DatabaseImmuneCellExpressionData()
blueprint.ref <- celldex::BlueprintEncodeData()
monaco.ref <- celldex::MonacoImmuneData()
northern.ref <- celldex::NovershternHematopoieticData()

# Convert Seurat object to SingleCellExperiment
sce <- as.SingleCellExperiment(DietSeurat(seurat_obj))
sce

# Auto-annotate cell types using reference databases from celldex
hpca.main <- SingleR(test = sce, assay.type.test = 1, ref = hpca.ref, labels = hpca.ref$label.main)
hpca.fine <- SingleR(test = sce, assay.type.test = 1, ref = hpca.ref, labels = hpca.ref$label.fine)
dice.main <- SingleR(test = sce, assay.type.test = 1, ref = dice.ref, labels = dice.ref$label.main)
dice.fine <- SingleR(test = sce, assay.type.test = 1, ref = dice.ref, labels = dice.ref$label.fine)
blue.main <- SingleR(test = sce, assay.type.test = 1, ref = blueprint.ref, labels = blueprint.ref$label.main)
blue.fine <- SingleR(test = sce, assay.type.test = 1, ref = blueprint.ref, labels = blueprint.ref$label.fine)
monaco.main <- SingleR(test = sce, assay.type.test = 1, ref = monaco.ref, labels = monaco.ref$label.main)
monaco.fine <- SingleR(test = sce, assay.type.test = 1, ref = monaco.ref, labels = monaco.ref$label.fine)
northern.main <- SingleR(test = sce, assay.type.test = 1, ref = northern.ref, labels = northern.ref$label.main)
northern.fine <- SingleR(test = sce, assay.type.test = 1, ref = northern.ref, labels = northern.ref$label.fine)

# Add the celldex annotations to the metadata of the Seurat object
seurat_obj@meta.data$hpca.main <- hpca.main$pruned.labels
seurat_obj@meta.data$hpca.fine <- hpca.fine$pruned.labels
seurat_obj@meta.data$dice.main <- dice.main$pruned.labels
seurat_obj@meta.data$dice.fine <- dice.fine$pruned.labels
seurat_obj@meta.data$monaco.main <- monaco.main$pruned.labels
seurat_obj@meta.data$monaco.fine <- monaco.fine$pruned.labels
seurat_obj@meta.data$northern.main <- northern.main$pruned.labels
seurat_obj@meta.data$northern.fine <- northern.fine$pruned.labels
seurat_obj@meta.data$blue.main <- blue.main$pruned.labels
seurat_obj@meta.data$blue.fine <- blue.fine$pruned.labels

# Manual annotations
seurat_obj@meta.data$seurat_clusters_gabby_annotation <- "NA"
seurat_obj@meta.data[which(seurat_obj@meta.data$seurat_clusters %in% c(1, 4:6, 8:11, 13, 15, 16)),
                     "seurat_clusters_gabby_annotation"] <- "Tumor"
seurat_obj@meta.data[which(seurat_obj@meta.data$seurat_clusters %in% c(0, 2, 3, 7, 14)),
                     "seurat_clusters_gabby_annotation"] <- "Myeloid"
seurat_obj@meta.data[which(seurat_obj@meta.data$seurat_clusters %in% c(12)),
                     "seurat_clusters_gabby_annotation"] <- "Stroma"

# Add UMAP coordinates to the metadata
UMAP <- as.data.frame(Embeddings(object = seurat_obj[["umap"]]))
seurat_obj@meta.data$UMAP_1 <- UMAP$UMAP_1
seurat_obj@meta.data$UMAP_2 <- UMAP$UMAP_2

# Add tSNE coordinates to the metadata
tsne <- as.data.frame(Embeddings(object = seurat_obj[["tsne"]]))
seurat_obj@meta.data$tSNE_1 <- tsne$tSNE_1
seurat_obj@meta.data$tSNE_2 <- tsne$tSNE_1



# Write metadata to a file
write.table(seurat_obj@meta.data, file = file.path(output_folder, paste0(Project_Name,"_metafile_with_annotation.txt")),
            sep = "\t")

# Write scaled count matrix to a file
write.table(scaled_count, file = file.path(output_folder, paste0(Project_Name,"_scaled_count_matrix.txt")),
            sep = "\t")

# Write seurat H5 file 
SaveH5Seurat(seurat_obj, filename = file.path(output_folder, paste0(Project_Name,"_h5friendly")),
             overwrite = TRUE, verbose = TRUE)


# Subset and write metadata for myeloid cells
Idents(seurat_obj) <- "seurat_clusters_gabby_annotation"

myeloid_subset <- subset(x = seurat_obj, idents = "Myeloid")
write.table(myeloid_subset@meta.data, file = file.path(output_folder, paste0(Project_Name,"_myeloid_metafiles.txt")),
            sep = "\t")

# Save myeloid subset as H5Seurat object
SaveH5Seurat(myeloid_subset, filename = file.path(output_folder, paste0(Project_Name,"_myeloid_h5friendly")),
             overwrite = TRUE, verbose = TRUE)

# Subset and write metadata for tumor cells
tumor_subset <- subset(x = seurat_obj, idents = "Tumor")
write.table(tumor_subset@meta.data, file = file.path(output_folder, paste0(Project_Name,"_tumor_metafiles.txt")),
            sep = "\t")

# Save tumor subset as H5Seurat object
SaveH5Seurat(tumor_subset, filename = file.path(output_folder, paste0(Project_Name,"_tumor_h5friendly")),
             overwrite = TRUE, verbose = TRUE)









