use crate::domain::frame::Frame;

pub trait FrameSource {
    fn next_frame(&mut self) -> Option<Frame>;
}
