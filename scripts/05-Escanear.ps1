. "$PSScriptRoot/Comun.ps1"
Start-Transcript -Path evidencias/reto-vulnerabilidades.log -Force
try {
    & docker.exe scout cves campus-api:1.0.0
    if ($LASTEXITCODE -ne 0) {
        Write-Output 'Scout no disponible; se utiliza Trivy, alternativa admitida por la guia.'
        Docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "${PWD}/evidencias:/report" -v campus-trivy-cache:/root/.cache/ aquasec/trivy:latest image --scanners vuln --format json --output /report/trivy.json campus-api:1.0.0
        $reporte = Get-Content evidencias/trivy.json -Raw | ConvertFrom-Json
        $reporte.Results | ForEach-Object { $_.Vulnerabilities } | Where-Object { $_ } | Select-Object VulnerabilityID,PkgName,InstalledVersion,FixedVersion,Severity | Format-Table -AutoSize
    }
} finally { Stop-Transcript }
