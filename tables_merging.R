# Install and load packages
if (!require("readr", quietly = TRUE))
  install.packages("readr")

if (!require("dplyr", quietly = TRUE))
  install.packages("dplyr")

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

if (!require("biomformat", quietly = TRUE))
  BiocManager::install("biomformat")

if (!require("rbiom", quietly = TRUE))
  install.packages("rbiom")

library(readr)

library(dplyr, quietly = TRUE)

library("rbiom")

# Read arguments from console execution of R script
args <- commandArgs(trailingOnly = TRUE)
#print(args)

# Assign first argument to user_path. Where the result tables are.
user_path <- args[1]

# Assign argument 2 to "barcodes_to_process_arg" this is the string that contains barcode numbers separated by commas
barcodes_to_process_arg <- args[2]

# Assign argument 3 to sample names. #barcodes_to_process_arg <-  "01,02,03,04"
sample_names_arg <- args[3]


# FOR TESTING
#user_path <- "C:/Users/Marcelo/Desktop/results/";
#barcodes_to_process_arg <-  "01,02"
#sample_names_arg <- "liquid, solid"

# Initialize variables
barcodes_to_process <- NULL
sample_names <- NULL

# If all barcodes are to be processed abundance tables list is determined with all barcodes directories
if (barcodes_to_process_arg != "all") {
  try(
    barcodes_to_process <- strsplit(barcodes_to_process_arg, ",")
      )
}else if (barcodes_to_process_arg == "all") {
  abundance_tables <- list.files(path = user_path, pattern = NULL, all.files = FALSE,
                                 full.names = FALSE, recursive = FALSE,
                                 ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
}

# If a list of barcodes is passed, we have to go through the abundance_tables list
# and extract only the ones for the chosen barcodes.
if (!is.null(barcodes_to_process)) {
  #print(barcodes_to_process)
  abundance_tables <- list.files(path = user_path, pattern = NULL, all.files = FALSE,
                                 full.names = FALSE, recursive = FALSE,
                                 ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
  abundance_tables2 <- c()
  
  for (at in seq(from = 1, to = length(abundance_tables), by=1)) {
    for (bc in seq(from = 1, to = length(barcodes_to_process[[1]]), by=1)) {
      # Find the barcode number in the list of tables.
      if (grepl(barcodes_to_process[[1]][bc], abundance_tables[at])) {
        abundance_tables2 <- c(abundance_tables2, abundance_tables[at])
      }
    }
  }
  abundance_tables <- abundance_tables2
}
#print(abundance_tables)

# Get the sample names parsed by splitting the user input string.
if (!is.null(sample_names_arg)) {
  sample_names <- strsplit(sample_names_arg, ",")
}

barcode_numbers <- c()

#Generate barcode names from abundance tables.
for (table in seq(from = 1, to = length(abundance_tables), by=1)) {
  # Using the last two characters of each abundance table file
  current_bc <- substr(abundance_tables[table], start = 8, stop = 9)
  barcode_numbers <- c(barcode_numbers, current_bc)
}

processed_file = 1

# For loop to merge all the tables in the list, only using the tables that end with "rel-abundance.tsv" generated by emu.
for (file_number in seq(from = 1, to = length(abundance_tables), by = 1)) {
  if (endsWith(abundance_tables[file_number], "rel-abundance.tsv")){
    #print(file_number)
    if(processed_file == 1){
      otu_table <- dplyr::select(readr::read_tsv(paste(user_path, abundance_tables[file_number], sep = "/")), "lineage", "estimated counts")
      colnames(otu_table) <- c("lineage", paste0("barcode", toString(barcode_numbers[processed_file])))
      processed_file = processed_file + 1
    }
    else{
      current_table <- dplyr::select(readr::read_tsv(paste(user_path, abundance_tables[file_number], sep = "/")), "lineage", "estimated counts")
      colnames(current_table) <- c("lineage", paste0("barcode", toString(barcode_numbers[processed_file])))
      processed_file = processed_file + 1
      otu_table <- merge(otu_table, current_table, by="lineage", all = TRUE)
    }
  }
}

otu_table["lineage"][is.na(otu_table["lineage"])] <- "Unassigned"

otu_table[is.na(otu_table)] <- 0

if (!is.null(sample_names) && length(sample_names) == length(barcodes_to_process)) {
  colnames(otu_table) <- c(colnames(otu_table)[1], sample_names[[1]])
}

print(head(otu_table))

write.table(otu_table, file = paste0(user_path, "otu_table.csv"), quote = FALSE, row.names = FALSE, sep = ",")

otu_table_biom <- biomformat::make_biom(otu_table)

biomformat::write_biom(otu_table_biom, paste0(user_path, "otu_table.biom"))
