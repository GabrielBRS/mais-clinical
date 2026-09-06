struct Scratch:
    """Owned host scratch bytes. Replaces C++ PMR arenas with a Mojo List."""

    var storage: List[UInt8]

    def __init__(out self, bytes: Int = 0):
        if bytes <= 0:
            self.storage = List[UInt8]()
        else:
            self.storage = List[UInt8](length=bytes, fill=0)

    def name(self) -> String:
        return "monotonic-scratch"

    def byte_length(self) -> Int:
        return len(self.storage)
