from llm_adaptation.pipeline import main

if __name__ == "__main__":
    main(["train", "--recipe", "recipes/qwen/continued_pretraining.yaml"])
