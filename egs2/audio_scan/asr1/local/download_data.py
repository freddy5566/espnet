import os
import argparse

from datasets import get_dataset_config_names, load_dataset

def get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset", type=str, default="formospeech/AudioSCAN-XTTSv2-female")
    parser.add_argument("--config-name", type=str, default="simple")
    parser.add_argument("--data-path", type=str, default="downloads")
    parser.add_argument("--speaker", type=str, default="XTTSv2-female")
    
    args = parser.parse_args()

    return args


if __name__ == "__main__":
    args = get_args()
    data_splits = ["train", "dev", "test"]

    dataset = load_dataset(args.dataset, args.config_name)

    train_dataset, test_dataset = dataset["train"], dataset["test"]
    train_dev_dataset = train_dataset.train_test_split(test_size=0.1)

    train_dataset = train_dev_dataset["train"]
    dev_dataset = train_dev_dataset["test"]

    datasets = [train_dataset, dev_dataset, test_dataset]

    for dataset, data_split in zip(datasets, data_splits):
        os.makedirs(f"{args.data_path}/{args.speaker}_{args.config_name}_{data_split}", exist_ok=True)

        with open(f"{args.data_path}/{args.speaker}_{args.config_name}_{data_split}/text.all", "w", encoding="utf-8") as transcript_file, \
            open(f"{args.data_path}/{args.speaker}_{args.config_name}_{data_split}/wav.scp.all", "w", encoding="utf-8") as wav_scp_file, \
            open(f"{args.data_path}/{args.speaker}_{args.config_name}_{data_split}/utt2spk.all", "w", encoding="utf-8") as utt2spk_file, \
            open(f"{args.data_path}/{args.speaker}_{args.config_name}_{data_split}/spk2utt.all", "w", encoding="utf-8") as spk2utt_file:

            for sample in dataset.iter(batch_size=1):
                path = sample["audio"][0]["path"]
                sample_id = path.split("/")[-1].split(".")[0]

                transcript_file.write(f"{sample_id} {sample['out'][0]}\n")
                wav_scp_file.write(f"{sample_id} {path}\n")
                utt2spk_file.write(f"{sample_id} {sample_id}\n")
                spk2utt_file.write(f"{sample_id} {sample_id}\n")
