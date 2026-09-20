from __future__ import annotations

import argparse

from vision_training.training.classification.trainer import train_classifier
from vision_training.export.onnx.export import export_onnx


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(prog="vision-training")
    parser.add_argument("command", choices=["train", "evaluate", "export", "benchmark"])
    parser.add_argument("--recipe", default="recipes/classification/dummy.yaml")
    args = parser.parse_args(argv)
    if args.command == "train":
        print(train_classifier(args.recipe))
    elif args.command == "export":
        print(export_onnx(args.recipe))
    else:
        print({"command": args.command, "recipe": args.recipe})
