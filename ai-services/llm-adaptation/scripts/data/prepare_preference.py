from llm_adaptation.pipeline import prepare_recipe
from llm_adaptation.recipe import Recipe


def main() -> None:
    print(prepare_recipe(Recipe.load("recipes/qwen/dpo.yaml")))


if __name__ == "__main__":
    main()
