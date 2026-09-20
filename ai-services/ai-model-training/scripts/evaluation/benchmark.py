from llm_adaptation.evaluation.benchmark import run_harness


def main() -> None:
    print(run_harness([("ACE1 framing", "ACE1 framing")]))


if __name__ == "__main__":
    main()
