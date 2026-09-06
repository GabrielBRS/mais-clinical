use crate::domain::detection::Detection;

pub fn nms(mut dets: Vec<Detection>, iou_thresh: f32) -> Vec<Detection> {
    dets.sort_by(|a, b| b.box2.score.total_cmp(&a.box2.score));
    let mut kept = Vec::new();
    let mut dead = vec![false; dets.len()];
    for i in 0..dets.len() {
        if dead[i] {
            continue;
        }
        kept.push(dets[i].clone());
        for j in (i + 1)..dets.len() {
            if !dead[j] && dets[i].box2.iou(&dets[j].box2) > iou_thresh {
                dead[j] = true;
            }
        }
    }
    kept
}
