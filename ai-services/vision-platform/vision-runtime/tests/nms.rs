use vision_runtime::domain::detection::{Box2, Detection};
use vision_runtime::postprocessing::nms::nms;

#[test]
fn nms_drops_overlap() {
    let a = Detection {
        box2: Box2 {
            x: 0.0,
            y: 0.0,
            w: 10.0,
            h: 10.0,
            score: 0.9,
            class_id: 0,
        },
        label: "a".into(),
        track_id: -1,
    };
    let b = Detection {
        box2: Box2 {
            x: 1.0,
            y: 1.0,
            w: 10.0,
            h: 10.0,
            score: 0.5,
            class_id: 0,
        },
        label: "b".into(),
        track_id: -1,
    };
    let kept = nms(vec![a, b], 0.4);
    assert_eq!(kept.len(), 1);
}
