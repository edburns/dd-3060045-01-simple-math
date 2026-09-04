BeforeAll {
    . (Join-Path $PSScriptRoot 'math-tool.ps1')
}

Describe 'Get-Fibonacci' {
    It 'returns zero for N=0' {
        $result = @(Get-Fibonacci 0)

        $result | Should -HaveCount 1
        $result[0] | Should -Be 0
        $result[0].GetType().IsValueType | Should -BeTrue
    }

    It 'returns one for N=1' {
        $result = @(Get-Fibonacci 1)

        $result | Should -HaveCount 1
        $result[0] | Should -Be 1
    }

    It 'returns 5 for N=5' {
        $result = @(Get-Fibonacci 5)

        $result | Should -HaveCount 1
        $result[0] | Should -Be 5
    }

    It 'returns 55 for N=10' {
        $result = @(Get-Fibonacci 10)

        $result | Should -HaveCount 1
        $result[0] | Should -Be 55
    }

    It 'rejects negative and non-integer inputs' {
        { Get-Fibonacci '-1' } | Should -Throw
        { Get-Fibonacci 1.0 } | Should -Throw
        { Get-Fibonacci 1.5 } | Should -Throw
    }
}

Describe 'Get-Factorial' {
    It 'returns one for N=0' {
        $result = @(Get-Factorial 0)

        $result | Should -HaveCount 1
        $result[0] | Should -Be 1
    }

    It 'returns one for N=1' {
        $result = @(Get-Factorial 1)

        $result | Should -HaveCount 1
        $result[0] | Should -Be 1
    }

    It 'returns 120 for N=5' {
        $result = @(Get-Factorial 5)

        $result | Should -HaveCount 1
        $result[0] | Should -Be 120
    }

    It 'rejects negative and non-integer inputs' {
        { Get-Factorial '-1' } | Should -Throw
        { Get-Factorial 1.0 } | Should -Throw
        { Get-Factorial 1.5 } | Should -Throw
    }
}

Describe 'math-tool.ps1 CLI' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot 'math-tool.ps1'
        $pwshPath = (Get-Command pwsh).Source

        function Invoke-MathToolProcess {
            param(
                [Parameter(Mandatory = $true)]
                [string] $N,
                [string] $Operation
            )

            $startInfo = [Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $pwshPath
            $startInfo.ArgumentList.Add('-NoLogo')
            $startInfo.ArgumentList.Add('-NoProfile')
            $startInfo.ArgumentList.Add('-File')
            $startInfo.ArgumentList.Add($scriptPath)
            $startInfo.ArgumentList.Add('-N')
            $startInfo.ArgumentList.Add($N)
            if ($PSBoundParameters.ContainsKey('Operation')) {
                $startInfo.ArgumentList.Add('-Operation')
                $startInfo.ArgumentList.Add($Operation)
            }
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.UseShellExecute = $false

            $process = [Diagnostics.Process]::new()
            $process.StartInfo = $startInfo
            $process.Start() | Out-Null
            $stdoutTask = $process.StandardOutput.ReadToEndAsync()
            $stderrTask = $process.StandardError.ReadToEndAsync()
            $exitTask = $process.WaitForExitAsync()
            [Threading.Tasks.Task]::WhenAll($exitTask, $stdoutTask, $stderrTask).Wait()

            return [pscustomobject]@{
                ExitCode = $process.ExitCode
                StdOut = $stdoutTask.Result
                StdErr = $stderrTask.Result
            }
        }
    }

    It 'writes exactly one result line for N=5 and exits successfully' {
        $result = Invoke-MathToolProcess -N '5'

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "Fibonacci(5) = 5$([Environment]::NewLine)"
        $result.StdErr | Should -Be ''
    }

    It 'writes exactly one factorial result line for N=5 and exits successfully' {
        $result = Invoke-MathToolProcess -N '5' -Operation 'factorial'

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "Factorial(5) = 120$([Environment]::NewLine)"
        $result.StdErr | Should -Be ''
    }

    It 'dispatches fibonacci in an isolated child process' {
        $result = Invoke-MathToolProcess -N '8' -Operation 'fibonacci'

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "Fibonacci(8) = 21$([Environment]::NewLine)"
        $result.StdErr | Should -Be ''
    }

    It 'dispatches factorial in an isolated child process' {
        $result = Invoke-MathToolProcess -N '4' -Operation 'factorial'

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "Factorial(4) = 24$([Environment]::NewLine)"
        $result.StdErr | Should -Be ''
    }

    It 'rejects invalid inputs without producing a result' {
        foreach ($invalid in @('-1', '1.5')) {
            $output = & $pwshPath -NoLogo -NoProfile -File $scriptPath -N $invalid 2>&1
            $LASTEXITCODE | Should -Not -Be 0
            $outputText = ($output -join "`n")
            $outputText | Should -Not -Match '^Fibonacci\('
            $outputText | Should -Not -Match '^Factorial\('
        }
    }

    It 'rejects unsupported operations via parameter validation without producing a result' {
        $output = & $pwshPath -NoLogo -NoProfile -File $scriptPath -N 5 -Operation unsupported 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        $outputText = ($output -join "`n")
        $outputText | Should -Not -Match '^(Fibonacci|Factorial)\('
    }
}
