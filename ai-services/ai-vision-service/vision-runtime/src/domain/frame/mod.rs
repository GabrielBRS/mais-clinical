#[derive(Clone, Debug)]
pub struct Frame {
    pub width: u32,
    pub height: u32,
    pub channels: u8,
    pub data: Vec<u8>,
}

impl Frame {
    pub fn zeros(width: u32, height: u32, channels: u8) -> Self {
        let n = (width * height * u32::from(channels)) as usize;
        Self {
            width,
            height,
            channels,
            data: vec![0; n],
        }
    }
}
