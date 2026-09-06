#[derive(Clone, Debug, PartialEq)]
pub struct Box2 {
    pub x: f32,
    pub y: f32,
    pub w: f32,
    pub h: f32,
    pub score: f32,
    pub class_id: i32,
}

impl Box2 {
    pub fn area(&self) -> f32 {
        self.w * self.h
    }

    pub fn iou(&self, other: &Box2) -> f32 {
        let x1 = self.x.max(other.x);
        let y1 = self.y.max(other.y);
        let x2 = (self.x + self.w).min(other.x + other.w);
        let y2 = (self.y + self.h).min(other.y + other.h);
        let inter = (x2 - x1).max(0.0) * (y2 - y1).max(0.0);
        let uni = self.area() + other.area() - inter;
        if uni <= 0.0 {
            0.0
        } else {
            inter / uni
        }
    }
}

#[derive(Clone, Debug)]
pub struct Detection {
    pub box2: Box2,
    pub label: String,
    pub track_id: i32,
}
