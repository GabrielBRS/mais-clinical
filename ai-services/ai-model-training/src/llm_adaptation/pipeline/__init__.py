from __future__ import annotations

import argparse

from llm_adaptation.pipeline.evaluate import evaluate_recipe
from llm_adaptation.pipeline.export import export_recipe
from llm_adaptation.pipeline.prepare import prepare_recipe
from llm_adaptation.pipeline.publish import publish_recipe
from llm_adaptation.pipeline.train import train_recipe
from llm_adaptation.recipe import Recipe, project_root


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(prog="llm-adaptation")
    parser.add_argument("command", choices=["prepare", "train", "evaluate", "export", "publish"])
    parser.add_argument("--recipe", required=True)
    parser.add_argument("--root", default=None)
    args = parser.parse_args(argv)
    root = project_root() if args.root is None else __import__("pathlib").Path(args.root)
    recipe = Recipe.load(args.recipe, root=root)
    dispatch = {
        "prepare": prepare_recipe,
        "train": train_recipe,
        "evaluate": evaluate_recipe,
        "export": export_recipe,
        "publish": publish_recipe,
    }
    result = dispatch[args.command](recipe)
    print(result)


__all__ = ["main", "evaluate_recipe", "export_recipe", "prepare_recipe", "publish_recipe", "train_recipe"]
