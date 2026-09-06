from ai_compute.core.error import EngineError
from ai_compute.core.model import Model
from ai_compute.core.status import StatusCode


struct ModelRegistry:
    var _models: Dict[String, Model]

    def __init__(out self):
        self._models = Dict[String, Model]()

    def register(mut self, var model: Model) raises EngineError:
        if model.id.byte_length() == 0:
            raise EngineError(StatusCode.invalid_argument, "model.id vazio")
        if model.id in self._models:
            raise EngineError(StatusCode.already_exists, "modelo ja registrado")
        self._models[model.id] = model^

    def unregister(mut self, id: String) raises EngineError:
        if id not in self._models:
            raise EngineError(StatusCode.not_found, "modelo nao encontrado")
        _ = self._models.pop(id)

    def get(self, id: String) raises EngineError -> Model:
        var found = self._models.get(id)
        if not found:
            raise EngineError(StatusCode.not_found, "modelo nao encontrado")
        return found.value().copy()

    def list(self) -> List[Model]:
        var models = List[Model](capacity=len(self._models))
        for item in self._models.items():
            models.append(item.value.copy())
        return models^
