from typing import List

import argparse

import evaluate

def get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()

    parser.add_argument("--ref", type=str, required=True)
    parser.add_argument("--hyp", type=str, required=True)

    args = parser.parse_args()

    return args


def get_text_from_file(file_path: str) -> List[str]:
    text = []
    with open(file_path, "r", encoding="utf-8") as file:
        text = file.readlines()
        text = list(map(lambda line: line.strip(), text))

    return text

if __name__ == "__main__":
    args = get_args()

    exact_match = evaluate.load("exact_match")

    hyp = get_text_from_file(args.hyp)
    ref = get_text_from_file(args.ref)

    print(exact_match.compute(predictions=hyp, references=ref))