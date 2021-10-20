$port = $env:port ?? 8080
$address = $env:address ?? "*"
$uri = $env:uri
$token = $env:token


Start-PodeServer {
    Add-PodeEndpoint -Port $port -Protocol Http -Address $address

    Enable-PodeOpenApi -Title "pladder-SnaaS" -Version 1.0 -Path /openapi
    Enable-PodeOpenApiViewer -Type Swagger -Path / -OpenApiUrl /openapi

    Add-PodeRoute -Method Post -Path '/snuska' -ContentType 'text/plain' -ScriptBlock {
        $data = $WebEvent.Data | out-string
        $data = $data -replace '{|\[|\]|}|\$',''
        $data = $data[0..100] -join ""
        $data = $data.trim()
        Write-PodeTextResponse -Value (Invoke-RestMethod -Uri $using:uri -Method Post -Headers @{"X-Pladder-Token" = $using:token} -ContentType "text/plain; charset=utf-8" -Body "snuska $data")
    } -PassThru |
        Set-PodeOARequest -RequestBody (New-PodeOARequestBody -ContentSchemas @{ 'text/plain' = (New-PodeOAStringProperty -Name 'target' -MinLength 1 -MaxLength 100) }) -PassThru |
        Set-PodeOARouteInfo -Summary "Returns a freshly minted targeted snusk from strutern"

    Add-PodeRoute -Method Get -Path '/snusk' -ScriptBlock {
        Write-PodeTextResponse -Value (Invoke-RestMethod -Uri $using:uri -Method Post -Headers @{"X-Pladder-Token" = $using:token} -ContentType "text/plain; charset=utf-8" -Body "snusk")
    } -PassThru |
        Set-PodeOARouteInfo -Summary "Returns a freshly minted snusk from strutern"
}
