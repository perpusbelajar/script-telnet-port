#!/bin/bash

# Prompt user for the port number to check
read -p "Enter the port number to check: " PORT
# Validate if the port is a number
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "Error: Port must be a number."
  exit 1
fi

# Prompt user for the file containing the list of IP addresses
read -p "Enter the input file name (e.g., listipserver.txt): " FILE

# Check if the input file exists
if [[ ! -f "$FILE" ]]; then
  echo "Error: $FILE not found!"
  exit 1
fi

# Prompt user for the output file name
read -p "Enter the output report file name (e.g., report.txt): " REPORT_FILE

# Clear the previous report file if it exists
> "$REPORT_FILE"

# Header for the report
echo "Port $PORT Check Report" | tee -a "$REPORT_FILE"
echo "=====================" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Loop through each line (IP) in the file
while IFS= read -r ip; do
  # Skip empty lines or lines starting with '#'
  if [[ -z "$ip" || "$ip" =~ ^# ]]; then
    continue
  fi

  # Check if the specified port is open using telnet (using /dev/tcp)
  (echo > /dev/tcp/"$ip"/"$PORT") &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo "$ip: Port $PORT is open" | tee -a "$REPORT_FILE"
  else
    echo "$ip: Port $PORT is closed or unreachable" | tee -a "$REPORT_FILE"
  fi
done < "$FILE"

# Summary section
echo "" | tee -a "$REPORT_FILE"
echo "===== Summary =====" | tee -a "$REPORT_FILE"

# Count the results
open_count=$(grep -c "Port $PORT is open" "$REPORT_FILE")
closed_count=$(grep -c "Port $PORT is closed or unreachable" "$REPORT_FILE")

echo "Total IPs checked: $(grep -vc '^#' "$FILE")" | tee -a "$REPORT_FILE"
echo "Port $PORT open: $open_count IP(s)" | tee -a "$REPORT_FILE"
echo "Port $PORT closed or unreachable: $closed_count IP(s)" | tee -a "$REPORT_FILE"

# Notify user of saved report
echo ""
echo "Results saved to $REPORT_FILE"

