from llm_adaptation.evaluation.regression.quality import quality_regressed


def main() -> None:
    print(quality_regressed(0.7, 0.9))


if __name__ == "__main__":
    main()
