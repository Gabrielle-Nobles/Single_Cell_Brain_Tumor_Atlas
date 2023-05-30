# Moffitt_Internship_2023
![scRNA-seq Analysis Protocol and Post Processing Protocol](https://github.com/Gabrielle-Nobles/Single_Cell_Brain_Tumor_Atlas/assets/97853225/4fdfb208-c6e4-418f-bd27-7de8a39f07d1)

## Introduction 
The utilization of single-cell RNA sequencing (scRNA-seq) has emerged as a robust and potent approach to examining the complexities of cellular heterogeneity and genetic expression with distinctive resolution. However, analyzing scRNAseq data can be complex and requires a standardized approach. This protocol outlines a comprehensive workflow for analyzing scRNAseq data using R and the Seurat package, along with other tools like SeuratDisk, pathwork, dplyr, Single R, and Celldex. The protocol covers essential steps such as quality control, normalization, data scaling, dimensionality reduction, clustering, and automated cell annotation. Following this protocol allows bioinformaticians and researchers to effectively analyze scRNAseq data, identify distinct cell populations, and gain valuable insights into cellular dynamics and functions. The output files generated by this protocol, including metadata, H5 Seurat files, cell subpopulation metadata, and ISCVA-compliant files, facilitate downstream analyses and enable integration with other analysis and visualization tools. This protocol provides a standardized and reproducible framework for scRNAseq analysis. 
## Installation 

### R dependencies 

### Input Files 
To achieve accurate results in single-cell RNA sequencing (scRNAseq) analysis, it's crucial to have high-quality and compatible input data. The input file should be a raw count matrix of single cells, with each row representing a gene and each column representing a specific cell. The numbers within the matrix indicate the raw expression counts or read counts of genes in each cell. Ensure that the input file is in a compatible format, such as a Comma-Separated Values (CSV) file, tab-delimited text file or a Tab-Seperated Values (TSV) file, as these formats are easily readable and processed by R and the Seurat package. If you have used the CellRanger pipeline to process your scRNAseq data, you should have three input files: matrix (matrix.mtx), barcode (barcode.tsv), and features (features.tsv).

**Parameter file to read in the barcode.tsv, matrix.mtx and genes.tsv from each individual patient**
### Single Cell RNA-seq Analysis 
1. Quality Control
-- Hao et al.,Cell 2021.[PMID: 34062119]
- Perform quality control (QC) steps to filter out low-quality cells and genes. QC calculates the percentages of mitochondrial genes and ribosomal protein genes for each cell, and then filters out cells that have high mitochondrial gene content and low detected features in the RNA assay.  
3. Normalization 
- Hao et al.,Cell 2021.[PMID: 34062119]
- After completing the QC steps, it's important to normalize the count matrix to adjust for differences in library sizes and sequencing depth. This is a crucial step in analyzing scRNAseq data because it accounts for variations in library sizes and sequencing depth between individual cells. Normalization ensures that expression values can be compared accurately and eliminates technical biases. 
- Our method employs the "LogNormalize" parameter, which performs a global-scaling normalization. It divides each gene's expression by the total expression of that gene across all cells, multiplies the data by a default scale factor of 10,000, and log-transforms it. This normalization method is valuable for preserving the relative differences between cells while normalizing gene expression across them.
4. Cell Cycle Scores
- Hao et al.,Cell 2021.[PMID: 34062119]
- To determine cell cycle activity in scRNAseq data, the expression levels of certain genes associated with the cell cycle are analyzed and cell cycle scores are assigned to individual cells.
5. Scaling Data 
- Hao et al.,Cell 2021.[PMID: 34062119]
- Scaling normalizes and transform gene expression values, which helps to remove unwanted technical variation and improve the accuracy of downstream analyses
- The scaling method used by default is the "LogNormalize" method, which performs a natural logarithm transformation followed by centering and scaling of the gene expression values.
- During the scaling process, the variables specified in 'vars.to.regress' (nFeature_RNA and percent.mt in this case) are regressed out. This means that any variation in the gene expression values that can be attributed to these variables is removed.
6. Prinicpal Component Analysis (PCA)
- Hao et al.,Cell 2021.[PMID: 34062119]
- Conduct PCA on the scaled data to reduce the dimensionality of the dataset while preserving the most significant sources of variation. This step helps identify major sources of heterogeneity within the dataset. 
7. Nearest Neighbor 
- Compute the nearest neighbors for each cell in the reduced PCA space. This step helps identify cells that are likely to be biologically similar based on their expression profiles
8. SNN clustering 
- Hao et al.,Cell 2021.[PMID: 34062119]
- Perform clustering of the cells using the shared nearest neighbor (SNN) optimization based clustering algorithm. This algorithm group cells into clusters based on their similarity in the PCA space.
9. Doublet Finder 
- McGinnis et al.,CellPress.2019.[PMID: 30954475]
10. Automated Cell Annotation using SingleR and Celldex
- Aran et al.,Nature Immunology.2019.[PMID: 30643263]
- Leverage external reference datasets and computational tools like SingleR and Celldex to automatically annotate cell types or states. SingleR compares the gene expression of each cell to a reference dataset, while Celldex predicts cell type annotations based on a cell type reference database. These annotations provide biological context to the identified cell clusters.
### Output files 
- **Metadata**
1. Cell Cycle Score (S.score,G2M.score, and Phase) 
2. QC percentage (percent.rp and perdent.mt)
3. Doublets (pANN and DF.classfication) 
4. Resoulutions (integrated_snn_res or RNA_snn_res) 
5. Umap and Tsne coordinates 
6. Single R annotations 
- hpca.main and hpca.fine 
- dice.main and dice.fine 
- monacco.main and moncacco.fine 
- nothern.main and northern.fine
- blue.main and blue.fine
7. Manually curated cell annotations (seurat_clusters_gabby_annotations) 
- **H5 Seurat-compliant file** 
-- Export the processed and analyzed data in the H5 Seurat file format. This file contains the expression values, dimensionality reduction results, clustering information, and metadata. It serves as a comprehensive representation of the analyzed single-cell RNAseq data.
- **Subset of cell populations**
--Create separate metadata and H5 Seurat files for each identified cell subpopulation or cluster. This division facilitates downstream analyses focused on specific cell populations of interest.
- **H5 ISCVA-compliant file** 
--The H5 ISCVA-compliant file is a specific file format designed to load and interact with the Interactive Single Cell Visual Analytics (ISCVA) application. 
## Post Processing: Gene expression 
### Input File
The H5 Seurat file typically contains essential information such as the expression matrix, cell metadata, dimensionality reduction results, clustering information, and other annotations relevant to the dataset. Loading the H5 Seurat file ensures that all the necessary data and attributes are available for subsequent analysis steps.
## Gene expresssion 

### Output Files 

## Post Processing: 1000 Matrix for Umap application 
### Input File 


### Output File 



