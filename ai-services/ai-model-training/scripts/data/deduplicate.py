from llm_adaptation.data.ingestion import load_records
from llm_adaptation.data.prepare import dedupe, prepare_records


def main() -> None:
    print(len(dedupe(prepare_records(load_records("data/sft")))))


if __name__ == "__main__":
    main()
