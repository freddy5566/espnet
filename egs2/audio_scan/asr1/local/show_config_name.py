import argparse

from datasets import get_dataset_config_names

def get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset", type=str, default="formospeech/AudioSCAN-XTTSv2-female")
    parser.add_argument("--config-name-path", type=str, default="./local/config_name.txt")
    
    args = parser.parse_args()

    return args

if __name__ == "__main__":
    args = get_args()

    config_names = get_dataset_config_names(args.dataset)
    config_names = sorted(config_names)

    with open(args.config_name_path, "w", encoding="utf-8") as file:
        file.write("\n".join(config_names))
