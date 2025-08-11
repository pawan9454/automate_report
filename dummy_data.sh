#!/bin/bash

# Target path where you want to create the folders
target_path="/root/"

# Main folder name under target path
main_folder="Customers"

# Full path
full_path="$target_path/$main_folder"

# Create the main folder
mkdir -p "$full_path"

# Create 20 subfolders with dummy files
for i in {1..20}; do
    subfolder="cust$i"
    folder_path="$full_path/$subfolder"
    mkdir -p "$folder_path"

    # Create a dummy file with increasing size (e.g., 1MB to 20MB)
    size=$((i * 3))  # size in MB
    dummy_file="$folder_path/file${i}.dat"

    # You can use either of the below methods:

    ## Option 1: using fallocate (fast, preferred if supported)
    fallocate -l "${size}M" "$dummy_file" 2>/dev/null

    ## Option 2: fallback using dd if fallocate is not available
    if [ $? -ne 0 ]; then
        dd if=/dev/zero of="$dummy_file" bs=1M count=$size status=none
    fi

    echo "Created $dummy_file of size ${size}MB"
done

# Final confirmation
echo -e "\nAll folders and dummy files created under $full_path"

