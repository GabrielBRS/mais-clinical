from application.application import Application, Health


struct GetHealthUseCase(Copyable):
    """Reads process health. Does not know HTTP or JSON."""

    @staticmethod
    def execute(app: Application) -> Health:
        return app.health()
