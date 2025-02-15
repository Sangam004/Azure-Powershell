# Import the ServerManager module (necessary on some systems)
Import-Module ServerManager

# Install IIS and all subfeatures
Add-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools

# Install ASP.NET 4.5
Add-WindowsFeature -Name Web-Asp-Net45

# Install .NET Framework features
Add-WindowsFeature -Name NET-Framework-Features

# Create a simple default webpage
Set-Content -Path "C:\inetpub\wwwroot\Default.html" -Value "This is the server $($env:computername)"
