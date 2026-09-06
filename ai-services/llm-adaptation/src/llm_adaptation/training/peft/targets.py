DEFAULT_TARGETS = ("q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj")


def default_targets(family: str = "qwen") -> tuple[str, ...]:
    del family
    return DEFAULT_TARGETS
