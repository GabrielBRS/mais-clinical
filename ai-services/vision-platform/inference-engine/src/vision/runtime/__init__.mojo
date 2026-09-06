from vision.core.error import VisionError
from vision.core.status import StatusCode


@fieldwise_init
struct ModelSpec(Copyable):
    var id: String
    var backend: String
    var path: String


struct ModelRegistry:
    var _models: Dict[String, ModelSpec]

    def __init__(out self):
        self._models = Dict[String, ModelSpec]()

    def add(mut self, var spec: ModelSpec) raises VisionError:
        if spec.id.byte_length() == 0:
            raise VisionError(StatusCode.invalid_argument, "model.id vazio")
        if spec.id in self._models:
            raise VisionError(StatusCode.already_exists, "modelo ja registrado")
        self._models[spec.id] = spec^

    def find(self, id: String) raises VisionError -> ModelSpec:
        var found = self._models.get(id)
        if not found:
            raise VisionError(StatusCode.not_found, "modelo nao encontrado")
        return found.value().copy()

    def list(self) -> List[ModelSpec]:
        var models = List[ModelSpec](capacity=len(self._models))
        for item in self._models.items():
            models.append(item.value.copy())
        return models^


def pending_jobs() -> Int:
    return 0


def worker_count() -> Int:
    return 1


def max_batch() -> Int:
    return 8
