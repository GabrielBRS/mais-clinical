use crate::domain::detection::Box2;

#[derive(Clone, Debug)]
pub struct Track {
    pub id: i32,
    pub box2: Box2,
    pub age: u32,
    pub hits: u32,
    pub active: bool,
}
