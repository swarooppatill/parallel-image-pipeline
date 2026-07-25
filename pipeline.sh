#!/usr/bin/env bash

set -euo pipefail

INPUT_DIR="${INPUT_DIR:-./input}"
OUTPUT_DIR="${OUTPUT_DIR:-./output}"
LOG_DIR="./logs"
LOG_FILE="${LOG_DIR}/benchmark_results.csv"
NUM_JOBS="${NUM_JOBS:-$(nproc)}"
MODE="${1:-parallel}" # Options: "parallel" or "sequential"

mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

# Ensure CSV header exists
if [ ! -f "$LOG_FILE" ]; then
    echo "timestamp,mode,total_files,threads,elapsed_seconds,throughput_img_sec" > "$LOG_FILE"
fi

# Worker function for single image transformations
process_image() {
    local img_path="$1"
    local out_dir="$2"
    local filename
    filename=$(basename "$img_path")
    local target_path="${out_dir}/processed_${filename}"

    # Stage 1: Convert to Grayscale
    # Stage 2: Gaussian Blur
    # Stage 3: Edge Detection Charcoal effect
    # Stage 4: Resize to 1080p width
    convert "$img_path" \
        -colorspace Gray \
        -gaussian-blur 0x2 \
        -charcoal 1 \
        -resize 1920x \
        "$target_path"
}

export -f process_image

# Collect files
mapfile -t IMAGES < <(find "$INPUT_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \))
TOTAL_FILES=${#IMAGES[@]}

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo "[!] Error: No valid images found in $INPUT_DIR"
    exit 1
fi

echo "===================================================="
echo "  Parallel Image Processing Pipeline (Ubuntu Bash)  "
echo "===================================================="
echo " Mode             : $MODE"
echo " Input Images     : $TOTAL_FILES"
echo " CPU Cores Used   : $NUM_JOBS"
echo "----------------------------------------------------"

START_TIME=$(date +%s.%N)

if [ "$MODE" == "parallel" ]; then
    printf "%s\n" "${IMAGES[@]}" | parallel -j "$NUM_JOBS" --bar process_image {} "$OUTPUT_DIR"
elif [ "$MODE" == "sequential" ]; then
    count=1
    for img in "${IMAGES[@]}"; do
        echo -ne "Processing image $count/$TOTAL_FILES...\r"
        process_image "$img" "$OUTPUT_DIR"
        ((count++))
    done
    echo ""
else
    echo "Invalid mode specified! Use 'parallel' or 'sequential'."
    exit 1
fi

END_TIME=$(date +%s.%N)
ELAPSED=$(echo "$END_TIME - $START_TIME" | bc)
THROUGHPUT=$(echo "scale=2; $TOTAL_FILES / $ELAPSED" | bc)

echo "----------------------------------------------------"
echo " Execution Complete!"
echo " Total Time Taken : ${ELAPSED} seconds"
echo " Throughput       : ${THROUGHPUT} images/sec"
echo " Output Location  : ${OUTPUT_DIR}"
echo "===================================================="

# Log metrics to CSV
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "$TIMESTAMP,$MODE,$TOTAL_FILES,$NUM_JOBS,$ELAPSED,$THROUGHPUT" >> "$LOG_FILE"
echo "[+] Results appended to $LOG_FILE"
