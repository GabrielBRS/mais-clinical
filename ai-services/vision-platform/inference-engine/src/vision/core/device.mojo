@fieldwise_init
struct DeviceKind(Equatable, ImplicitlyCopyable, Writable):
    var _value: Int

    comptime cpu = Self(1)
    comptime gpu = Self(2)

    def name(self) -> String:
        if self == Self.cpu:
            return "cpu"
        if self == Self.gpu:
            return "gpu"
        return "unknown"

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())


@fieldwise_init
struct Device(Equatable, ImplicitlyCopyable, Writable):
    var kind: DeviceKind
    var index: Int32

    @staticmethod
    def cpu() -> Self:
        return Self(DeviceKind.cpu, 0)

    @staticmethod
    def gpu(index: Int32 = 0) -> Self:
        return Self(DeviceKind.gpu, index)

    def is_cpu(self) -> Bool:
        return self.kind == DeviceKind.cpu

    def is_gpu(self) -> Bool:
        return self.kind == DeviceKind.gpu

    def label(self) -> String:
        return String(self.kind, ":", self.index)

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.label())


def enumerate_devices() -> List[Device]:
    """Always include host CPU. GPU devices are probed by the gpu package."""
    var devices = List[Device](capacity=1)
    devices.append(Device.cpu())
    return devices^
