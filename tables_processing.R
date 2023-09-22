if (!require("readr", quietly = TRUE))
  install.packages("readr")

if (!require("dplyr", quietly = TRUE))
  install.packages("dplyr")

library(readr)

library(dplyr, quietly = TRUE)

#user_path <- "C:/Users/Marcelo/Desktop/results/";

args <- commandArgs(trailingOnly = TRUE)

#print(args)

user_path <- args[1]
#print(user_path)

barcodes_to_process_arg <- args[2]

#barcodes_to_process_arg <-  "01,02,03,04"
#print(barcodes_to_process_args)

barcodes_to_process <- NULL

if (barcodes_to_process_arg != "all") {
  try(
    barcodes_to_process <- strsplit(barcodes_to_process_arg, ",")
      )
}else if (barcodes_to_process_arg == "all") {
  abundance_tables <- list.files(path = user_path, pattern = NULL, all.files = FALSE,
                                 full.names = FALSE, recursive = FALSE,
                                 ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
}

if (!is.null(barcodes_to_process)) {
  #print(barcodes_to_process)
  abundance_tables <- list.files(path = user_path, pattern = NULL, all.files = FALSE,
                                 full.names = FALSE, recursive = FALSE,
                                 ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
  abundance_tables2 <- c()
  
  for (at in seq(from = 1, to = length(abundance_tables), by=1)) {
    for (bc in seq(from = 1, to = length(barcodes_to_process[[1]]), by=1)) {
      #print(barcodes_to_process[[1]][bc])
      if (grepl(barcodes_to_process[[1]][bc], abundance_tables[at])) {
        abundance_tables2 <- c(abundance_tables2, abundance_tables[at])
      }
    }
  }
  abundance_tables <- abundance_tables2
}
#print(abundance_tables)

barcode_numbers <- c()

for (table in seq(from = 1, to = length(abundance_tables), by=1)) {
  #print(substr(abundance_tables[table], start = 8, stop = 9))
  current_bc <- substr(abundance_tables[table], start = 8, stop = 9)
  barcode_numbers <- c(barcode_numbers, current_bc)
}

#print(barcode_numbers)

processed_file = 1

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

print(head(otu_table))

write.table(otu_table, file = paste0(user_path, "otu_table.csv"), quote = FALSE, row.names = FALSE, sep = ",")
