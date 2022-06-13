

########################################################################################
## Publishing Provisioning Scripts
## This script used SharePoint PnP PowerShell to provisionning some solutions.
##
## Author:          Andriy Chevychalov
## Editor:  
## Examples:
##     .\Deploy-App.ps1 -Tenant 'aec1b57d-7b0a-4eeb-979c-1a211621adce' -TenantUrl https://oberigdev.sharepoint.com -SiteRelativeUrl /sites/acdev -ClientId '{9179171b-abec-456c-84af-03305686c768}' -ClientCertificateName 'SPFx-AzureDevOpsV1.pfx' -PackageFileName 'spfx-online-hooks.sppkg' -Verbose
## 
## Bugs/Issues
##    https://github.com/pnp/PnP-PowerShell/issues/2181
##    https://www.koskila.net/how-to-fix-add-pnpapp-failing-with-an-access-denied-error/
##
## Created on:      12/07/2020
## Product Version: 1.0
## Script Version:  1.0
#########################################################################################
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,
		ValueFromPipeline=$True, 
		ValueFromPipelineByPropertyName=$True, 
		HelpMessage='Get tennant id as GUID')]
    [ValidatePattern('(\{|\()?[A-Za-z0-9]{4}([A-Za-z0-9]{4}\-?){4}[A-Za-z0-9]{12}(\}|\()?')]
	[string]$Tenant,

	[Parameter(Mandatory=$True,
		ValueFromPipeline=$True, 
		ValueFromPipelineByPropertyName=$True, 
		HelpMessage='Get tennant url')]
    [ValidatePattern("\b(https?)://.*")]
	[string]$TenantUrl,

    [Parameter(Mandatory=$False,
		ValueFromPipeline=$True, 
		ValueFromPipelineByPropertyName=$True, 
		HelpMessage='Get site collection relative url')]
	[string]$SiteRelativeUrl,

    [Parameter(Mandatory=$False,
		ValueFromPipeline=$True, 
		ValueFromPipelineByPropertyName=$True, 
		HelpMessage='Get client id as GUID')]
    [ValidatePattern('(\{|\()?[A-Za-z0-9]{4}([A-Za-z0-9]{4}\-?){4}[A-Za-z0-9]{12}(\}|\()?')]
	[string]$ClientId,

    [Parameter(Mandatory=$False,
		ValueFromPipeline=$True, 
		ValueFromPipelineByPropertyName=$True, 
		HelpMessage='Get client certificate name, for App registration')]
	[string]$ClientCertificateName,

    [Parameter(Mandatory=$False,
		ValueFromPipeline=$True, 
		ValueFromPipelineByPropertyName=$True, 
		HelpMessage='Get client secret')]
	[string]$PackageFileName    
)

try
{
    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $using = $PSScriptRoot
    . ($using + '\Common\Common.ps1')

    $uri = [System.Uri] $TenantUrl
    
    $global:settings = @{
        Uri = $uri
        UriHost = $uri.Host
        Tenant = $Tenant
        TenantUrl = $TenantUrl
        SiteRelativeUrl = $SiteRelativeUrl
        SiteUrl = [string]::Concat($TenantUrl,$SiteRelativeUrl)
        RootApplicationFolder = Split-Path $script:MyInvocation.MyCommand.Path
        ApplicationPath = ""
        ClientId = $ClientId
        ClientCertificateName = $ClientCertificateName
        PackageFileName = $PackageFileName
    }
    $global:settings.ApplicationPath = "{0}/{1}" -f $global:settings.RootApplicationFolder, $global:settings.PackageFileName

    Write-Verbose ("Init environment...`n")
    Write-Verbose ($global:settings | Out-String)
    #Enable-Logging -Enable $true

    $CurrentDirectory =  Split-Path -parent $MyInvocation.MyCommand.Definition
    Write-Verbose ("Current directory {0}`n" -f $CurrentDirectory)
    Write-Verbose ("Ensure PnP.PowerShell Module...`n")

    Find-Module -Name PnP.PowerShell | Install-Module -AllowClobber -Force -Verbose
    Install-Module PnP.PowerShell -Force
    Get-Module PnP.PowerShell

    #Register-PnPAzureADApp -ApplicationName SPFx-AzureDevOpsV1 -Tenant:$global:settings.Tenant -OutPath . -DeviceLogin
    $certificatePath = "{0}/{1}" -f $global:settings.RootApplicationFolder, $global:settings.ClientCertificateName

    Write-Verbose ("Start provisioning with certificate [{0}]...`n" -f $certificatePath)
    
    ##-Scopes Sites.FullControl.All
    $connection = Connect-PnPOnline -Url:$global:settings.SiteUrl  -ClientId:$global:settings.ClientId -Tenant:$global:settings.Tenant -CertificatePath $certificatePath
   
    Get-PnPContext
    $site = Get-PnPSite 
    Write-Verbose ("Connection was created successfully, ({0})...`n" -f $site.Url)

    if (($global:settings.SiteRelativeUrl.lehgtn > 1) -and (-not $global:settings.SiteRelativeUrl -ceq '/'))
    {

        Write-Verbose ("To deploy & install the app {0} on a site use the below script...`n" -f $global:settings.ApplicationPath)
        Add-PnPApp -Path $global:settings.ApplicationPath -Scope Site -Publish -Overwrite
    }
    else
    {
        Write-Verbose "To deploy & install the app on a tenant level...`n"
        Add-PnPApp -Path $global:settings.ApplicationPath -Overwrite:$true -Publish
    }

    #Write-Verbose "Publish will be taking care of the deploy and trust process.`n"
    #Write-Verbose "If you want to install the application manually, you can move the app packages like .app and .sppkg using the below command.`n"
    #Add-PnPApp -Path $global:settings.ApplicationPath -Overwrite

    Write-Verbose "Provisioning has been successfully completed...`n"

}
catch
{
	Write-Error "An exception occurred. The script will now be stopped. Please find the details below."
	Write-Error "$_"
}
finally
{
    Disconnect-PnPOnline

    $stopWatch.Stop()
	$elapsed = ElapsedToString($stopWatch.Elapsed)
}

    

