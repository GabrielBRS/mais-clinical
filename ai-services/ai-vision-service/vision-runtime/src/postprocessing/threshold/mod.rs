use crate::domain::detection::Detection;

pub fn by_score(dets: Vec<Detection>, min: f32) -> Vec<Detection> {
    dets.into_iter().filter(|d| d.box2.score >= min).collect()
}
