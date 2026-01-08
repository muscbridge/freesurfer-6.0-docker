#!/bin/sh
# FreeSurfer 6.0 BIDS wrapper (Docker)
# Usage: run_freesurfer_bids INPUT_BIDS_ROOT [OUTPUT_ROOT]

INPUT_BIDS="$1"
OUTPUT_ROOT="$2"   # optional

FS_VERSION="6.0"
DOCKER_IMAGE="freesurfer:6.0"

# ---- sanity checks ----
if [ -z "$INPUT_BIDS" ]; then
    echo "Usage: $0 INPUT_BIDS_ROOT [OUTPUT_ROOT]"
    exit 1
fi

if [ ! -d "$INPUT_BIDS" ]; then
    echo "Error: input folder not found: $INPUT_BIDS"
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker not found in PATH"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is installed but not running"
    exit 1
fi

# Set output folder
if [ -z "$OUTPUT_ROOT" ]; then
    OUTPUT_ROOT="$INPUT_BIDS/derivatives/Preprocessing/freesurfer/freesurfer_$FS_VERSION"
fi

echo "Input BIDS root: $INPUT_BIDS"
echo "Output root: $OUTPUT_ROOT"
echo

# ---- loop over subjects and sessions ----
for SUB_DIR in "$INPUT_BIDS"/sub-*; do
    [ -d "$SUB_DIR" ] || continue
    SUBJECT=`basename "$SUB_DIR"`

    echo "Processing subject: $SUBJECT"

    # Determine session folders, or assume single-session
    SES_DIRS=$(find "$SUB_DIR" -maxdepth 1 -type d -name "ses-*" 2>/dev/null)
    if [ -z "$SES_DIRS" ]; then
        SES_DIRS="$SUB_DIR"
    fi

    for SES_DIR in $SES_DIRS; do
        SES=`basename "$SES_DIR"`
        if [ "$SES_DIR" = "$SUB_DIR" ]; then
            SES="$SUBJECT"
        fi

        ANAT_DIR="$SES_DIR/anat"
        T1="$ANAT_DIR/${SUBJECT}_${SES}_T1w.nii.gz"

        if [ ! -f "$T1" ]; then
            echo "  Missing T1 for $SES, skipping"
            continue
        fi

        # Map the parent folder of the session to /subjects in Docker
        PARENT_DIR="$OUTPUT_ROOT/$SUBJECT"
        mkdir -p "$PARENT_DIR"

        # Skip if this session is already processed
        if [ -d "$PARENT_DIR/$SES/surf" ]; then
            echo "  Already processed $SES, skipping"
            continue
        fi

        echo "  Running FreeSurfer for $SES"

        docker run --rm \
			-v "$ANAT_DIR:/data:ro" \
			-v "$PARENT_DIR:/subjects" \
			"$DOCKER_IMAGE" \
			bash -c "source /opt/freesurfer/SetUpFreeSurfer.sh && recon-all -i /data/$(basename "$T1") -s $SES -sd /subjects -all"


        echo "  Finished $SES"
        echo
    done
done

echo "All subjects complete"
