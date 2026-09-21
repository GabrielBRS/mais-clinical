from ai_orchestrator.domain.message import Message
from ai_orchestrator.domain.model import GenerationConfig
from ai_orchestrator.usecase.generate_response.command import GenerateCommand
from ai_orchestrator.usecase.generate_response.result import GenerateResult


class GenerateResponseUseCase:
    def __init__(self, llm) -> None:
        self._llm = llm

    def execute(self, command: GenerateCommand) -> GenerateResult:
        text = self._llm.generate([Message.user(command.prompt)], GenerationConfig())
        return GenerateResult(text)
