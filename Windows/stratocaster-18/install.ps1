
function Invoke-Chocolatey {
    Import-Csv -LiteralPath "$PSScriptRoot/chocolatey.csv" -Encoding UTF8 | %{Write-Host "Installing: " $_.Name ;Invoke-Expression -Command ('choco install ' + $_.Name + ' -y')} 
}

function Install-Modules {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    <#
    Name                      InstallationPolicy   SourceLocation
    ----                      ------------------   --------------
    PSGallery                 Trusted              https://www.powershellgallery.com/api/v2
    #>
    Install-Module -Name PowerShellGet, ExchangeOnlineManagement, AzureADPreview
}

Invoke-Chocolatey
Install-Modules