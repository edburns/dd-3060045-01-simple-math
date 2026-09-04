[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [object] $N
)

function Get-Fibonacci {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object] $N
    )

    $text = [Convert]::ToString($N, [Globalization.CultureInfo]::InvariantCulture)
    if ($N -is [bool] -or $text -notmatch '^\d+$') {
        throw 'N must be a non-negative integer.'
    }

    [int] $index = 0
    if (-not [int]::TryParse($text, [Globalization.NumberStyles]::None,
            [Globalization.CultureInfo]::InvariantCulture, [ref] $index)) {
        throw 'N must be a non-negative integer.'
    }

    [bigint] $previous = 0
    [bigint] $current = 1
    for ($i = 0; $i -lt $index; $i++) {
        $next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $previous
}

if ($MyInvocation.InvocationName -ne '.') {
    if ($null -eq $N) {
        throw 'N must be a non-negative integer.'
    }

    $value = Get-Fibonacci $N
    Write-Output "Fibonacci($N) = $value"
}
