# 💡 Contributing

Please feel free to open [issues] and [PRs], contributions are always welcome!

## 🛠️ Development Setup

Ready to contribute? Here’s how to set up your fork and get started with
development.

### ✅ `pre-commit` hooks

This project uses [`pre-commit`] to enforce automatic checks on commits.

You can see the config and all of the checks in the [`.pre-commit-config.yaml`]
file.

To install the pre-commit hook, please run `pre-commit install` from the root
of the repo. Once installed, `pre-commit` will do automatic checks on every
commit.

Note that there's also a [`pre-commit` GH Action] that will run the checks when
pushing changes or submitting PRs. For more details, check out the [`docs/`].

[PRs]: ../../pulls
[issues]: ../../issues
[`pre-commit`]: https://pre-commit.com
[`.pre-commit-config.yaml`]: .pre-commit-config.yaml
[`pre-commit` GH Action]: .github/workflows/pre-commit.yaml
[ `docs/`]: docs/README.md
