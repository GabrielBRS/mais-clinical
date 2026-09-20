struct GRPCServer(Copyable):
    """Input adapter placeholder.

    Layer: transport/grpc
    Not started yet. Same use cases as HTTP will register here later.
    There is no official Modular gRPC framework in Mojo 1.0.
    """

    var port: UInt16

    def __init__(out self, port: UInt16):
        self.port = port

    def serve(self) raises:
        _ = self.port
        raise Error("grpc server ainda nao implementado")
