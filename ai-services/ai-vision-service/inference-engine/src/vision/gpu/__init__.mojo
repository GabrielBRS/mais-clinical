from vision.core.image import Image
from vision.preprocess import resize_nearest


def device_count() -> Int:
    """Portable probe. A later GPU spec can replace this with DeviceContext."""
    return 0


def device_tensor() -> Bool:
    return False


def pooled_bytes() -> Int:
    return 0


def graphs_enabled() -> Bool:
    return False


def resize_nearest_gpu(src: Image, width: Int, height: Int) raises -> Image:
    """Generic nearest-neighbor. GPU launch is opt-in when an accelerator exists.
    """
    # Portable algorithm lives on the host until DeviceContext is wired.
    # Vendor specialization (NVIDIA/AMD) is out of scope until measured.
    return resize_nearest(src, width, height)
