[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [object] $N,
    [Parameter()]
    [ValidateSet('fibonacci', 'factorial')]
    [string] $Operation = 'fibonacci'
)

function Get-ValidatedNonNegativeInteger {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object] $N
    )

    $isIntegerType = $N -is [sbyte] -or $N -is [byte] -or
        $N -is [int16] -or $N -is [uint16] -or
        $N -is [int32] -or $N -is [uint32] -or
        $N -is [int64] -or $N -is [uint64] -or
        $N -is [bigint]
    $isDigitString = $N -is [string] -and $N.Trim() -match '^\d+$'
    if (-not $isIntegerType -and -not $isDigitString) {
        throw 'N must be a non-negative integer.'
    }

    $text = [Convert]::ToString($N, [Globalization.CultureInfo]::InvariantCulture)
    [bigint] $index = 0
    if (-not [bigint]::TryParse($text.Trim(), [Globalization.NumberStyles]::None,
            [Globalization.CultureInfo]::InvariantCulture, [ref] $index)) {
        throw 'N must be a non-negative integer.'
    }

    return $index
}

function Get-Fibonacci {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object] $N
    )

    [bigint] $index = Get-ValidatedNonNegativeInteger $N

    [bigint] $previous = 0
    [bigint] $current = 1
    for ([bigint] $i = 0; $i -lt $index; $i = $i + 1) {
        [bigint] $next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $previous
}

function Get-Factorial {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object] $N
    )

    [bigint] $index = Get-ValidatedNonNegativeInteger $N
    [bigint] $result = 1
    for ([bigint] $i = 2; $i -le $index; $i = $i + 1) {
        $result = $result * $i
    }

    return $result
}

if ($MyInvocation.InvocationName -ne '.') {
    if ($null -eq $N) {
        throw 'N must be a non-negative integer.'
    }

    if ($Operation -eq 'fibonacci') {
        $value = Get-Fibonacci $N
        Write-Output "Fibonacci($N) = $value"
    }
    else {
        $value = Get-Factorial $N
        Write-Output "Factorial($N) = $value"
    }
}
