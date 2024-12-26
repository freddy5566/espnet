#!/usr/bin/env bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

speaker=XTTSv2-female
dataset="formospeech/AudioSCAN-${speaker}"
config_name="filler_num2"
asr_tag="${speaker}_transformer_${config_name}"
datadir=data_${speaker}_${config_name}

CUDA_VISIBLE_DEVICES="0" ./asr.sh \
    --asr_stats_dir exp/${asr_tag} \
    --dumpdir dump/${asr_tag} \
    --asr_tag ${asr_tag} \
    --stage 1 --stop-stage 15 \
    --local_data_opts "--dataset ${dataset} --config-name ${config_name} --speaker ${speaker}" \
    --nj 16 \
    --inference_nj 16 \
    --lang ${config_name} \
    --token_type word \
    --asr_config conf/train_asr_transformer.yaml \
    --inference_config conf/decode_asr.yaml \
    --train_set ${speaker}_${config_name}_train \
    --valid_set ${speaker}_${config_name}_dev \
    --test_sets ${speaker}_${config_name}_test \
    --use_lm false "$@"

python3 local/calculate_exact_match.py \
    --ref exp/asr_${asr_tag}/decode_asr_asr_model_valid.acc.ave/${speaker}_${config_name}_test/score_wer/ref.trn \
    --hyp exp/asr_${asr_tag}/decode_asr_asr_model_valid.acc.ave/${speaker}_${config_name}_test/score_wer/hyp.trn
