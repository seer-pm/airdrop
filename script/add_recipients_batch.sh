CHUNK_SIZE=125
RETRIES=2

PAGE=1

# Check if the script received a file name argument
if [ -z "$1" ]; then
    echo "Error: Please provide the base name of the JSON file as an argument (e.g., 'humans-mainnet' for the file 'data/humans-mainnet.json')."
    exit 1
fi

# Define file names based on the provided argument
FILE_NAME="$1"
JSON_FILE="data/${FILE_NAME}.json"
IMPORT_LOCK_FILE="data/${FILE_NAME}.import.lock"

# Check if the JSON file exists
if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file '$JSON_FILE' not found."
    exit 1
fi

# Check if the IMPORT_LOCK_FILE exists or create it, and ensure we have write access
if [ ! -f "$IMPORT_LOCK_FILE" ]; then
    touch "$IMPORT_LOCK_FILE" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Unable to create or write to $IMPORT_LOCK_FILE. Exiting."
        exit 1
    fi
fi

# Read the page from the import lock file, if it exists and is non-empty
if [ -s "$IMPORT_LOCK_FILE" ]; then
    echo "Resuming from the last failed page..."
    start_page=$(cat "$IMPORT_LOCK_FILE")
else
    start_page=0  # Start fresh if no import lock exists
fi

pages=$(jq -r "[.[]] | [range(0; length; $CHUNK_SIZE) as \$i | .[\$i:\$i+$CHUNK_SIZE] | join(\",\")] | .[]" --argjson CHUNK_SIZE "$CHUNK_SIZE" "$JSON_FILE")

while IFS= read -r recipients; do

    # Skip pages until reaching the start_page if it is greater than 0
    if [ "$start_page" -gt 0 ] && [ "$PAGE" -le "$start_page" ]; then
        printf "\n========== SKIP PAGE: $PAGE ==========\n\n"
        ((++PAGE))
        continue
    fi


    start_page=0  # Reset start_page after reaching the resume point

    printf "\n========== PAGE: $PAGE ==========\n\n"

    attempt=1

    while [ $attempt -le $RETRIES ]; do
        RECIPIENTS_ADDRESSES=$recipients bash -c 'time forge script script/AddRecipients.s.sol:AddRecipients --broadcast --rpc-url gnosis --via-ir' && break
        
        # Check if the command failed
        if [ $? -ne 0 ]; then
            echo "Attempt $attempt for PAGE=$PAGE failed. Retrying..."
            ((attempt++))
            sleep 5  # Add a delay before retrying
        else
            echo "Success for PAGE=$PAGE"
            break
        fi
    done
    
    # If the command failed after all retries, log the failure
    if [ $attempt -gt $RETRIES ]; then
        echo "PAGE=$PAGE failed after $RETRIES attempts."
        break  # Stop processing further pages
    fi


    # Log the last successfully processed page
    echo "$PAGE" | tee "$IMPORT_LOCK_FILE" >/dev/null

    ((++PAGE))
done <<< "$pages"