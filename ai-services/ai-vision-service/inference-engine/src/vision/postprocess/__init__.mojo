from vision.core.box import Box, Detection, iou


def _sort_score_desc(mut dets: List[Detection]):
    var i = 0
    while i < len(dets):
        var best = i
        var j = i + 1
        while j < len(dets):
            if dets[j].box.score > dets[best].box.score:
                best = j
            j += 1
        if best != i:
            var tmp = dets[i].copy()
            dets[i] = dets[best].copy()
            dets[best] = tmp^
        i += 1


def nms(
    var detections: List[Detection], iou_threshold: Float32
) -> List[Detection]:
    _sort_score_desc(detections)
    var kept = List[Detection]()
    var dead = List[UInt8](length=len(detections), fill=0)
    var i = 0
    while i < len(detections):
        if dead[i] == 0:
            kept.append(detections[i].copy())
            var j = i + 1
            while j < len(detections):
                if dead[j] == 0:
                    if (
                        iou(detections[i].box, detections[j].box)
                        > iou_threshold
                    ):
                        dead[j] = 1
                j += 1
        i += 1
    return kept^


def filter_score(dets: List[Detection], min_score: Float32) -> List[Detection]:
    var out = List[Detection]()
    for det in dets:
        if det.box.score >= min_score:
            out.append(det.copy())
    return out^


def decode_boxes(boxes: List[Box]) -> List[Detection]:
    var out = List[Detection](capacity=len(boxes))
    for box in boxes:
        out.append(Detection(box, "obj", -1))
    return out^
