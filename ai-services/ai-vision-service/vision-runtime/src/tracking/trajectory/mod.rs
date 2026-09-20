use crate::domain::detection::Box2;

pub fn centroid(box2: &Box2) -> (f32, f32) {
    (box2.x + box2.w * 0.5, box2.y + box2.h * 0.5)
}
