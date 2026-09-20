use crate::domain::detection::{Box2, Detection};
use crate::domain::frame::Frame;
use crate::port::inference::Infer;

pub struct BlobAdapter;

impl Infer for BlobAdapter {
    fn detect(&self, frame: &Frame) -> Vec<Detection> {
        if frame.data.iter().any(|b| *b > 128) {
            vec![Detection {
                box2: Box2 {
                    x: 0.0,
                    y: 0.0,
                    w: frame.width as f32,
                    h: frame.height as f32,
                    score: 0.9,
                    class_id: 0,
                },
                label: "blob".into(),
                track_id: -1,
            }]
        } else {
            Vec::new()
        }
    }
}
