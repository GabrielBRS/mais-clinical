from vision import VERSION
from vision.core.status import Status


@fieldwise_init
struct Health(Copyable):
    var status: Status
    var version: String
    var ready: Bool


def check() -> Health:
    return Health(Status.ok(), VERSION, True)
