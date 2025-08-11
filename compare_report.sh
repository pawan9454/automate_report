#!/bin/bash

report_dir="/root/customer_reports"
temp_dir="/tmp/compare_reports"
mkdir -p "$temp_dir"

# Get latest 2 reports
latest_reports=($(ls -t "$report_dir"/customer_disk_usage_report_*.txt | head -n 2))

if [ ${#latest_reports[@]} -lt 2 ]; then
    echo "❌ Not enough reports to compare (need at least 2)."
    exit 1
fi

file_new="${latest_reports[0]}"
file_old="${latest_reports[1]}"
compare_file="$report_dir/compare_$(date '+%Y-%m-%d_%H-%M').txt"

# Clean temp file
> "$temp_dir/compare_raw.txt"

# Extract customer and sizes
awk '/^|/ && !/Customer/ && !/^\+/' "$file_old" | awk -F '|' '{gsub(/ /,"",$2); gsub(/ /,"",$3); print $2" "$3}' > "$temp_dir/old.txt"
awk '/^|/ && !/Customer/ && !/^\+/' "$file_new" | awk -F '|' '{gsub(/ /,"",$2); gsub(/ /,"",$3); print $2" "$3}' > "$temp_dir/new.txt"

# Process each customer
while read -r cust_old size_old; do
    size_new=$(grep "^$cust_old " "$temp_dir/new.txt" | awk '{print $2}')
    
    # Convert to KB
    old_kb=$(numfmt --from=iec "$size_old" 2>/dev/null || echo 0)
    new_kb=$(numfmt --from=iec "$size_new" 2>/dev/null || echo 0)
    diff_kb=$((new_kb - old_kb))
    
    # Output to raw compare file
    echo "$diff_kb $cust_old $size_old $size_new" >> "$temp_dir/compare_raw.txt"
done < "$temp_dir/old.txt"

# Sort by difference in descending order
sort -nr "$temp_dir/compare_raw.txt" > "$temp_dir/compare_sorted.txt"

# Write final report
{
    printf "+------------+------------+------------+-------------+\n"
    printf "| Customer   | Previous   | Current    | Difference  |\n"
    printf "+------------+------------+------------+-------------+\n"
    while read -r diff_kb cust old new; do
        # Convert diff back to human
        diff_hr=$(numfmt --to=iec --suffix=B "$diff_kb" 2>/dev/null || echo "0B")
        printf "| %-10s | %-10s | %-10s | %-11s |\n" "$cust" "$old" "$new" "$diff_hr"
    done < "$temp_dir/compare_sorted.txt"
    printf "+------------+------------+------------+-------------+\n"
} > "$compare_file"

echo "✅ Sorted comparison report saved to: $compare_file"

