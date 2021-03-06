$port = $env:port ?? 8080
$address = $env:address ?? "*"
$uri = $env:uri
$token = $env:token


$headers = @{
    "X-Pladder-Token" = $token
    "Content-Type"    = "text/plain; charset=utf-8"
}

try {
    $version = Get-Content version -Erroraction Stop
} catch {
    $version = "Unknown"
}

Function Initialize-PodeSettings() {
    Add-PodeEndpoint -Port $port -Protocol Http -Address $address

    Add-PodeLimitRule -Type IP -Values all -Limit 5 -Seconds 1

    $logger = New-PodeLoggingMethod -Terminal
    $logger | Enable-PodeRequestLogging
    $logger | Enable-PodeErrorLogging
}


Start-PodeServer -Threads 3 {

    Initialize-PodeSettings

    $routePostSnuska = Add-PodeRoute -PassThru -Method Post -Path '/snuska' -ContentType 'text/plain' -ScriptBlock {
        $data = $WebEvent.Data | Out-String
        $data = $data -replace '{|\[|\]|}|\$', ''
        $data = ($data[0..100] -join "").trim()

        $response = Invoke-RestMethod -Uri $using:uri -Method Post -Headers $using:headers -Body "snuska {$data}"
        Write-PodeTextResponse -Value $response
    }


    $routeGetSnusk = Add-PodeRoute -PassThru -Method Get -Path '/snusk' -ScriptBlock {
        $response = Invoke-RestMethod -Uri $using:uri -Method Post -Headers $using:headers -Body "snusk"
        Write-PodeTextResponse -Value $response
    }

    $routeGetTtd = Add-PodeRoute -PassThru -Method Get -Path '/ttd' -ScriptBlock {
        $response = Invoke-RestMethod -Uri $using:uri -Method Post -Headers $using:headers -Body "ttd"
        Write-PodeTextResponse -Value $response
    }

    $routeGetKackers = Add-PodeRoute -PassThru -Method Get -Path '/kackers' -ScriptBlock {
        $response = Invoke-RestMethod -Uri $using:uri -Method Post -Headers $using:headers -Body "get-cell kackers"
        Write-PodeTextResponse -Value "kackers $response`n"
    }

    # OpenAPI Stuff
    Enable-PodeOpenApi -Title "pladder-SnaaS" -Version $version -Path /openapi
    Enable-PodeOpenApiViewer -Type Swagger -Path / -OpenApiUrl /openapi -DarkMode

    Set-PodeOARouteInfo -Route $routeGetSnusk -Summary "Returns a freshly minted snusk from strutern"

    Set-PodeOARequest -Route $routePostSnuska -RequestBody (New-PodeOARequestBody -ContentSchemas @{ 'text/plain' = (New-PodeOAStringProperty -Name 'target' -MinLength 1 -MaxLength 100) })
    Set-PodeOARouteInfo -Route $routePostSnuska -Summary "Returns a freshly minted targeted snusk from strutern"

    Set-PodeOARouteInfo -Route $routeGetTtd -Summary "Returns a freshly minted OpenTTD-style Swedish town name"

    Set-PodeOARouteInfo -Route $routeGetKackers -Summary "Returns current value of ~kack"
}
