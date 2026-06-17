# Kargo Demo

Demo repository for the talk **"GitOps is not enough: taming environment promotion in Kubernetes with Kargo"**

presented at [Voxxed Days Luxembourg](https://voxxeddays.com/luxembourg/) — Tool in Action (25 min)

---

## What this is

A minimal but realistic end-to-end promotion pipeline:

```
GitHub Actions (CI)
       │  builds image, pushes to GHCR with SHA digest
       ▼
  Kargo Warehouse
       │  detects new Freight (image digest)
       ▼
  Stage: dev  ──── auto-promote ──── smoke test
       │
       ▼
  Stage: staging ── auto-promote ── integration test
       │
       ▼
  Stage: prod ───── 🔐 manual approval required
```

Everything is Kubernetes-native. No shell scripts. No Slack messages. No manual PRs.

---

## Repository structure

```
.
├── app/                        # Sample Go HTTP application
│   ├── main.go
│   └── Dockerfile
├── manifests/                  # Kustomize manifests per environment
│   ├── base/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── kargo/                      # Kargo CRDs
│   ├── warehouse.yaml
│   ├── stages.yaml
│   └── analysis-template.yaml
├── argocd/                     # Argo CD Application CRDs
│   ├── app-dev.yaml
│   ├── app-staging.yaml
│   └── app-prod.yaml
└── .github/workflows/
    └── build-push.yaml         # CI: build + push on every push to main
```

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| `kind` | ≥ 1.28 | `brew install kind` |
| `kubectl` | latest | `brew install kubectl` |
| `helm` | ≥ 3.13 | `brew install helm` |
| `argocd` CLI | ≥ 2.10 | `brew install argocd` |
| `kargo` CLI | ≥ 0.9 | `brew install akuity/tap/kargo` |


## Key concepts

| Concept | What it is |
|---------|-----------|
| **Warehouse** | Watches artifact sources (GHCR). Emits Freight when a new image digest is detected. |
| **Freight** | Immutable snapshot: image SHA-256 digest + git commit. The unit of promotion. |
| **Stage** | A target environment (dev / staging / prod). Holds a subscription and the current Freight. |
| **Promotion** | The act of advancing Freight from one Stage to the next, with verification steps. |
| **AnalysisTemplate** | Argo Rollouts resource used by Kargo to run automated verification gates. |

---

## Why image digests, not tags?

Image tags like `:latest` or `:v1.2.3` are **mutable** — the same tag can point to a different image after a push. Kargo always resolves tags to their immutable SHA-256 digest at Freight creation time, so you have a guarantee that what passed dev is exactly what gets promoted to prod.


---

## References

- [Kargo documentation](https://docs.kargo.io)
- [Kargo GitHub](https://github.com/akuity/kargo)
- [Argo CD](https://argo-cd.readthedocs.io)
- [Argo Rollouts Analysis](https://argoproj.github.io/argo-rollouts/features/analysis)
- [Flux image automation](https://fluxcd.io/flux/guides/image-update)