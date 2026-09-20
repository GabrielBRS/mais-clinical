from __future__ import annotations

from llm_adaptation.data import Message


def render_chat(messages: list[Message], template: str = "chatml") -> str:
    if template in {"chatml", "qwen"}:
        return "".join(f"<|im_start|>{m.role}\n{m.content}<|im_end|>" for m in messages)
    if template in {"llama3", "llama"}:
        parts = ["<|begin_of_text|>"]
        for message in messages:
            parts.append(
                f"<|start_header_id|>{message.role}<|end_header_id|>\n{message.content}<|eot_id|>"
            )
        return "".join(parts)
    if template == "mistral":
        rendered = ""
        for message in messages:
            if message.role == "user":
                rendered += f"[INST] {message.content} [/INST]"
            else:
                rendered += f" {message.content}</s>"
        return rendered
    return "\n".join(f"{m.role}: {m.content}" for m in messages)
