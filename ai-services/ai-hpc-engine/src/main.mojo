from ai_compute.core import enumerate_devices
from ai_compute.telemetry.health import check


def main() raises:
    var health = check()
    print("ai-compute-engine", health.version, "ready=", health.ready)
    var devices = enumerate_devices()
    for device in devices:
        print("device", device.label())
