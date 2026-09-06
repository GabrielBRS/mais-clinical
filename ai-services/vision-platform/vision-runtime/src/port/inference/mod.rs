use crate::domain::detection::Detection;
use crate::domain::frame::Frame;

pub trait Infer {
    fn detect(&self, frame: &Frame) -> Vec<Detection>;
}
