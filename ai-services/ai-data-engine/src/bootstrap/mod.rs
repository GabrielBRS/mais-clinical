//! Composition root: único lugar que conhece implementações concretas.

mod app;
mod dependencies;

pub use app::{App, run};
