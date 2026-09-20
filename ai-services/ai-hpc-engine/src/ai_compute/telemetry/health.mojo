from ai_compute import VERSION
from ai_compute.core.status import Status


@fieldwise_init
struct Health(Copyable):
    var status: Status
    var version: String
    var ready: Bool


def check() -> Health:
    return Health(Status.ok(), VERSION, True)
