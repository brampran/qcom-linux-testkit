#!/bin/bash
 
# Step 1: Find the media node with qcom-camss driver
for media in /dev/media*; do
    if media-ctl -p -d "$media" 2>/dev/null | grep -q "driver[[:space:]]*qcom-camss"; then
        MEDIA_NODE="$media"
        break
    fi
done
 
if [ -z "$MEDIA_NODE" ]; then
    echo "No media device with qcom-camss driver found."
    exit 1
fi
 
echo "Using media node: $MEDIA_NODE"
 
# Step 2: Get the entity number for msm_vfe0_video0
ENTITY_LINE=$(media-ctl -p -d "$MEDIA_NODE" 2>/dev/null | grep -E 'entity [0-9]+: msm_vfe0_video0')
ENTITY_NUM=$(echo "$ENTITY_LINE" | grep -oP 'entity \K[0-9]+')
 
if [ -z "$ENTITY_NUM" ]; then
    echo "Could not find entity for msm_vfe0_video0."
    exit 1
fi
 
# Step 3: Extract the device node name from that entity
VIDEO_NODE=$(media-ctl -p -d "$MEDIA_NODE" 2>/dev/null | \
    awk -v entity="entity $ENTITY_NUM:" '
    $0 ~ entity { found=1; next }
    found && /device node name/ {
        print $NF
        exit
    }')
 
if [ -n "$VIDEO_NODE" ]; then
    echo "Video node for msm_vfe0_rdi0 is: $VIDEO_NODE"
else
    echo "Could not find video node for msm_vfe0_video0."
    exit 1
fi
