# k8s-actions-runner
Playground for a self-hosted GitHub action runner.

## Installation

- [Create a GitHub Personal Access Token](https://github.com/settings/tokens/new) with `repo` scope for private repos and `public_repo` scope for public repos.
  - Copy the provided Token, this is used to generate new runner's registration/removal tokens.
- Edit [base/secrets/secrets.env](base/secrets/secrets.env) file with the appropiate target repository and the previous created PAT.
- Install the actions runner:
```bash
kubectl apply -k base
```
