"""Typed request at the CLI/application boundary."""


struct HostRequest:
    var operation: String
    var recipe_path: String
    var root: String
    var device: String
    var dry_run: Bool
    var resume: Bool

    def __init__(out self):
        self.operation = ""
        self.recipe_path = ""
        self.root = "."
        self.device = "cpu"
        self.dry_run = False
        self.resume = False
