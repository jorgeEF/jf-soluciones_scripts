# Set-ExecutionPolicy Unrestricted

# Configuración inicial
if ($Host.Name -eq 'ConsoleHost') {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}

# Cargar ensamblado de Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# --- MEJORA ESTÉTICA: Activar estilos visuales modernos ---
[System.Windows.Forms.Application]::EnableVisualStyles()

# Crear formulario
$form = New-Object System.Windows.Forms.Form
$form.Text = "JF-Soluciones - Apps Installer"
$form.Size = [System.Drawing.Size]::new(800, 700)
$form.StartPosition = "CenterScreen"
# --- MEJORA ESTÉTICA: Usar fuente moderna y añadir espaciado general ---
$form.Font = [System.Drawing.Font]::new("Segoe UI", 9)
$form.Padding = [System.Windows.Forms.Padding]::new(10)

# Lista de aplicaciones categorizadas
$appCategories = @{
	IA = @(
		"ElementLabs.LMStudio",
		"Ollama.Ollama"
	)
	Internet = @(
        "Google.Chrome",
		"Google.GoogleDrive",
		"Mozilla.Firefox.es-AR",
		"Syncthing.Syncthing",
		"Tailscale.Tailscale",
        "qBittorrent.qBittorrent",
		"Discord.Discord"		
    )
	Multimedia = @(                
        "Audacity.Audacity",
		"Google.EarthPro",
		"HandBrake.HandBrake",
		"CodecGuide.K-LiteCodecPack.Standard",		
		"KDE.Kdenlive",
		"dotPDN.PaintDotNet",
		"Stellarium.Stellarium",
		"Nikse.SubtitleEdit",
		"VideoLAN.VLC"
    )
	Oficina = @(
		"7zip.7zip",
		"KeePassXCTeam.KeePassXC",
		"TheDocumentFoundation.LibreOffice",		      
		"Microsoft.PowerToys",
		"RustDesk.RustDesk",  
		"ShareX.ShareX",
		"SumatraPDF.SumatraPDF"
    )
	Programacion = @(        
        "Notepad++.Notepad++",
        "Microsoft.VisualStudioCode",
		"HeidiSQL.HeidiSQL",
        "Git.Git",
        "OpenJS.NodeJS.LTS",
		"CoreyButler.NVMforWindows"
    )
}

# Crear diccionario para almacenar los checkboxes
$appCheckboxes = @{ }

# Crear un panel principal que fluirá y tendrá scroll
$mainFlowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$mainFlowPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainFlowPanel.AutoScroll = $true
$mainFlowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$mainFlowPanel.WrapContents = $false # Para que los GroupBox no se pongan uno al lado del otro
$form.Controls.Add($mainFlowPanel)

# Obtener claves y ordenar alfabéticamente para que las categorías aparezcan en orden
foreach ($category in $appCategories.Keys | Sort-Object) {
    # Crear un GroupBox para cada categoría
    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.Text = $category
    $groupBox.AutoSize = $true
    $groupBox.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $groupBox.Padding = [System.Windows.Forms.Padding]::new(10)
    $mainFlowPanel.Controls.Add($groupBox)

    # Crear un panel de flujo dentro del GroupBox para los checkboxes
    $appsFlowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $appsFlowPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $appsFlowPanel.AutoSize = $true
    $appsFlowPanel.WrapContents = $true # Asegura que los checkboxes salten a la siguiente línea si no caben
    $appsFlowPanel.Width = $groupBox.ClientSize.Width # Ajuste inicial
    $groupBox.Controls.Add($appsFlowPanel)

    foreach ($app in $appCategories[$category]) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $app.Split('.')[1]  # Solo mostrar la parte después del punto
        $checkbox.AutoSize = $true
        $checkbox.Margin = [System.Windows.Forms.Padding]::new(5)
        $appCheckboxes[$app] = $checkbox
        $appsFlowPanel.Controls.Add($checkbox)
    }
}

# Crear panel para los controles de ubicación y botones
$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$bottomPanel.Height = 110 # Reducimos un poco la altura
$form.Controls.Add($bottomPanel)

# --- MEJORA ESTÉTICA: Usar un TableLayoutPanel para alinear los controles inferiores ---
$bottomTableLayout = New-Object System.Windows.Forms.TableLayoutPanel
$bottomTableLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
$bottomTableLayout.ColumnCount = 3
$bottomTableLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$bottomTableLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)))
$bottomTableLayout.RowCount = 3
$bottomTableLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 24))) # Fila para la etiqueta
$bottomTableLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 32))) # Fila para el TextBox
$bottomTableLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))      # Fila para los botones, altura automática
$bottomPanel.Controls.Add($bottomTableLayout)

# Controles de la primera fila del TableLayout (TextBox y botón Explorar)
$locationLabel = New-Object System.Windows.Forms.Label
$locationLabel.Text = "Carpeta destino (opcional):"
$locationLabel.AutoSize = $true
$locationLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Left
$bottomTableLayout.Controls.Add($locationLabel, 0, 0)

$locationTextBox = New-Object System.Windows.Forms.TextBox
$locationTextBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$bottomTableLayout.Controls.Add($locationTextBox, 0, 1)

# Botón Explorar
$exploreButton = New-Object System.Windows.Forms.Button
$exploreButton.Text = "Explorar..."
$exploreButton.AutoSize = $true
$exploreButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$bottomTableLayout.Controls.Add($exploreButton, 1, 1)

# Controles de la segunda fila (botones de acción)
$actionButtonsPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$actionButtonsPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$actionButtonsPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$actionButtonsPanel.Padding = [System.Windows.Forms.Padding]::new(0, 10, 0, 0)
$bottomTableLayout.SetColumnSpan($actionButtonsPanel, 3) # Que ocupe todas las columnas
$bottomTableLayout.Controls.Add($actionButtonsPanel, 0, 2)

$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Instalar aplicaciones seleccionadas"
$installButton.Size = [System.Drawing.Size]::new(220, 30)
$installButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$actionButtonsPanel.Controls.Add($installButton)

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Cerrar"
$closeButton.Size = [System.Drawing.Size]::new(100, 30)
$closeButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$actionButtonsPanel.Controls.Add($closeButton)

# Acción para el botón "Explorar"
$exploreButton.Add_Click({
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderDialog.Description = "Seleccione una carpeta de destino"
    if ($folderDialog.ShowDialog() -eq "OK") {
        $locationTextBox.Text = $folderDialog.SelectedPath
    }
})

# Acción para el botón "Cerrar"
$closeButton.Add_Click({
    $form.Close()
})

# Función para ejecutar comando de instalación y mostrar la salida en una nueva ventana
function Invoke-WingetInstallWithProgress {
    param (
        [string[]]$SelectedApps,
        [string]$InstallLocation
    )

    # Crear formulario de progreso
    $progressForm = New-Object System.Windows.Forms.Form
    $progressForm.Text = "Instalando..."
    $progressForm.Size = [System.Drawing.Size]::new(700, 500)
    $progressForm.StartPosition = "CenterParent"
    $progressForm.ControlBox = $false # Deshabilitar botones de minimizar/maximizar/cerrar

    $logBox = New-Object System.Windows.Forms.TextBox
    $logBox.Multiline = $true
    $logBox.ScrollBars = "Vertical"
    $logBox.Dock = "Fill"
    $logBox.ReadOnly = $true
    $logBox.Font = [System.Drawing.Font]::new("Consolas", 10)
    $progressForm.Controls.Add($logBox)

    $progressForm.Show()

    # Función para agregar texto al log
    $logUpdate = {
        param($text)
        if ($logBox.InvokeRequired) {
            $logBox.Invoke([Action[string]]$logUpdate, $text)
        } else {
            $logBox.AppendText("$text`r`n")
        }
    }

    # Ejecutar en un trabajo para no bloquear la UI
    $job = Start-Job -ScriptBlock {
        param($apps, $location, $logUpdate)

        foreach ($appId in $apps) {
            & $logUpdate "Iniciando instalación de: $appId"
            $command = "winget install --id $appId --accept-source-agreements --accept-package-agreements"
            if (-not [string]::IsNullOrEmpty($location)) {
                $sanitizedAppName = $appId.Split('.')[1]
                $appInstallPath = Join-Path -Path $location -ChildPath $sanitizedAppName
                $command += " --location `"$appInstallPath`""
            }
            & $logUpdate "Ejecutando: $command"
            # Ejecuta el comando y redirige la salida estándar y de error
            $process = Start-Process winget -ArgumentList $command.Split(' ')[1..($command.Split(' ').Length - 1)] -NoNewWindow -Wait -PassThru -RedirectStandardOutput "stdout.tmp" -RedirectStandardError "stderr.tmp"
            Get-Content "stdout.tmp" | ForEach-Object { & $logUpdate $_ }
            Get-Content "stderr.tmp" | ForEach-Object { & $logUpdate "ERROR: $_" }
            Remove-Item "stdout.tmp", "stderr.tmp" -ErrorAction SilentlyContinue
            & $logUpdate "Finalizada la instalación de: $appId`n"
        }
    } -ArgumentList @($SelectedApps, $InstallLocation, $logUpdate)

    # Esperar a que el trabajo termine
    Wait-Job $job | Out-Null
    Receive-Job $job
    Remove-Job $job

    $logUpdate.Invoke("--- PROCESO COMPLETADO ---")
    [System.Windows.Forms.MessageBox]::Show($progressForm, "Proceso de instalación completado.", "Información", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    $progressForm.Close()
}

# Acción para el botón "Instalar aplicaciones seleccionadas"
$installButton.Add_Click({
    # Obtener aplicaciones seleccionadas
    $selectedApps = @()
    foreach ($app in $appCategories.Keys) {
        foreach ($appId in $appCategories[$app]) {
            if ($appCheckboxes[$appId].Checked) {
                $selectedApps += $appId
            }
        }
    }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Por favor, seleccione al menos una aplicacion para instalar.", "Advertencia", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # Obtener ubicación de instalación
    $installLocation = $locationTextBox.Text

    # Deshabilitar el botón de instalar para evitar múltiples clics
    $installButton.Enabled = $false
    Invoke-WingetInstallWithProgress -SelectedApps $selectedApps -InstallLocation $installLocation
    $installButton.Enabled = $true
})

# Mostrar formulario
[void]$form.ShowDialog()