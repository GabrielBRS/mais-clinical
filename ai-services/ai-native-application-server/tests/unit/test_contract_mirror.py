from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PYTHON_ROOT = ROOT / "ai-agent-contract" / "src"
PYTHON_PACKAGE = PYTHON_ROOT / "ai_orchestrator"
MOJO_ROOT = ROOT / "ai-agent-runtime" / "src" / "contracts"


def _module(path: Path) -> str:
    parts = list(path.relative_to(PYTHON_ROOT).with_suffix("").parts)
    if parts[-1] == "__init__":
        parts.pop()
    return ".".join(parts)


def test_every_python_contract_module_has_a_homologous_mojo_loader() -> None:
    python_files = sorted(PYTHON_PACKAGE.rglob("*.py"))
    mojo_loaders = {
        path.relative_to(MOJO_ROOT)
        for path in MOJO_ROOT.rglob("*.mojo")
        if path.name != "registry.mojo"
    }
    expected = {
        path.relative_to(PYTHON_ROOT).with_suffix(".mojo") for path in python_files
    }

    assert mojo_loaders == expected
    for python_file in python_files:
        loader = MOJO_ROOT / python_file.relative_to(PYTHON_ROOT).with_suffix(".mojo")
        assert f'Python.import_module("{_module(python_file)}")' in loader.read_text()


def test_registry_eagerly_loads_every_contract_module() -> None:
    registry = (MOJO_ROOT / "registry.mojo").read_text()
    modules = {_module(path) for path in PYTHON_PACKAGE.rglob("*.py")}

    assert registry.count("registry.store(") == len(modules)
    for module in modules:
        assert f'registry.store("{module}"' in registry
