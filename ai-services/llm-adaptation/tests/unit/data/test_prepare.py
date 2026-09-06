from llm_adaptation.data import Message, Record
from llm_adaptation.data.cleaning import normalize, sanitize
from llm_adaptation.data.deduplication.exact import exact_key
from llm_adaptation.data.filtering import quality_ok
from llm_adaptation.data.formatting import format_instruction
from llm_adaptation.data.prepare import prepare_records
from llm_adaptation.data.tokenization import WordTokenizer, pack, truncate


def test_normalize_and_sanitize() -> None:
    assert normalize("  hello   world\n") == "hello world"
    assert "<tag>" not in sanitize("<tag>hi\x00")


def test_quality_rejects_repeat() -> None:
    assert not quality_ok("spam spam spam spam spam")


def test_prepare_dedupes() -> None:
    records = [
        Record(id="a", instruction="What is LoRA?", response="Low rank adapters."),
        Record(id="b", instruction="What is LoRA?", response="Low rank adapters."),
        Record(id="c", instruction="What is QLoRA?", response="Four bit base plus LoRA."),
    ]
    out = prepare_records(records)
    assert len(out) == 2
    assert exact_key(out[0].primary_text()) != exact_key(out[1].primary_text())


def test_format_and_tokenize() -> None:
    rec = Record(id="1", instruction="Hi", response="Hello there friend")
    text = format_instruction(rec)
    tok = WordTokenizer.fit([text])
    ids = truncate(tok.encode(text), 32)
    assert tok.decode(ids)
    assert pack([ids, ids], max_len=64, eos_id=tok.eos_id)


def test_chat_record() -> None:
    rec = Record(id="1", messages=[Message("user", "hello there world"), Message("assistant", "hi there friend")])
    assert prepare_records([rec])
