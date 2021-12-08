<#
    Module: GetDirectory.psm1
    Author: Dark-Coffee
    Version: 0.1
    Updated: 2021-12-08
    Description: Pulls the most recent file of .zip/.bak type from the specified SFTP Site.
#>

function Get-SFTPFile {
    param (
        [string]$HostName,
        [int]$PortNumber,
        [string]$UserName,
        [securestring]$Password,
        [string]$SshHostKeyFingerprint,
        [path]$DownloadDir
    )
    
    try
    {
        # Load WinSCP .NET assembly
        Add-Type -Path "WinSCPnet.dll"
    
        # Setup session options
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = $HostName
            PortNumber = $PortNumber
            UserName = $UserName
            Password = $(ConvertFrom-SecureString -SecureString $Password -AsPlainText)
            SshHostKeyFingerprint = $SshHostKeyFingerprint
        }
        Write-Host $sessionOptions
    
        $session = New-Object WinSCP.Session
    
        try
        {
            # Connect
            $session.Open($sessionOptions)
    
            # Download files
            $transferOptions = New-Object WinSCP.TransferOptions
            $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
    
            $transferResult =
                $session.GetFiles("/*.bak", "C:\Temp\FTP\", $False, $transferOptions)
    
            # Throw on any error
            $transferResult.Check()
    
            # Print results
            foreach ($transfer in $transferResult.Transfers)
            {
                Write-Host "Download of $($transfer.FileName) succeeded"
            }
        }
        finally
        {
            # Disconnect, clean up
            $session.Dispose()
        }
    
        exit 0
    }
    catch
    {
        Write-Host "Error: $($_.Exception.Message)"
        exit 1
    }



    # PowerShell Console Help
    <#
        .SYNOPSIS
        Pulls the most recent .zip or .bak file from the specified sftp site.
        .DESCRIPTION
        Downloads the most recent file from an sftp. files included will be .zip/.bak.
        If .zip will automatically extract.
        .PARAMETER HostName
        [MANDATORY] Specifies the Host for the SFTP Site
        .PARAMETER Port
        The port to knock on the SFTP Site. If left blank will default to 22.
        .PARAMETER UserName
        [MANDATORY] The Username to use when connecting to the SFTP Host
        .PARAMETER Password
        [MANDATORY] The password for the provided user.
        .PARAMETER PrivateKeyFile
        If specified, the PPK file to use to connect with, in place of a password.
        .PARAMETER SshHostKeyFingerprint
        [MANDATORY] The SSH Hostkey Fingerprit for the SFTP Host.
        .PARAMETER DownloadDir
        The directory to download files to. If this directory does not exist, it will be created. Defaults to C:\Temp\FTP\
        .INPUTS
        This function does not accept pipeline input.
        .OUTPUTS
        .EXAMPLE
        PS>  Get-FTPSite -
        .EXAMPLE
        PS>
        .EXAMPLE
        PS> 
        .LINK
        https://github.com/dark-coffee/Posh-FTP#readme
    #>
}
