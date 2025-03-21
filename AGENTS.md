# Repository Guidelines
## Project Structure & Module Organization
- `sageattention/` hosts the public Python entry points (`core.py`, `quant.py`) and Triton kernels in `triton/`; keep high-level API updates here and guard architecture-specific dispatch branches.
- `csrc/` contains the shared CUDA headers and fused kernels used by the compiled extensions; mirror signature changes with the Python launch configs.
- `bench/` provides repeatable performance probes against FlashAttention variants; pair new kernels with companion benchmark scripts.
- `example/` offers integration smoke tests (e.g., `cogvideox-2b.py`) and is the canonical reference for replacing `torch.nn.functional.scaled_dot_product_attention`.
- `sageattention3_blackwell/` isolates Blackwell-optimized code paths; land changes here only after confirming parity with SageAttention2/2++.

## Build, Test, and Development Commands
- `source venv/bin/activate` enters the repo-maintained virtualenv (pre-provisioned in this fork); keep it active for all build, bench, and test commands.
- `./setup.sh` bootstraps the same `venv/` and reinstalls `requirements.txt`; rerun after adjusting PyTorch or Triton pins.
- `python setup.py install` builds the CUDA extensions for the active GPU architecture; export `MAX_JOBS=32 NVCC_APPEND_FLAGS="--threads 8"` when compiling large updates.
- `pip install -e .` (inside the activated venv) enables editable development while iterating on Python glue layers without rebuilding wheels.
- `python -m build` or `./build.sh` produces distributable wheels in `dist/` before publishing or wider testing.

## Coding Style & Naming Conventions
- Use 4-space indentation, snake_case functions, and concise module docstrings in Python; prefer explicit type hints for tensors and architecture flags.
- Keep Triton kernel names aligned with their launch parameters (`attn_qk_*`, `quant_*`) and document non-obvious tiling or smoothing choices inline.
- C++/CUDA headers in `csrc/` rely on UpperCamelCase for templates and SCREAMING_SNAKE_CASE for compile-time constants; maintain ≤100 character line lengths for readability.
- Group imports as stdlib, third-party, then local modules, and keep logging behind `warnings` or `torch` utilities instead of bare `print`.

## Testing Guidelines
- Run `python bench/bench_qk_int8_pv_fp8_cuda.py --pv_accum_dtype fp32+fp16 --quant_gran per_warp` to confirm throughput and numerical stability on Ada/Hopper GPUs; add variant scripts for new kernels.
- Validate functional changes via the example suite, e.g., `python example/cogvideox-2b.py --compile --attention_type sage`, ensuring loss parity against the baseline attention.
- When introducing Triton kernels, capture a minimal benchmark under `bench/` and record expected latency deltas in the pull request.
- Execute before/after measurements on the same GPU architecture and note CUDA driver versions alongside results.

## Commit & Pull Request Guidelines
- Use short, imperative commit subjects (e.g., `add sm90 pv tweaks`); include a body when the change spans both Python and CUDA layers to explain dependency order.
- Reference GitHub issues in PR descriptions (`Fixes #123`) and summarize performance and accuracy impact with concrete metrics or tables.
- Attach benchmark plots or screenshots for user-visible assets in `example/`; for kernel work, paste averaged latency and configuration flags.
- Request reviews from both Python and kernel maintainers when touching cross-cutting paths, and mark the PR ready only after rerunning the benchmarks above.

## GPU & Environment Notes
- Minimum environment: Python 3.9+, CUDA ≥ 12.0 (12.8 for Blackwell), and PyTorch 2.3+; the checked-in `venv/` tracks these pins—refresh with `./setup.sh` after changing GPU drivers.
- Export `EXT_PARALLEL`, `NVCC_APPEND_FLAGS`, and `MAX_JOBS` before rebuilds to keep compile times reasonable on multi-GPU hosts.
- Prefer `torch.cuda.get_device_capability()` over hard-coded `sm` values when adding runtime checks, and update `sageattention/core.py` dispatch tables accordingly.
