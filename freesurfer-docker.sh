#!/bin/sh
# POSIX-safe FreeSurfer 6.0 BIDS wrapper
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

    for SES_DIR in "$SUB_DIR"/ses-*; do
        [ -d "$SES_DIR" ] || continue
        SES=`basename "$SES_DIR")`

        ANAT_DIR="$SES_DIR/anat"
        T1="$ANAT_DIR/${SUBJECT}_${SES}_T1w.nii.gz"

        if [ ! -f "$T1" ]; then
            echo "  Missing T1 for $SES, skipping"
            continue
        fi

        OUTDIR="$OUTPUT_ROOT/$SUBJECT/$SES"

        if [ -d "$OUTDIR/surf" ]; then
            echo "  Already processed $SES, skipping"
            continue
        fi

        mkdir -p "$OUTDIR"

        echo "  Running FreeSurfer for $SES"

        docker run --rm \
            -v "$ANAT_DIR:/data:ro" \
            -v "$OUTDIR:/subjects" \
            "$DOCKER_IMAGE" \
            recon-all \
                -i "/data/`basename "$T1"`" \
                -s "${SUBJECT}_${SES}" \
                -all

        echo "  Finished $SES"
        echo
    done
done

echo "All subjects complete"
