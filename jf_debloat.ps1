# Comprobar si se está ejecutando como administrador
$currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)

if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Si no está ejecutándose como administrador, reiniciar como administrador
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# Configurar PowerShell para usar UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Ruta del directorio donde se encuentra este script
$currentScriptPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Directorio de log donde se almacenarán los registros del proceso
$logFile = "$currentScriptPath\$(Get-Date -Format 'yyyyMMdd')_jf-debloat.log"

# Función para desinstalar aplicaciones usando winget o Remove-AppxPackage
function Uninstall-Applications {
    param (
        [array]$appIdsToUninstall
    )

    foreach ($appId in $appIdsToUninstall) {
        Write-Host "Intentando desinstalar: $appId"
        "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) Intentando desinstalar: $appId" | Out-File -FilePath $logFile -Append -Encoding UTF8

        # Primero, intentar desinstalar con winget
        try {
            $wingetResult = & winget uninstall --accept-source-agreements --disable-interactivity --id $appId 2>&1
            "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) Resultado winget: $wingetResult" | Out-File -FilePath $logFile -Append -Encoding UTF8

            # Verificar si winget no encontró la aplicación
            if ($wingetResult -match "No se encontr" -or $wingetResult -match "No package found") {
                Write-Host "$appId no encontrado con winget. Intentando Remove-AppxPackage..."
                "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) $appId no encontrado con winget. Intentando Remove-AppxPackage..." | Out-File -FilePath $logFile -Append -Encoding UTF8

                # Intentar desinstalar con Remove-AppxPackage para aplicaciones UWP
                try {
                    $appPattern = '*' + $appId + '*'
                    Get-AppxPackage -Name $appPattern -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) Desinstalado con Remove-AppxPackage: $appId" | Out-File -FilePath $logFile -Append -Encoding UTF8
                }
                catch {
                    $errorMessage = $_.Exception.Message
                    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) Error desinstalando con Remove-AppxPackage: $appId - $errorMessage" | Out-File -FilePath $logFile -Append -Encoding UTF8
                    Write-Host "Error desinstalando $appId con Remove-AppxPackage: $errorMessage"
                }

                # Intentar eliminar la aplicación provisionada para que no se reinstale en nuevos usuarios
                try {
                    Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $appPattern } | ForEach-Object { 
                        Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName 
                    }
                    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) Eliminado de imagen provisionada: $appId" | Out-File -FilePath $logFile -Append -Encoding UTF8
                }
                catch {
                    $errorMessage = $_.Exception.Message
                    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) Error eliminando de la imagen provisionada: $appId - $errorMessage" | Out-File -FilePath $logFile -Append
                    Write-Host "Error eliminando de la imagen provisionada: $appId - $errorMessage"
                }
            }
        }
        catch {
            $errorMessage = $_.Exception.Message
            "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) Error desinstalando $appId con winget: $errorMessage" | Out-File -FilePath $logFile -Append -Encoding UTF8
            Write-Host "Error desinstalando $appId con winget: $errorMessage"
        }
    }
}



# Lista de IDs de aplicaciones a desinstalar
$appIdsToUninstall = @(
    "Microsoft.OneDrive", 
    "Microsoft.DevHome",
    "Microsoft.Copilot",
    "Microsoft.YourPhone",
    "Microsoft.OutlookForWindows",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.3DBuilder",
    "Microsoft.BingNews",
    "Microsoft.BingFinance",
    "Microsoft.Microsoft3DViewer",
    "MicrosoftTeams",
    "MSTeams",
    "Clipchamp.Clipchamp",
    "Facebook",
    "Netflix",
    "Spotify"
)

# Ejecutar la función de desinstalación y registrar el proceso
Write-Host "Iniciando desinstalación de aplicaciones..."
Uninstall-Applications -appIdsToUninstall $appIdsToUninstall

Write-Host "Proceso completado. Registro guardado en $logFile"







   







