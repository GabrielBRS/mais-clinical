use ai_data_engine::transform::apply;

fn main() {
    let text = "  hello\u{0007}   RAG   world  ";
    let out = apply(text, &["clean".into(), "normalize".into()]);
    println!("{out}");
}
