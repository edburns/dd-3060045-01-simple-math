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

    It 'returns the expected representative value' {
        Get-Fibonacci 5 | Should -Be 5
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
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()

        $process.ExitCode | Should -Be 0
        $stdout.TrimEnd("`r", "`n") | Should -Be 'Fibonacci(5) = 5'
        ($stdout.TrimEnd("`r", "`n") -split "`r?`n").Count | Should -Be 1
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
