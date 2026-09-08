## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`
- `### 2. Add factorial and operation dispatch`

Apply these resolved decisions:

- The canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The repository workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that runner. Do not replace or bypass the runner.
- Direct CLI execution writes exactly one result line to stdout: `Fibonacci(N) = value` or `Factorial(N) = value`, according to the selected operation.
- `Get-Fibonacci` and `Get-Factorial` return only their numeric values, with no incidental output.
- Inputs are non-negative integers.
- This task starts only after task 1 is merged and must preserve task 1's Fibonacci behavior.
- The implementation and test files remain the repository-root files `math-tool.ps1` and `math-tool.Tests.ps1`.

No task-specific spike finding exists for this campaign. Implement from the plan's resolved contracts and the repository's production test infrastructure; do not copy or adapt spike source code.

## Branch and execution order

Use `experiment/shepherd-control` as the PR base branch. This is task 2 of 2 and depends on merged task 1. Tasks are assigned, completed, and merged serially in implementation order. Do not begin work until task 1 is merged and this issue is assigned.

## Implement

Extend repository-root `math-tool.ps1` with:

- A pure `Get-Factorial` function that computes factorial for non-negative integer `N` and emits only that numeric return value.
- An `Operation` parameter that dispatches between `fibonacci` and `factorial` while retaining the `N` parameter.
- Direct-script output of exactly `Fibonacci(N) = value` for Fibonacci and exactly `Factorial(N) = value` for factorial.
- Backward-compatible Fibonacci behavior from task 1, including direct execution that does not specify `Operation`.
- Explicit rejection of unsupported operation values rather than silently selecting an operation.

Extend repository-root `math-tool.Tests.ps1` using the existing production Pester suite. Add objective unit and isolated child-process coverage without replacing the task 1 tests:

- Unit-test factorial edge cases `N=0` and `N=1`, plus at least one small representative value such as `N=5`.
- Exercise both operation-dispatch paths in isolated child `pwsh` processes.
- Assert exact one-line stdout, successful exit, and no unexpected stderr for both operations.
- Retain the non-negative integer input checks and Fibonacci unit/CLI regression coverage introduced by task 1.
- Cover rejection of an unsupported operation value.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero for the combined regression suite.
- The pinned pull-request workflow using Pester 5.7.1 passes.
- `Get-Factorial 0` and `Get-Factorial 1` each return numeric `1`; the representative case `Get-Factorial 5` returns numeric `120`; none emit incidental output.
- An isolated factorial child process for `N=5` exits zero, writes exactly `Factorial(5) = 120` as its sole stdout result line, and writes no unexpected stderr.
- Isolated Fibonacci execution still exits zero and writes exactly the previously established Fibonacci result line, including the task 1 invocation form without an explicit `Operation`.
- Unsupported operations and invalid `N` values fail invocation rather than producing a result line.
- Existing task 1 tests remain in the combined suite and pass unchanged unless a narrowly necessary update is required to exercise the new parameter surface.

## Out of scope

- Do not change the Fibonacci algorithm or observable Fibonacci contract except where narrowly required to add dispatch.
- Do not add operations other than `fibonacci` and `factorial`.
- Do not modify the canonical runner or workflow, change the pinned Pester version, or add another test framework.
- Do not add unrelated files, dependencies, documentation, or refactors.
