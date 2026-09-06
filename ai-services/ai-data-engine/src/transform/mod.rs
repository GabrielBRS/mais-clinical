mod aggregate;
mod clean;
mod enrich;
mod filter;
mod map;
mod normalize;
mod serialize;

pub use aggregate::join;
pub use clean::clean;
pub use enrich::tag;
pub use filter::drop_empty_lines;
pub use map::map_lines;
pub use normalize::normalize;
pub use serialize::to_json;

pub fn apply(text: &str, ops: &[String]) -> String {
    let mut out = text.to_owned();
    for op in ops {
        out = match op.as_str() {
            "normalize" => normalize::normalize(&out),
            "clean" => clean::clean(&out),
            _ => out,
        };
    }
    out
}
