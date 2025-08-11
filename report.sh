#!/bin/bash

# Base path where customer folders exist
base_path="/root/Customers"

# Folder to store reports
report_dir="/root/customer_reports"
mkdir -p "$report_dir"

# Timestamped filename
timestamp=$(date '+%Y-%m-%d_%H-%M')
report_file="$report_dir/customer_disk_usage_report_${timestamp}.txt"

# Header
{
    printf "+------------+--------+\n"
    printf "| Customer   | Size   |\n"
    printf "+------------+--------+\n"
} > "$report_file"

# Loop through each folder
for folder in "$base_path"/*/; do
    size=$(du -sh "$folder" | cut -f1)
    name=$(basename "$folder")
    printf "| %-10s | %-6s |\n" "$name" "$size" >> "$report_file"
done

# Footer
printf "+------------+--------+\n" >> "$report_file"

# Confirm
echo "Report saved to: $report_file"

