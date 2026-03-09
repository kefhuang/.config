#!/usr/bin/env python3
import argparse
import concurrent.futures
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


DEFAULT_TIMEOUT_SECONDS = 300


def parse_args():
    parser = argparse.ArgumentParser(
        description="Consult Codex, Claude, and Gemini in parallel."
    )
    parser.add_argument(
        "--question",
        required=True,
        help="Question or viewpoint to send to all providers.",
    )
    context_group = parser.add_mutually_exclusive_group()
    context_group.add_argument(
        "--context-file",
        help="Optional file containing a prebuilt context brief.",
    )
    context_group.add_argument(
        "--context-stdin",
        action="store_true",
        help="Read the context brief from stdin.",
    )
    parser.add_argument(
        "--timeout-seconds",
        type=int,
        default=DEFAULT_TIMEOUT_SECONDS,
        help=f"Per-provider timeout in seconds (default: {DEFAULT_TIMEOUT_SECONDS}).",
    )
    return parser.parse_args()


def read_context(context_file, context_stdin):
    if context_file:
        path = Path(context_file)
        if not path.is_file():
            raise FileNotFoundError(f"context file not found: {context_file}")
        return path.read_text().strip()

    if context_stdin:
        if sys.stdin.isatty():
            raise ValueError("--context-stdin requires piped stdin")
        stdin_text = sys.stdin.read()
        return stdin_text.strip()

    return ""


def git_summary(cwd):
    try:
        subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--git-dir"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            text=True,
        )
    except subprocess.CalledProcessError:
        return "not a git repository"

    branch = subprocess.run(
        ["git", "-C", cwd, "branch", "--show-current"],
        check=False,
        capture_output=True,
        text=True,
    ).stdout.strip() or "detached"
    changes = subprocess.run(
        ["git", "-C", cwd, "status", "--porcelain"],
        check=False,
        capture_output=True,
        text=True,
    ).stdout.splitlines()
    return f"branch={branch}, changes={len(changes)}"


def build_prompt(question, context, cwd, repo_summary):
    context_block = context or "No additional context was supplied."
    return f"""## Consultation Request

You are one of three independent technical reviewers. The other two reviewers are also analyzing this same request separately.

### Environment
Current working directory: {cwd}
Git summary: {repo_summary}

### Context
{context_block}

### Question
{question}

### Constraints
- You may read local context, search, or web fetch if your CLI allows it.
- Do not modify files.
- Do not run shell commands or take actions for the user.
- Be direct. Agreement without analysis is not useful.

### Response Format
Return plain text with these exact headings:
Verdict:
Key Reasons:
Risks:
Alternatives:
Assumptions:
Confidence:
"""


def text_from_json_payload(payload):
    fragments = []

    def visit(value):
        if isinstance(value, str):
            stripped = value.strip()
            if stripped:
                fragments.append(stripped)
        elif isinstance(value, list):
            for item in value:
                visit(item)
        elif isinstance(value, dict):
            for key in ("text", "message", "content", "output", "response", "result"):
                if key in value:
                    visit(value[key])

    visit(payload)
    return "\n".join(fragment for fragment in fragments if fragment)


def provider_result(name, status, response="", error="", returncode=None):
    return {
        "status": status,
        "response": response.strip(),
        "error": error.strip(),
        "returncode": returncode,
        "provider": name,
    }


def ensure_command(name):
    if shutil.which(name):
        return
    raise FileNotFoundError(f"{name} CLI not found in PATH")


def run_codex(prompt, cwd, timeout_seconds, temp_dir):
    ensure_command("codex")
    output_path = Path(temp_dir) / "codex.txt"
    command = [
        "codex",
        "exec",
        "-s",
        "read-only",
        "--ephemeral",
        "-C",
        cwd,
        "-o",
        str(output_path),
        "-",
    ]
    completed = subprocess.run(
        command,
        input=prompt,
        capture_output=True,
        text=True,
        timeout=timeout_seconds,
        check=False,
    )
    if completed.returncode != 0:
        return provider_result(
            "codex",
            "failed",
            error=completed.stderr or completed.stdout or "codex exec failed",
            returncode=completed.returncode,
        )
    if not output_path.exists():
        return provider_result(
            "codex",
            "failed",
            error="codex exec succeeded but produced no output file",
            returncode=completed.returncode,
        )
    return provider_result("codex", "ok", response=output_path.read_text(), returncode=0)


def run_claude(prompt, cwd, timeout_seconds):
    ensure_command("claude")
    env = os.environ.copy()
    env.pop("CLAUDECODE", None)
    env.pop("CLAUDE_CODE_ENTRYPOINT", None)
    command = [
        "claude",
        "-p",
        "--permission-mode",
        "plan",
        "--no-session-persistence",
        "--allowed-tools",
        "Read,Glob,Grep,WebFetch,WebSearch",
    ]
    completed = subprocess.run(
        command,
        input=prompt,
        capture_output=True,
        text=True,
        timeout=timeout_seconds,
        check=False,
        cwd=cwd,
        env=env,
    )
    if completed.returncode != 0:
        return provider_result(
            "claude",
            "failed",
            error=completed.stderr or completed.stdout or "claude print failed",
            returncode=completed.returncode,
        )
    return provider_result("claude", "ok", response=completed.stdout, returncode=0)


def run_gemini(prompt, cwd, timeout_seconds):
    ensure_command("gemini")
    env = os.environ.copy()
    env.setdefault("SEATBELT_PROFILE", "permissive-open")
    command = [
        "gemini",
        "-s",
        "-p",
        prompt,
        "--output-format",
        "json",
    ]
    completed = subprocess.run(
        command,
        capture_output=True,
        text=True,
        timeout=timeout_seconds,
        check=False,
        cwd=cwd,
        env=env,
    )
    if completed.returncode != 0:
        return provider_result(
            "gemini",
            "failed",
            error=completed.stderr or completed.stdout or "gemini non-interactive run failed",
            returncode=completed.returncode,
        )

    response_text = completed.stdout.strip()
    if response_text:
        try:
            payload = json.loads(response_text)
        except json.JSONDecodeError:
            pass
        else:
            extracted = text_from_json_payload(payload)
            if extracted:
                response_text = extracted
    return provider_result("gemini", "ok", response=response_text, returncode=0)


def run_provider(name, prompt, cwd, timeout_seconds, temp_dir):
    try:
        if name == "codex":
            return run_codex(prompt, cwd, timeout_seconds, temp_dir)
        if name == "claude":
            return run_claude(prompt, cwd, timeout_seconds)
        if name == "gemini":
            return run_gemini(prompt, cwd, timeout_seconds)
        raise ValueError(f"unknown provider: {name}")
    except subprocess.TimeoutExpired:
        return provider_result(name, "failed", error=f"{name} timed out")
    except Exception as exc:  # noqa: BLE001
        return provider_result(name, "failed", error=str(exc))


def main():
    args = parse_args()
    cwd = os.getcwd()

    try:
        context = read_context(args.context_file, args.context_stdin)
    except Exception as exc:  # noqa: BLE001
        print(json.dumps({"error": str(exc)}))
        return 1

    repo_summary = git_summary(cwd)
    prompt = build_prompt(args.question, context, cwd, repo_summary)
    providers = {}

    with tempfile.TemporaryDirectory(prefix="consult-skill-") as temp_dir:
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
            future_map = {
                executor.submit(
                    run_provider,
                    provider_name,
                    prompt,
                    cwd,
                    args.timeout_seconds,
                    temp_dir,
                ): provider_name
                for provider_name in ("codex", "claude", "gemini")
            }
            for future in concurrent.futures.as_completed(future_map):
                result = future.result()
                providers[result["provider"]] = result

    failed_providers = sorted(
        provider_name
        for provider_name, result in providers.items()
        if result["status"] != "ok"
    )
    successful_providers = sorted(
        provider_name
        for provider_name, result in providers.items()
        if result["status"] == "ok"
    )

    output = {
        "question": args.question,
        "context_summary": context,
        "cwd": cwd,
        "git_summary": repo_summary,
        "providers": providers,
        "successful_providers": successful_providers,
        "failed_providers": failed_providers,
    }
    print(json.dumps(output, indent=2))
    return 0 if len(failed_providers) <= 1 else 1


if __name__ == "__main__":
    raise SystemExit(main())
