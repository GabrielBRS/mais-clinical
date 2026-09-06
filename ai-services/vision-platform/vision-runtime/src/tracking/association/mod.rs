use crate::domain::detection::Detection;
use crate::domain::track::Track;

pub fn associate(tracks: &[Track], dets: &[Detection], iou_thresh: f32) -> Vec<(usize, usize)> {
    let mut pairs = Vec::new();
    let mut used_d = vec![false; dets.len()];
    let mut used_t = vec![false; tracks.len()];
    for (ti, track) in tracks.iter().enumerate() {
        let mut best = None;
        let mut best_iou = iou_thresh;
        for (di, det) in dets.iter().enumerate() {
            if used_d[di] {
                continue;
            }
            let iou = track.box2.iou(&det.box2);
            if iou > best_iou {
                best_iou = iou;
                best = Some(di);
            }
        }
        if let Some(di) = best {
            used_d[di] = true;
            used_t[ti] = true;
            pairs.push((ti, di));
        }
    }
    let _ = used_t;
    pairs
}
