#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
import urllib.request


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"Command failed: {' '.join(cmd)}\n{result.stderr}")
    return result.stdout.strip()


def get_remote_url() -> str:
    return run(["git", "remote", "get-url", "origin"])  # contains embedded token


def parse_owner_repo_and_token(remote_url: str):
    # Expected: https://x-access-token:TOKEN@github.com/OWNER/REPO(.git)?
    m = re.match(r"https?://x-access-token:([^@]+)@github\.com/([^/]+)/([^/.]+)(?:\.git)?", remote_url)
    if not m:
        raise ValueError("Could not parse token/owner/repo from remote URL")
    token, owner, repo = m.group(1), m.group(2), m.group(3)
    return token, owner, repo


def get_current_branch() -> str:
    return run(["git", "rev-parse", "--abbrev-ref", "HEAD"])  # e.g., feature-branch


def branch_exists(remote: str, branch: str) -> bool:
    out = run(["git", "ls-remote", "--heads", remote, branch])
    return bool(out)


def choose_base_branch(remote: str) -> str:
    # Prefer master (user request), fallback to main if master doesn't exist
    if branch_exists(remote, "master"):
        return "master"
    if branch_exists(remote, "main"):
        return "main"
    # Last resort: read remote HEAD symbolic ref
    try:
        show = run(["git", "remote", "show", remote])
        m = re.search(r"HEAD branch:\s*(\S+)", show)
        if m:
            return m.group(1)
    except Exception:
        pass
    return "master"  # default if unknown


def create_pr(token: str, owner: str, repo: str, head: str, base: str) -> dict:
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls"
    body = {
        "title": "Alien Shooter prototype for Roblox",
        "head": head,
        "base": base,
        "body": (
            "Adds a minimal top-down Alien Shooter prototype (server waves/combat, client camera/input/tracers, HUD, README).\n\n"
            "- Server: Bootstrap remotes, Combat validation/raycast, Enemy module, Wave spawner, Leaderstats\n"
            "- Client: Camera controller, Input + shoot, Tracer visuals, Crosshair, HUD\n"
            "- Shared: Tweakable Config\n"
        ),
        "maintainer_can_modify": True,
        "draft": False,
    }
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main():
    try:
        remote_url = get_remote_url()
        token, owner, repo = parse_owner_repo_and_token(remote_url)
        head = get_current_branch()
        base = choose_base_branch("origin")
        pr = create_pr(token, owner, repo, head, base)
        html_url = pr.get("html_url")
        if html_url:
            print(html_url)
            return 0
        print(json.dumps(pr))
        return 0
    except urllib.error.HTTPError as e:
        try:
            err = e.read().decode("utf-8")
            data = json.loads(err)
        except Exception:
            data = {"message": e.reason}
        # Handle common case: PR already exists
        if e.code == 422 and isinstance(data, dict) and "message" in data:
            # Attempt to point to compare page as fallback
            try:
                remote_url = get_remote_url()
                _, owner, repo = parse_owner_repo_and_token(remote_url)
                head = get_current_branch()
                base = choose_base_branch("origin")
                compare_url = f"https://github.com/{owner}/{repo}/compare/{base}...{head}?expand=1"
                print(f"PR may already exist. Compare page: {compare_url}")
                return 0
            except Exception:
                pass
        print(json.dumps(data))
        return 1
    except Exception as ex:
        print(f"Error: {ex}")
        return 1


if __name__ == "__main__":
    sys.exit(main())