from vision.core.image import Image
from vision.preprocess import resize_nearest


def resize_nearest_kernel_cpu(
    src: Image, width: Int, height: Int
) raises -> Image:
    """Reference implementation of the portable resize algorithm.

    A GPU kernel with the same indexing (global x/y, coalesced HWC stores)
    belongs here when DeviceContext is available. Do not emit CUDA C++.
    """
    return resize_nearest(src, width, height)
