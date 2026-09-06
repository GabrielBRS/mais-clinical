pub fn map_lines(text: &str, f: impl Fn(&str) -> String) -> String {
    text.lines().map(f).collect::<Vec<_>>().join("\n")
}
