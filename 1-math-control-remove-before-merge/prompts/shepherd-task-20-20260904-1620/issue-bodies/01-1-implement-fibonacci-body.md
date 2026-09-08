## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`

Apply these resolved decisions:

- The canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The repository workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that runner. Do not replace or bypass the runner.
- Direct CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value`.
- `Get-Fibonacci` returns only the numeric value, with no incidental output.
- Inputs are non-negative integers.
- The implementation and test files are the repository-root files `math-tool.ps1` and `math-tool.Tests.ps1`.

No task-specific spike finding exists for this campaign. Implement from the plan's resolved contracts and the repository's production test infrastructure; do not copy or adapt spike source code.

## Branch and execution order

Use `experiment/shepherd-control` as the PR base branch. This is task 1 of 2. Tasks are assigned, completed, and merged serially in implementation order. Do not begin work until this issue is assigned. Task 2 may begin only after this task is merged into the base branch.

## Implement

Create repository-root `math-tool.ps1` with:

- A parameter named `N` that accepts non-negative integers.
- A pure `Get-Fibonacci` function that computes the Fibonacci value for `N` and emits only that numeric return value.
- Direct-script behavior that invokes the function and writes exactly `Fibonacci(N) = value` to stdout.

Create repository-root `math-tool.Tests.ps1` with:

- Dot-sourced Pester unit tests for `Get-Fibonacci`.
- Unit coverage for `N=0`, `N=1`, and at least one small representative value such as `N=5`.
- Isolated child-`pwsh` process tests for direct CLI behavior. These tests must execute `math-tool.ps1` as a script rather than relying on state in the Pester process.
- Assertions for the exact one-line stdout contract and successful process exit.
- Coverage proving negative and non-integer inputs are rejected, consistent with the non-negative integer input contract.

Keep the implementation deterministic and independent of network access or external runtime dependencies.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero.
- The pinned pull-request workflow using Pester 5.7.1 passes.
- Unit tests establish `Get-Fibonacci 0` returns numeric `0`, `Get-Fibonacci 1` returns numeric `1`, and the representative case returns the expected numeric value without extra pipeline output.
- An isolated child process for `N=5` exits zero, writes exactly `Fibonacci(5) = 5` as its sole stdout result line, and writes no unexpected stderr.
- Invalid negative and non-integer input tests fail invocation rather than producing a Fibonacci result.
- `math-tool.ps1` and `math-tool.Tests.ps1` are introduced together, as required by the repository-owned runner.

## Out of scope

- Do not implement factorial or operation dispatch; those belong to task 2.
- Do not modify the canonical runner or workflow, change the pinned Pester version, or add another test framework.
- Do not add unrelated files, dependencies, documentation, or refactors.
- Do not assign or start any later campaign issue.
