# Juice Shop DevSecOps Pipeline

## [University of Piraeus](https://www.unipi.gr/en/home/) | [Department of Informatics](https://cs.unipi.gr/en/)
**MSc course**: Secure Programming

**Semester**: 2

**Project Completion Year**: 2025

## Project Overview

This project builds a complete **DevSecOps pipeline** around [OWASP Juice Shop](https://github.com/juice-shop/juice-shop), an intentionally vulnerable web application maintained by OWASP. The application code comes from the original project. Our work focuses on the security tooling around it: CI/CD workflows, containerised scanners, local Git hooks and security gates that stop insecure code from being merged, pushed or published.

Every push and pull request runs through secrets scanning, static analysis, dependency and container scanning, dynamic testing and a network scan. The Docker image is published to Docker Hub only when every check passes on `main`.

## Our Contributions

- **CI/CD pipeline** in GitHub Actions, built from reusable workflows that run in sequence, each one acting as a security gate.
- **Secrets scanning** with TruffleHog, both in CI and as a local `pre-push` hook.
- **Static analysis (SAST)** with Semgrep and SonarQube. SonarQube runs on a temporary server inside the CI job and the Quality Gate is enforced.
- **Container scanning** with Snyk on the locally built Docker image.
- **Dynamic testing (DAST)** with an authenticated OWASP ZAP baseline scan against the running application.
- **Network scanning** with Nmap, which fails the build if any port other than the allowed ones is open.
- **Docker setup**: application image, `docker-compose.test.yml` with a smoke test container, health checks and a custom Nmap image.
- **Local Git hooks**: a Semgrep `pre-commit` hook and a TruffleHog `pre-push` hook, installed with one script.
- **Automated Docker Hub publishing** of versioned and `latest` images after a successful pipeline on `main`.

## DevSecOps Pipeline

```
TruffleHog → SonarQube → Semgrep → Snyk → ZAP → Nmap → Docker Hub publish (main only)
```

| Stage | Tool | Type | Fails when |
|---|---|---|---|
| Secrets scan | TruffleHog | Secrets detection | Any secret is found |
| Static analysis | SonarQube (LTS Community) | SAST | The Quality Gate is not `OK` |
| Static analysis | Semgrep (`--config=auto`) | SAST | Any finding at error level |
| Container scan | Snyk | SCA / container | Vulnerabilities of high severity or above |
| Dynamic testing | OWASP ZAP baseline | DAST | The baseline scan reports alerts |
| Network scan | Nmap | Port policy | Open ports outside the allowed list (default `3000`) |
| Publish | Docker Buildx | Release | Runs only on `push` to `main` |

- **Triggers:** `push` and `pull_request` on all branches, plus manual runs (`workflow_dispatch`).
- **Reports:** Semgrep, Snyk and ZAP results (SARIF, JSON, HTML) and the Nmap scan output are uploaded as workflow artifacts.

## Technologies Used

- **CI/CD:** GitHub Actions (reusable workflows)
- **Containers:** Docker, Docker Compose, Docker Buildx, Docker Hub
- **Security tools:** TruffleHog, Semgrep, SonarQube, Snyk, OWASP ZAP, Nmap
- **Scripting:** Bash, `jq`, `curl`
- **Application:** OWASP Juice Shop (Node.js, TypeScript, Angular)

## Project Structure

Only the files added for the DevSecOps pipeline are listed:

```
/.github
    /workflows
        main.yml              # Main CI/CD pipeline, calls the workflows below in order
        trufflehog.yml        # Secrets scan
        sonarqube.yml         # SonarQube server + scanner, Quality Gate check
        semgrep.yml           # Semgrep SAST
        snyk.yml              # Snyk container scan
        zaproxy.yml           # Authenticated ZAP baseline scan
        nmap.yml              # Nmap open ports policy
        docker-publish.yml    # Docker Hub publishing
    /nmap
        Dockerfile            # Custom Nmap image
/.githooks
    pre-commit                # Semgrep on staged files
    pre-push                  # TruffleHog on the pushed commit range
/.zap
    rules.tsv                 # ZAP rule configuration
/scripts
    setup-git-hooks.sh        # Enables the local Git hooks
/test/smoke
    Dockerfile                # Smoke test container
docker-compose.test.yml       # App + smoke test for CI
```

## Required Secrets

Set these in the repository under **Settings → Secrets and variables → Actions**:

- **`SNYK_TOKEN`**: Snyk API token.
- **`DOCKERHUB_USERNAME`** and **`DOCKERHUB_TOKEN`**: Docker Hub credentials for publishing the image.

## Local Security Hooks

- **Setup:** Enable the hooks once per clone:

    ```bash
    bash scripts/setup-git-hooks.sh
    ```

- **pre-commit (Semgrep):**
  - Scans the staged code files with Semgrep (`semgrep/semgrep:latest`).
  - Blocks the commit on findings.
  - Writes reports to `.git/semgrep-precommit.{json,sarif}`.
- **pre-push (TruffleHog):**
  - Scans the exact commit range being pushed.
  - Blocks the push on findings.
  - Writes reports to `.git/trufflehog-prepush-<sha>.json`.
- **Skip temporarily (not recommended):**

    ```bash
    SKIP_SECURITY_HOOKS=1 git commit ...
    SKIP_SECURITY_HOOKS=1 git push ...
    ```

- **Prerequisites:** Docker must be available locally, because the hooks run the scanners as Docker images.

## Nmap Policy

- **Allowed ports:** `3000` by default, configurable in the Nmap workflow call in `main.yml`.
- **Artifacts:** CI writes `scan/nmap_open_ports.txt` and `scan/nmap_open_ports.xml`.
- **Enforcement:** CI parses `nmap_open_ports.txt` and fails if unexpected open ports are found.

## Contributors

<table>
  <tr>
    <td align="center"><a href="https://github.com/ApostolisSiampanis"><img src="https://avatars.githubusercontent.com/u/75365398?v=4" width="100px;" alt="Apostolis Siampanis"/><br /><sub><b>Apostolis Siampanis</b></sub></a><br /></td>
    <td align="center"><a href="https://github.com/thkox"><img src="https://avatars.githubusercontent.com/u/79880468?v=4" width="100px;" alt="Theodoros Koxanoglou"/><br /><sub><b>Theodoros Koxanoglou</b></sub></a><br /></td>
  </tr>
</table>

## Acknowledgments
This project was developed as part of the "Secure Programming" MSc course at the University of Piraeus. The application itself is [OWASP Juice Shop](https://github.com/juice-shop/juice-shop) by Björn Kimminich and the OWASP Juice Shop contributors. Contributions and feedback are always welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details. OWASP Juice Shop is also distributed under the MIT License.
