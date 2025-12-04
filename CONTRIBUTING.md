# Contributing to GrindCompanion

## Commit Message Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated semantic versioning and changelog generation.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: A new feature (triggers MINOR version bump)
- **fix**: A bug fix (triggers PATCH version bump)
- **perf**: Performance improvement (triggers PATCH version bump)
- **refactor**: Code refactoring (triggers PATCH version bump)
- **docs**: Documentation only changes (no release)
- **style**: Code style changes (formatting, no logic change, no release)
- **test**: Adding or updating tests (no release)
- **build**: Build system or dependency changes (no release)
- **ci**: CI configuration changes (no release)
- **chore**: Other changes that don't modify src files (no release)

### Breaking Changes

Add `BREAKING CHANGE:` in the footer or append `!` after the type to trigger a MAJOR version bump:

```
feat!: remove deprecated API

BREAKING CHANGE: The old API has been removed
```

### Examples

```
feat(combat): add support for pet damage tracking

fix(display): correct currency formatting for large values

perf(loot): optimize item cache lookup

docs(readme): update installation instructions

refactor(session): simplify data structure
```

## Pull Request Guidelines

When creating a pull request:

1. **PR Title**: Must follow the conventional commit format (e.g., `feat: add new feature`)
2. **Commit Messages**: All commits in the PR should follow conventional commit format
3. **Validation**: Automated checks will verify your PR title and commit messages
4. If validation fails, update your PR title or commit messages accordingly

You can bypass PR validation by adding the `ignore-semantic-pr` label (maintainers only).

## Release Process

Releases are fully automated via GitHub Actions when commits are pushed to the `main` branch:

1. Commit messages are analyzed to determine version bump
2. Version is updated in `GrindCompanion.toc` and `package.json`
3. `CHANGELOG.md` is generated/updated
4. Addon is packaged as a zip file
5. Git tag and GitHub release are created
6. Release assets are uploaded to GitHub
7. Addon is automatically uploaded to CurseForge

No manual intervention required!
