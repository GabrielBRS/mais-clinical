from .tensor import Tensor


@fieldwise_init
struct GenerationParams(Copyable):
    var max_tokens: Int32
    var temperature: Float32
    var top_p: Float32

    def __init__(out self):
        self.max_tokens = 256
        self.temperature = 1.0
        self.top_p = 1.0


struct Request(Copyable):
    var model_id: String
    var inputs: List[Tensor]
    var prompt: String
    var texts: List[String]
    var documents: List[String]
    var generation: GenerationParams

    def __init__(out self, var model_id: String = ""):
        self.model_id = model_id^
        self.inputs = List[Tensor]()
        self.prompt = ""
        self.texts = List[String]()
        self.documents = List[String]()
        self.generation = GenerationParams()
