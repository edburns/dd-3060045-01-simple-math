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
        Get-Fibonacci 1 | Should -Be 1
    }

    It 'returns 5 for N=5' {
        Get-Fibonacci 5 | Should -Be 5
    }

    It 'returns 55 for N=10' {
        Get-Fibonacci 10 | Should -Be 55
    }

    It 'rejects negative and non-integer inputs' {
        { Get-Fibonacci -1 } | Should -Throw
        { Get-Fibonacci 1.5 } | Should -Throw
    }
}

Describe 'math-tool.ps1 CLI' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot 'math-tool.ps1'
        $pwshPath = (Get-Command pwsh).Source
    }

    It 'writes exactly one result line for N=5 and exits successfully' {
        $startInfo = [Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $pwshPath
        $startInfo.ArgumentList.Add('-NoLogo')
        $startInfo.ArgumentList.Add('-NoProfile')
        $startInfo.ArgumentList.Add('-File')
        $startInfo.ArgumentList.Add($scriptPath)
        $startInfo.ArgumentList.Add('-N')
        $startInfo.ArgumentList.Add('5')
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.UseShellExecute = $false

        $process = [Diagnostics.Process]::new()
        $process.StartInfo = $startInfo
        $process.Start() | Should -BeTrue
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        [Threading.Tasks.Task]::WhenAll($stdoutTask, $stderrTask).Wait()
        $stdout = $stdoutTask.Result
        $stderr = $stderrTask.Result

        $process.ExitCode | Should -Be 0
        $stdout | Should -Be "Fibonacci(5) = 5$([Environment]::NewLine)"
        $stderr | Should -Be ''
    }

    It 'rejects invalid inputs without producing a result' {
        foreach ($invalid in @('-1', '1.5')) {
            $output = & $pwshPath -NoLogo -NoProfile -File $scriptPath -N $invalid 2>&1
            $LASTEXITCODE | Should -Not -Be 0
            ($output -join "`n") | Should -Not -Match '^Fibonacci\('
        }
    }
}
