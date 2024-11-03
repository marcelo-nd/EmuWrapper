#!/bin/bash

EMU_DATABASE_DIR=""
sequences_path=""
output_path=""
bc_dir=""

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLUE='\033[34m'

function print_usage {
    echo "usage: [-d database] [-s sequences] [-o output] [-b barcodes] [-n names]"
    echo "  -h      print help"
    echo "  -d      specify Emu database path to be used"
    echo "  -s      specifiy the path to your sequence zip files"
    echo "  -z      specify if you want to unzip barcode sequences ("TRUE" or "FALSE")"
    echo "  -o      specifiy the output path were OTU tables are going to be stored"
    echo "  -c      specify if you want to perferom copy number adjustment ("TRUE" or "FALSE")"
    echo "  -p      specify the path to the copy number database"
}

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
	print_usage
  return
fi

# Reset OPTIND to wnter while loop assignment
OPTIND=1

while getopts 's:o:' flag; do
#echo "assigning variables"
  case "${flag}" in
    s)
      # Set the sequences directory
      sequences_path="${OPTARG}" ;;
    o)
      # Set Output directory path
      output_path="${OPTARG}" ;;
    *)
      print_usage
      return
  esac
done

# Print parsed Sequences directory path
echo -e "${BLUE}Sequences path: $sequences_path${NC}"
# Print parsed Output directory path
echo -e "${BLUE}Output path: $output_path${NC}"

# Prefix for the names of barcode folders. Maybe it changes in the future or can ask user.
export prefix="barcode";
#echo "prefix: $prefix"
# Get the directories for all the barcodes
barcode_dir_list=`ls -d $sequences_path/$prefix*`
#echo "Barcode directories list: $barcode_dir_list"
# PART 1 UNZIP GZ FILES:

# Create output fastaq directory
if ! [ -d "$output_path/fastq/" ];
  # create "fastaq" directory
  then mkdir $output_path/fastq
fi

# For loop to Unzip fastaq files
for bc_dir in $barcode_dir_list; do
  #echo $bc_dir
  delimiter="/"
  last_piece=""

  # Replace delimiter with a newline and loop through each line
  for part in ${bc_dir//"$delimiter"/$'\n'}; do
    #echo "$part"
    bc_string="$part"
  done
  # Print the last piece
  #echo "$bc_string"

  # Get the list of files in sample directory
  files=$(shopt -s nullglob dotglob; echo $bc_dir/*);
  
#     #echo $files
#     #echo {$bc_dir}
#     #a="$bc_dir"
#     #echo ${a: -9:9}
#     # if list of files inside bc directory variable contains something
  if (( ${#files} ));
  then echo -e "${GREEN}Unzipping files in: $bc_dir${NC}";
  # If barcode/fastaq directory does not exists, this is were unzipped fastaq files are stored
  if ! [ -d "$output_path/fastq/$bc_string" ];
    # create "fastaq" directory
    then mkdir $output_path/fastq/$bc_string
  fi
  # Now lets iterate over al the gz files to uncompress them
  for f in "$bc_dir"/*.gz; do
    # Run gunzip, retain files and extract in "fastaq" directory
    STEM=$(basename "${f}" .gz)
    # gunzip: c flag is for keeping original files, f flag is to replace the ones that exist in output if they have the same name
    gunzip -k -c -f "${f}" > $output_path/fastq/$bc_string/"${STEM}"
  done
  # Concat fastq files to run EMU once per barcode
  cat $output_path/fastq/$bc_string/* > $output_path/fastq/$bc_string/"${bc_string}_concat.fastq"
  fi
done


