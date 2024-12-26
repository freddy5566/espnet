#!/usr/bin/env bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}
SECONDS=0

stage=1
stop_stage=100

datadir=./data
audio_scan_root=${datadir}/audio_scan
speaker=XTTSv2-female
dataset="formospeech/AudioSCAN-XTTSv2-female"
config_name="simple"
data_url=https://huggingface.co/datasets/${dataset}/resolve/main

log "$0 $*"
. utils/parse_options.sh

if [ $# -ne 0 ]; then
    log "Error: No positional arguments are required."
    exit 2
fi

. ./path.sh
. ./cmd.sh

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    log "stage 1: Data Download"
    mkdir -p ${datadir}

    python3 local/download_data.py \
        --dataset ${dataset} \
        --config-name ${config_name} \
        --data-path ${datadir} \
        --speaker ${speaker}
fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
    log "stage 2: Data Preparation"

    for dir in train dev test; do
        sort -u ${datadir}/${speaker}_${config_name}_${dir}/text.all > ${datadir}/${speaker}_${config_name}_${dir}/text
        sort -u ${datadir}/${speaker}_${config_name}_${dir}/utt2spk.all > ${datadir}/${speaker}_${config_name}_${dir}/utt2spk
        sort -u ${datadir}/${speaker}_${config_name}_${dir}/spk2utt.all > ${datadir}/${speaker}_${config_name}_${dir}/spk2utt
        sort -u ${datadir}/${speaker}_${config_name}_${dir}/wav.scp.all > ${datadir}/${speaker}_${config_name}_${dir}/wav.scp

        rm ${datadir}/${speaker}_${config_name}_${dir}/text.all
        rm ${datadir}/${speaker}_${config_name}_${dir}/utt2spk.all
        rm ${datadir}/${speaker}_${config_name}_${dir}/spk2utt.all
        rm ${datadir}/${speaker}_${config_name}_${dir}/wav.scp.all
    done
fi

log "Successfully finished. [elapsed=${SECONDS}s]"