#!/bin/bash

WORKDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOGS="${LOGS:=0}"
URL="${URL:='https://www.tulliobuzzi.edu.it/tutte-le-news'}"
WIDTH="${WIDTH:=1024}"
HEIGHT="${WIDTH:=1000}"
CROP_X="${WIDTH:=0}"
CROP_Y="${WIDTH:=250}"
CROP_W="${WIDTH:=1024}"
CROP_H="${WIDTH:=500}"

send-notify() {
    $WORKDIR/send-notify.sh
}

createLogs() {
    # Create logs folder if not found
    if [[ ! -d $WORKDIR/logs ]]; then
        echo "[INFO] Logs dir not found, creating one..."
        mkdir $WORKDIR/logs
    fi

    # Gen log files with syntax "{ref(erence)/sta(ging)/out(put)}-{current date}.png"
    cp $WORKDIR/reference.png $WORKDIR/logs/ref-$(date | tr " " "-" | cut -d "-" -f2-4).png
    cp $WORKDIR/staging.png $WORKDIR/logs/sta-$(date | tr " " "-" | cut -d "-" -f2-4).png
    cp $WORKDIR/output.png $WORKDIR/logs/out-$(date | tr " " "-" | cut -d "-" -f2-4).png
    echo "[INFO] Generated snapshots logs"
}

# Gen the output image
wkhtmltoimage --width $WIDTH --height $HEIGHT --crop-x $CROP_X --crop-y $CROP_Y --crop-w $CROP_W --crop-h $CROP_H $URL $WORKDIR/output.png

if [[ ! -f $WORKDIR/output.png ]]; then
    echo "[ERROR] Failed creation of website snapshot, exiting..."
    exit 1
fi

# On first run take output as reference aribtrarily
if [[ ! -f $WORKDIR/reference.png ]]; then
    echo "[INFO] Website reference snapshot not found, creating one..."
    mv $WORKDIR/output.png $WORKDIR/reference.png
    echo "[INFO] Created 'reference.png' from 'output.png', exiting..."
    exit 0
fi

# What to do if there's a staging screenshot 
if [[ -f $WORKDIR/staging.png ]]; then
    echo "[INFO] Found website staging snapshot"

    if diff $WORKDIR/staging.png $WORKDIR/output.png ; then
        # Output is the same as staging
        echo "[INFO] Output snapshot is the same as the staging one, updating webpage reference snapshot and notifying..."

        send-notify
        if [[ LOGS -eq 1 ]]; then
           createLogs
        fi
        rm $WORKDIR/staging.png
        mv $WORKDIR/output.png $WORKDIR/reference.png
        exit 0
    fi
    # Output is different from staging
    echo "[INFO] Output snapshot is different from the staging one, deleting staging snapshot and checking reference snapshot..."
    rm $WORKDIR/staging.png
fi

# What to do if there's NOT a staging screenshot and ouput != reference
if ! diff $WORKDIR/output.png $WORKDIR/reference.png ; then
    echo "[INFO] Output is different from reference one, creating staging snapshot..."
    mv $WORKDIR/output.png $WORKDIR/staging.png
    exit 0
fi

# What to do if there's NOT a staging screenshot and output == reference
echo "[INFO] No difference found in latest snapshot, webpage is the same"
rm $WORKDIR/output.png
