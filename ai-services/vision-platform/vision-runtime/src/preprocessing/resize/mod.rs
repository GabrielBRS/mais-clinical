use crate::domain::frame::Frame;

pub fn nearest(src: &Frame, width: u32, height: u32) -> Frame {
    let mut dst = Frame::zeros(width, height, src.channels);
    for y in 0..height {
        let sy = y * src.height / height;
        for x in 0..width {
            let sx = x * src.width / width;
            for c in 0..src.channels {
                let si = ((sy * src.width + sx) * u32::from(src.channels) + u32::from(c)) as usize;
                let di = ((y * width + x) * u32::from(src.channels) + u32::from(c)) as usize;
                dst.data[di] = src.data[si];
            }
        }
    }
    dst
}
