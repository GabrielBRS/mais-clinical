from llm_adaptation.data import TokenizedExample
from llm_adaptation.evaluation import evaluate
from llm_adaptation.evaluation.metrics import exact_match, token_f1
from llm_adaptation.model import ModelConfig, load_model


def test_generation_metrics() -> None:
    assert exact_match("a", "a") == 1.0
    assert token_f1("ace framing", "ace framing") == 1.0


def test_evaluate_dummy() -> None:
    metrics = evaluate(load_model(ModelConfig()), [TokenizedExample("1", [1, 2], [1, 2])])
    assert "loss" in metrics
    assert "perplexity" in metrics
