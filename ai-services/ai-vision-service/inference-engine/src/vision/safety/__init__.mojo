from vision.core.error import VisionError
from vision.core.status import StatusCode


def precondition(ok: Bool, what: String) raises VisionError:
    if ok:
        return
    raise VisionError(
        StatusCode.internal, String("precondition failed: ", what)
    )
