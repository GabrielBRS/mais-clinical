@fieldwise_init
struct ExecuteAgentCommand(Copyable):
    var agent_id: String
    var prompt: String
    var retrieve: Bool
    var backend: String


@fieldwise_init
struct ExecuteWorkflowCommand(Copyable):
    var prompt: String
