# Todoist CLI Fork - Quick Start Guide

**Date:** 2025-11-26
**Purpose:** Fast reference for getting started with forking and maintaining todoist CLI

---

## TL;DR - Is This Worth It?

**YES ✅** - sachaos/todoist is the ONLY viable Todoist CLI. No alternatives exist.

- Issue #266 is NOT a memory leak (null pointer bug, 6-line fix ready)
- 1,600 stars, active community, 18 quality PRs waiting
- MCP server and CLI are complementary (different use cases)
- 6-month timeline to API v2 migration with Claude Code help
- 15-20 hours/month sustainable maintenance

**Bottom line:** Fork it, fix it, maintain it. The community needs you.

---

## First Week Checklist

### Day 1-2: Repository Setup

```bash
# 1. Fork on GitHub
# Visit https://github.com/sachaos/todoist
# Click "Fork" button

# 2. Clone your fork
git clone https://github.com/<your-username>/todoist-cli.git
cd todoist-cli

# 3. Setup remotes
git remote add upstream https://github.com/sachaos/todoist.git
git remote set-url --push upstream DISABLE

# 4. Create branches
git checkout -b develop
git checkout main
git checkout -b hotfix/sigsegv
```

### Day 3-4: Critical SIGSEGV Fix

```bash
# Cherry-pick PR #271 fix
git checkout hotfix/sigsegv
# Apply 6-line fix to lib/item.go (defensive nil check)

# Test
go test -v ./...
go build
./todoist list  # Should not crash

# Merge and tag
git checkout main
git merge --no-ff hotfix/sigsegv
git tag -a v0.22.1 -m "Fix SIGSEGV in list command (#271)"
git push origin main --tags
```

### Day 5: CI/CD Setup

Create `.github/workflows/test.yml` and `.github/workflows/release.yml`
(See full plan for complete YAML configs)

### Day 6: Communication

```markdown
# Open issue on https://github.com/sachaos/todoist/issues

Hi @sachaos,

I've created a community fork to address maintenance backlog and API v1.0
migration. All improvements will be offered back. Happy to discuss
co-maintainership.

Fork: https://github.com/<your-username>/todoist-cli
```

### Day 7: Learning & Planning

- Start [A Tour of Go](https://go.dev/tour/)
- Read `lib/item.go` with Claude Code
- Plan Week 2 work

---

## Quick Reference Commands

### Development

```bash
# Run tests
go test -v -race ./...

# Build binary
go build -o todoist

# Run linter
golangci-lint run

# Test coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Release

```bash
# Create release
git tag -a v0.X.Y -m "Description"
git push origin v0.X.Y

# Local test release
goreleaser release --snapshot --clean
```

### With Claude Code

```text
"Explain what this function does: [paste code]"
"Review this for Go best practices: [paste code]"
"Write tests for this function: [paste code]"
"What's the idiomatic Go way to [task]?"
```

---

## Priority PR Integration

**Week 1-2:**

1. ✅ #271 - Fix SIGSEGV (6 lines, critical)
2. ✅ #241 - Filter tests (easy win)

**Week 3-6:**

1. #273 - Label logic (code quality)
2. #260 - Completed list flags (feature)
3. #238 - Description support (feature)

**Defer:**

- #267 - Sections (needs API v2)
- #276 - Async ops (complex)

---

## Update Your Dotfiles

Once fork is stable:

```toml
# .chezmoiexternal.toml.tmpl line 263
# Change from:
url = "https://github.com/sachaos/todoist/releases/download/v0.22.0/..."

# To:
url = "https://github.com/<your-username>/todoist-cli/releases/download/v0.22.1/..."
```

---

## Key Resources

**Essential:**

- [A Tour of Go](https://go.dev/tour/) - Start here!
- [Effective Go](https://go.dev/doc/effective_go) - Idioms and patterns
- [Todoist REST API v2](https://developer.todoist.com/rest/v2) - API migration target

**Tools:**

- [GoReleaser Docs](https://goreleaser.com/)
- [golangci-lint](https://golangci-lint.run/)

**Project:**

- [Original Repo](https://github.com/sachaos/todoist)
- [Issue #266](https://github.com/sachaos/todoist/issues/266)
- [PR #271 (Fix)](https://github.com/sachaos/todoist/pull/271)

---

## 6-Month Roadmap

### Month 1: Foundation

- Week 1: Fork, SIGSEGV fix, v0.22.1
- Week 2: CI/CD, testing
- Week 3: Documentation
- Week 4: v0.23.0 stable

### Month 2: Stabilization

- Merge PRs #273, #260, #238
- Fix additional bugs
- v0.24.0 release

### Month 3-5: API Migration

- Design abstraction layer
- Implement REST API v2 client
- Maintain Sync API fallback
- Regular releases

### Month 6: API v2 Release

- Week 21: v1.0.0-beta.1
- Week 22-23: Bug fixes
- Week 24: v1.0.0 stable 🎉

---

## Success Metrics

**Technical:**

- Zero SIGSEGV crashes (Month 2)
- 60% → 80% test coverage (6 months)
- v1.0.0 by Q3 2025

**Community:**

- 100+ stars in 3 months
- 5+ contributors in 6 months
- <24h issue response time

---

## Time Commitment

- **Daily:** 15 min (monitor issues/PRs)
- **Weekly:** 3-5 hours (coding, reviews)
- **Monthly:** 2-3 hours (releases, updates)
- **Quarterly:** 4 hours (planning)

**Total:** ~15-20 hours/month with Claude Code assistance

---

## Why CLI + MCP Server Both Matter

**CLI Use Cases:**

- Shell scripting/automation
- Quick terminal adds
- Fuzzy finder integration (fzf)
- Offline functionality
- CI/CD pipelines
- Deterministic operations (no AI experimentation)

**MCP Server Use Cases:**

- AI-powered natural language queries
- Claude Code integration
- Intelligent task filtering
- Conversational interaction

**Verdict:** Complementary tools, not redundant.

---

## Common Questions

**Q: Is sachaos/todoist abandoned?**
A: No - last release December 2024. Just needs more active maintenance.

**Q: Are there alternatives?**
A: No. This is the ONLY Todoist CLI for end users.

**Q: Is #266 a memory leak?**
A: No - it's a null pointer dereference. Simple fix ready in PR #271.

**Q: Do I need Go experience?**
A: Not much - Claude Code can help. Start with "A Tour of Go" (3-4 hours).

**Q: How long to stable fork?**
A: 1 month to stable, 6 months to API v2 migration.

**Q: What if upstream objects?**
A: Unlikely (MIT license, respectful approach). Offer collaboration.

**Q: What about long-term sustainability?**
A: 15-20 hrs/month, automation, good docs, recruit co-maintainer after 1 year.

---

## Next Action

**Right now:** Fork the repository on GitHub
**Then:** Execute Day 1-2 checklist above
**Questions?** Read the full plan at `docs/plans/2025-11-26-todoist-cli-fork-plan.md`

---

*Quick start guide compiled: 2025-11-26*
*You've got this! 🚀*