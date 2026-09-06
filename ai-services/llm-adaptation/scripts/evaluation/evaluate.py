from llm_adaptation.pipeline import main

if __name__ == "__main__":
    main(["evaluate", "--recipe", "recipes/qwen/sft_lora.yaml"])
