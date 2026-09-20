from llm_adaptation.evaluation.benchmark.baseline import delta


def main() -> None:
    print(delta({"f1": 0.8}, {"f1": 0.7}))


if __name__ == "__main__":
    main()
