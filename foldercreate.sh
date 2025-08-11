#!/bin/bash

# Target path where you want to create the folders
target_path="/root/"

# Main folder name under target path
main_folder="Customers"

# Full path
full_path="$target_path/$main_folder"


# Create the main folder
mkdir -p "$full_path"

# Create subfolders inside main folder
for i in {1..20}; do
     subfolder="cust$i"
     mkdir -p "$full_path/$subfolder"
done 

# Confirmation
echo "Folders created under $full_path:"
ls -l "$full_path"
