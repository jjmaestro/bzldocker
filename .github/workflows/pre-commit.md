# [`pre-commit.yaml`]

Workflow to run `pre-commit` checks on relevant events in the repo to ensure
code quality and consistency.

The workflow will run all the checks specified in [`.pre-commit-config.yaml`].

## 🕹️ Triggers

The workflow is triggered by pushes to any branch (except `wip/**` branches) or
pull request to the `main` branch.

It can also be [triggered manually] via the [Actions web UI], the GH REST API
or the GH CLI tool, e.g.:

```sh
gh workflow run pre-commit
```

[Actions web UI]: https://github.com/jjmaestro/bzldocker/actions/workflows/build-docker-images.yaml
[`pre-commit.yaml`]: pre-commit.yaml
[`.pre-commit-config.yaml`]: ../../.pre-commit-config.yaml
[triggered manually]: https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#workflow_dispatch
