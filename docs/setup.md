# Development Setup

Install Nix before using the build targets. For example, the Determinate Systems installer is available at:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Clone the repository and create `.envrc`:

```bash
use flake "path:$PWD"

export NIX_HOST=<host>
export NIX_USER=<user>
```

Run hooks with `jj hook`. Install Lefthook only when committing with Git directly:

```bash
lefthook install
```
