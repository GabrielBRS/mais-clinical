@fieldwise_init
struct Box(Copyable, ImplicitlyCopyable):
    var x: Float32
    var y: Float32
    var w: Float32
    var h: Float32
    var score: Float32
    var class_id: Int

    def area(self) -> Float32:
        return self.w * self.h

    def x2(self) -> Float32:
        return self.x + self.w

    def y2(self) -> Float32:
        return self.y + self.h


@fieldwise_init
struct Detection(Copyable):
    var box: Box
    var label: String
    var track_id: Int


@fieldwise_init
struct Track(Copyable, ImplicitlyCopyable):
    var id: Int
    var box: Box
    var age: Int
    var hits: Int
    var active: Bool


def iou(a: Box, b: Box) -> Float32:
    var x1 = max(a.x, b.x)
    var y1 = max(a.y, b.y)
    var x2 = min(a.x2(), b.x2())
    var y2 = min(a.y2(), b.y2())
    var iw = max(Float32(0.0), x2 - x1)
    var ih = max(Float32(0.0), y2 - y1)
    var inter = iw * ih
    var uni = a.area() + b.area() - inter
    if uni <= Float32(0.0):
        return Float32(0.0)
    return inter / uni
