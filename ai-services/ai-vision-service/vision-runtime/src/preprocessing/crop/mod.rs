use crate::domain::frame::Frame;

pub fn crop(src: &Frame, x: u32, y: u32, w: u32, h: u32) -> Frame {
    let mut dst = Frame::zeros(w, h, src.channels);
    for yy in 0..h {
        for xx in 0..w {
            for c in 0..src.channels {
                let si = (((y + yy) * src.width + (x + xx)) * u32::from(src.channels) + u32::from(c)) as usize;
                let di = ((yy * w + xx) * u32::from(src.channels) + u32::from(c)) as usize;
                dst.data[di] = src.data[si];
            }
        }
    }
    dst
}
