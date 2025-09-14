# juice-shop

## DevSecOps Pipeline

- **Platforms**: GitHub Actions (CI), local Git hooks (pre-commit, pre-push)
- **Static Analysis**: Semgrep, SonarQube (Quality Gate enforced), Snyk
- **Secrets Scan**: TruffleHog (CI and pre-push hook)
- **Dynamic Tests**: ZAP (DAST), Nmap (open ports policy)
- **Docker**: All tools and the app run in containers

## CI Triggers & Gates

- **Triggers**: Runs on `push` and `pull_request` for all branches.
- **Fail Conditions**:
  - **Semgrep**: Fails on findings (error level), uploads SARIF to code scanning.
  - **Snyk**: Fails on High vulnerabilities (local image build is scanned), uploads SARIF.
  - **SonarQube**: Quality Gate must be OK.
  - **ZAP**: Baseline scan fails on alerts (no ignore flag).
  - **Nmap**: Fails if open ports are not in the allowed list (default `3000`).
  - **TruffleHog**: Fails on any detected secret.

## Required Secrets

- **`SNYK_TOKEN`**: Set in repository “Settings → Secrets and variables → Actions”.

## Local Security Hooks

- **Setup**: Enable hooks once per clone.
  - Run: `bash scripts/setup-git-hooks.sh`
- **pre-commit (Semgrep)**:
  - Scans staged code files with Semgrep (`semgrep/semgrep:latest`).
  - Blocks the commit on findings.
  - Outputs reports under `.git/semgrep-precommit.{json,sarif}`.
- **pre-push (TruffleHog)**:
  - Scans the exact commit range being pushed with TruffleHog.
  - Blocks the push on findings.
  - Outputs reports under `.git/trufflehog-prepush-<sha>.json`.
- **Skip Temporarily (not recommended)**:
  - `SKIP_SECURITY_HOOKS=1 git commit ...`
  - `SKIP_SECURITY_HOOKS=1 git push ...`
- **Prerequisites**: Docker available locally (hooks run scanners via Docker images).

## Nmap Policy

- **Allowed ports**: `3000` by default (configurable in the Nmap workflow call).
- **Artifacts**: CI writes `scan/nmap_open_ports.txt` and `scan/nmap_open_ports.xml`.
- **Enforcement**: CI step parses `nmap_open_ports.txt` and fails if unexpected open ports are found.

## Tips

- **Branch Protection**: Require CI checks to pass on `main` to block insecure merges.
- **Speed**: Run heavy DAST locally only when needed; hooks run quick checks before CI.
