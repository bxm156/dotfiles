# Todoist CLI Fork & Maintenance Plan

**Date:** 2025-11-26
**Status:** Ready for Execution
**Recommendation:** PROCEED WITH FORK

---

## Executive Summary

After comprehensive research, **forking and maintaining sachaos/todoist is highly worthwhile**:

1. ✅ **No viable alternatives** - Only feature-complete Todoist CLI tool
2. ✅ **Essential to workflow** - Daily use for scripting, automation, fuzzy finders, offline use
3. ✅ **Complementary to MCP** - CLI for terminal/scripts, MCP for AI/Claude integration
4. ✅ **Active community** - 18 quality PRs waiting, 35 contributors, 1,600 stars
5. ✅ **Simple fix ready** - Issue #266 is null pointer bug, not memory leak (6-line fix in PR #271)
6. ✅ **Manageable with Claude Code** - Limited Go experience not a blocker

**Timeline:** Stable fork in 1 month, API v2 migration in 6 months (before Q4 2025 deadline)

---

## 1. Fork Strategy

### Repository Setup

**Name:** `todoist-cli`
**Binary:** `todoist` (backward compatible)
**Branding:** "Community-maintained Todoist CLI"

```bash
# Fork on GitHub UI: https://github.com/sachaos/todoist

# Clone and setup
git clone https://github.com/<your-username>/todoist-cli.git
cd todoist-cli

# Add upstream tracking
git remote add upstream https://github.com/sachaos/todoist.git
git remote set-url --push upstream DISABLE

# Create branches
git checkout -b develop
git checkout -b hotfix/sigsegv
git checkout -b feature/api-v2
```

### First Commits

1. **Update README.md** - Add fork notice and migration info
2. **Create FORK.md** - Document rationale and commitment
3. **Update go.mod** - Change module path to your fork

### Communication

**To Original Maintainer:**

```markdown
Hi @sachaos,

Thank you for this excellent CLI tool. Given maintenance challenges and the
upcoming API v1.0 migration deadline, I've created a community fork to:

1. Address critical stability issues (SIGSEGV #266)
2. Complete API v1.0 migration
3. Integrate valuable community PRs

This fork is a bridge, not a replacement. All improvements will be offered
back via PRs. I'm happy to discuss co-maintainership if you prefer.

Fork: https://github.com/<username>/todoist-cli

Looking forward to collaborating!
```

Wait 2 weeks for response, then proceed regardless.

---

## 2. Immediate Priorities (Weeks 1-4)

### Week 1: Critical Bug Fix

**Merge PR #271** - Fix SIGSEGV

```bash
git checkout -b hotfix/sigsegv-271
# Cherry-pick PR #271 (lib/item.go defensive nil checks)
# Add test case for non-ASCII labels
# Test on Linux, macOS, WSL

git checkout main
git merge --no-ff hotfix/sigsegv-271
git tag -a v0.22.1 -m "Fix SIGSEGV in list command (#271)"
git push origin main --tags
```

**Timeline:** 3 days
**Impact:** Immediate stability improvement

### Week 2: CI/CD Infrastructure

Create `.github/workflows/test.yml`:

```yaml
name: Test
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        go-version: ['1.23']
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
      - name: Test
        run: go test -v -race -coverprofile=coverage.txt ./...
      - name: Lint
        uses: golangci/golangci-lint-action@v3
      - name: Coverage
        uses: codecov/codecov-action@v3
```

Create `.github/workflows/release.yml`:

```yaml
name: Release
on:
  push:
    tags: ['v*.*.*']

permissions:
  contents: write
  packages: write

jobs:
  goreleaser:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'
      - uses: goreleaser/goreleaser-action@v5
        with:
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Week 3: Documentation

Create:

1. **CONTRIBUTING.md** - How to contribute, PR process, standards
2. **ARCHITECTURE.md** - Codebase structure, key files, data flow
3. **DEVELOPMENT.md** - Setup, testing, debugging, release process
4. **MIGRATION.md** - Guide for migrating from original

### Week 4: First Stable Release

**Release v0.23.0** with:

- SIGSEGV fix
- CI/CD automation
- Improved documentation
- 1-2 additional PRs (#241, #273)

---

## 3. PR Integration Workflow

### Prioritized PR List

**Immediate (Week 1-2):**

1. ✅ **#271** - Fix SIGSEGV (P0 - Critical, 6-line fix)
2. ✅ **#241** - Uncomment filter tests (P1 - Testing, easy win)

**Near-term (Week 3-6):**

1. **#273** - Simplify label logic (P1 - Code quality, 4 reactions)
2. **#260** - Add flags to completed list (P2 - Feature, 4 reactions)
3. **#238** - Add description support (P2 - Feature, 3 reactions)

**Deferred (Week 7+):**

1. **#267** - Section support (P2 - Major feature, needs API v2)
2. **#276** - Async operations (P3 - Complex UX improvement)
3. **#188** - Raw flag (P3 - Power user feature)

**Evaluate/Close:**

1. Old PRs (#94, #163, #172, #205, #206) - Ask for rebase or close

### Review Process

**For each PR:**

1. Acknowledge within 48 hours
2. Apply priority label
3. Technical review within 1 week
4. Test locally on multiple platforms
5. Merge decision within 2 weeks

---

## 4. API v2 Migration Strategy

### Timeline (24 weeks)

**Phase 1: Research & Design (Week 5-8)**

- Map Sync API v8 → REST API v2 endpoints
- Design abstraction layer
- Plan backward compatibility

**Phase 2: Implementation (Week 9-20)**

- Core endpoints (tasks, projects, labels)
- Advanced features (filters, sections, comments)
- Testing and polish

**Phase 3: Release (Week 21-24)**

- v1.0.0-beta.1 (Week 21)
- Release candidates (Week 22-23)
- v1.0.0 stable (Week 24)

**Target:** Q3 2025 (1 month before Todoist deadline)

### Technical Approach

Create API abstraction layer:

```go
// lib/api/interface.go
package api

type Client interface {
    GetTasks(ctx context.Context, filter string) ([]Task, error)
    CreateTask(ctx context.Context, task Task) (Task, error)
    UpdateTask(ctx context.Context, id string, updates TaskUpdate) (Task, error)
    CompleteTask(ctx context.Context, id string) error
    DeleteTask(ctx context.Context, id string) error
}

func NewClient(config Config) Client {
    if config.UseRESTAPI {
        return NewRESTClient(config)
    }
    return NewSyncClient(config)  // Legacy fallback
}
```

**Directory structure:**

```text
lib/api/
├── interface.go          # API interface
├── rest/
│   ├── client.go        # REST API v2 implementation
│   ├── tasks.go
│   ├── projects.go
│   └── models.go
├── sync/
│   ├── client.go        # Sync API v8 (legacy)
│   └── models.go
└── mapper/
    └── converter.go     # Convert between formats
```

### Key API Differences

| Feature | Sync API v8 | REST API v2 | Strategy |
|---------|-------------|-------------|----------|
| Task ID | Integer | String | Update structs |
| Sync | Incremental token | Pagination | New logic |
| Filters | Server-side | Client-side | Port or use API |
| Due dates | Complex object | ISO 8601 | Parsing layer |
| Labels | Separate sync | Embedded | Fetch separately |

---

## 5. Release Automation

### Enhanced GoReleaser Config

Update `.goreleaser.yml`:

```yaml
project_name: todoist-cli

builds:
  - id: todoist
    main: ./main.go
    binary: todoist
    env: [CGO_ENABLED=0]
    goos: [linux, darwin, windows]
    goarch: [amd64, arm64, arm]
    ldflags:
      - -s -w
      - -X main.Version={{.Version}}
      - -X main.Commit={{.Commit}}
      - -X main.Date={{.Date}}

archives:
  - format: tar.gz
    format_overrides:
      - goos: windows
        format: zip
    files:
      - LICENSE
      - README.md
      - CHANGELOG.md
      - completion/**/*

changelog:
  sort: asc
  groups:
    - title: Features
      regexp: "^feat:"
    - title: Bug Fixes
      regexp: "^fix:"
    - title: Performance
      regexp: "^perf:"

brews:
  - name: todoist-cli
    repository:
      owner: <your-username>
      name: homebrew-todoist-cli
    homepage: https://github.com/<your-username>/todoist-cli
    description: "Community-maintained Todoist CLI"

dockers:
  - image_templates:
      - "ghcr.io/{{.Env.GITHUB_REPOSITORY_OWNER}}/todoist-cli:{{.Tag}}"
      - "ghcr.io/{{.Env.GITHUB_REPOSITORY_OWNER}}/todoist-cli:latest"
```

### Version Strategy

```text
Current upstream: v0.22.0

Your progression:
v0.22.1 - SIGSEGV hotfix (Week 1)
v0.23.0 - First stable release (Week 4)
v0.24.0 - Community features (Week 8)
v0.25.0 - More features (Week 12)
v1.0.0-beta.1 - API v2 beta (Week 21)
v1.0.0 - API v2 stable (Week 24)
```

**Cadence:**

- **Patch:** As needed for critical bugs (days)
- **Minor:** Monthly for features
- **Major:** Breaking changes only (v1.0.0 for API v2)

---

## 6. Learning Go with Claude Code

### Essential Concepts (Week 1-4)

**Foundations:**

1. Error handling (`if err != nil`)
2. Structs and methods
3. Interfaces
4. Testing with `testing` package

**Project-Specific:**

1. Table-driven tests
2. Goroutines and channels
3. Context package
4. HTTP client (net/http)

### Learning Path

**Day 1-2:** Complete [A Tour of Go](https://go.dev/tour/) (3-4 hours)

**Day 3-4:** Read [Effective Go](https://go.dev/doc/effective_go)

**Day 5-7:** Explore codebase with Claude Code:

- "Walk me through how lib/sync.go works"
- "Explain this function line by line"
- "What patterns does this project use?"

**Week 2:** Implement small fix with guidance, write tests

### Using Claude Code Effectively

**Best Prompts:**

1. **Understanding:** "Explain what this code does line by line: [paste]"
2. **Review:** "Review this function for Go best practices: [paste]"
3. **Testing:** "Write table-driven tests for: [paste]"
4. **Debugging:** "Error: [error], Code: [code], What's wrong?"
5. **Learning:** "What's the idiomatic Go way to handle optional parameters?"

**Iterative Pattern:**

1. Understand existing code
2. Plan changes
3. Implement incrementally
4. Review and refine

---

## 7. Long-term Maintenance

### Time Commitment

- **Daily:** 15 minutes (monitor issues/PRs)
- **Weekly:** 3-5 hours (coding, reviews)
- **Monthly:** 2-3 hours (releases, updates)
- **Quarterly:** 4 hours (strategic planning)

**Total:** ~15-20 hours/month with Claude Code assistance

### Tasks

**Daily:**

- Check new issues (acknowledge within 24 hours)
- Apply labels
- Link related issues

**Weekly:**

- Review PRs
- Update roadmap
- Close stale issues
- Plan sprint

**Monthly:**

- Cut release
- Update CHANGELOG
- Write release notes
- Post update
- Review metrics

### Issue Labels

```text
Type: bug, feature, enhancement, documentation, question
Priority: P0-critical, P1-high, P2-medium, P3-low
Status: needs-reproduction, needs-info, confirmed, in-progress, blocked
Special: good-first-issue, help-wanted, upstream
```

### Feature Priorities

**Tier 1: Core** - Stability, API compatibility, performance, security

**Tier 2: User-Requested** - Sections, parent projects, descriptions, filtering

**Tier 3: Quality of Life** - Shell completion, JSON output, error messages, themes

**Tier 4: Power Features** - Backup/export, comments, plugins (post-v1.0)

---

## 8. Success Metrics

### Technical

- **Stability:** Zero SIGSEGV crashes in 3 releases (Month 2)
- **Coverage:** 60% → 70% → 80% (Months 1, 3, 6)
- **API Migration:** v1.0.0 by Q3 2025
- **Performance:** Sync <2s for 100 tasks

### Community

- **Issues:** <24h response, <14d closure, trending down
- **PRs:** 10 of 18 addressed in 3 months, >70% merge rate
- **Growth:** 100+ stars, 20+ forks, 500+ downloads per release in 3 months
- **Engagement:** 5+ contributors, active discussions, 1+ article in 6 months

### Quality

- Zero golangci-lint errors
- All code passes go vet
- Documentation for exported functions
- Monthly releases, 48h critical patches

---

## 9. Integration with Your Dotfiles

### Update .chezmoiexternal.toml.tmpl

```toml
# Current (line 263):
url = "https://github.com/sachaos/todoist/releases/download/v0.22.0/todoist_{{ $todoistOS }}_{{ $todoistArch }}.tar.gz"

# Future:
url = "https://github.com/<your-username>/todoist-cli/releases/download/v0.22.1/todoist_{{ $todoistOS }}_{{ $todoistArch }}.tar.gz"
```

### Update Tests

`tests/binaries/productivity-tools.bats`:

- Verify binary still works
- Update version check if needed

### Update Documentation

`EXTERNAL.md`:

- Change package source to fork
- Update description

**Note:** Claude command integration uses MCP server, no changes needed.

---

## 10. First Week Action Plan

### Day 1-2: Setup

```bash
# Fork on GitHub
# Clone locally
# Setup remotes
# Create branches
# Update README.md, FORK.md, go.mod
# Commit changes
```

### Day 3-4: Critical Fix

```bash
# Cherry-pick PR #271
# Add test for SIGSEGV
# Test on all platforms
# Release v0.22.1
```

### Day 5: CI/CD

```bash
# Create .github/workflows/test.yml
# Create .github/workflows/release.yml
# Test workflows
```

### Day 6: Communication

```bash
# Open issue on upstream
# Update dotfiles to use fork
# Test installation
```

### Day 7: Learning

```bash
# Start "A Tour of Go"
# Read lib/item.go with Claude
# Plan next week
```

---

## 11. Key Resources

### Documentation

- [Todoist REST API v2](https://developer.todoist.com/rest/v2)
- [Go Documentation](https://go.dev/doc/)
- [Effective Go](https://go.dev/doc/effective_go)
- [A Tour of Go](https://go.dev/tour/)
- [GoReleaser](https://goreleaser.com/)
- [GitHub Actions for Go](https://docs.github.com/en/actions/guides/building-and-testing-go)

### Community

- [Go Slack](https://invite.slack.golangbridge.org/)
- [r/golang](https://reddit.com/r/golang)
- [Go Forum](https://forum.golangbridge.org/)

### Tools

- [golangci-lint](https://golangci-lint.run/)
- [delve debugger](https://github.com/go-delve/delve)
- [pprof profiler](https://pkg.go.dev/net/http/pprof)

### Project Links

- **Original:** <https://github.com/sachaos/todoist>
- **Issue #266:** <https://github.com/sachaos/todoist/issues/266>
- **PR #271:** <https://github.com/sachaos/todoist/pull/271>
- **Open PRs:** <https://github.com/sachaos/todoist/pulls>
- **Open Issues:** <https://github.com/sachaos/todoist/issues>

---

## 12. Timeline Summary

### Month 1: Foundation

- **Week 1:** Fork, SIGSEGV fix, v0.22.1
- **Week 2:** CI/CD, testing
- **Week 3:** Documentation
- **Week 4:** v0.23.0 stable

### Month 2: Stabilization

- **Week 5-6:** Bug fixes (#228, #234)
- **Week 7-8:** PRs (#260, #238), v0.24.0

### Month 3: API Migration Start

- **Week 9-10:** API design
- **Week 11-12:** REST client starts

### Month 4-5: Implementation

- **Week 13-20:** Core migration
- Regular releases (v0.25.0, v0.26.0)

### Month 6: Testing & Release

- **Week 21:** v1.0.0-beta.1
- **Week 22-23:** Bug fixes
- **Week 24:** v1.0.0 stable 🎉

---

## Conclusion

**THIS FORK IS WORTH IT:**

1. ✅ No alternatives - Only viable Todoist CLI
2. ✅ Essential to workflow - Daily scripting/automation use
3. ✅ Complements MCP - Different use cases
4. ✅ Active community - 18 PRs, 35 contributors
5. ✅ Clear path - Simple fix, migration documented
6. ✅ Manageable scope - ~4K lines Go, mature codebase
7. ✅ Claude Code support - Limited Go not a blocker
8. ✅ Strategic timing - API deadline creates opportunity

**NEXT STEP:** Fork the repository and execute Week 1 plan.

**SUCCESS:** Stable, actively maintained CLI serving the community for years.

---

*Ready to execute. Good luck! 🚀*