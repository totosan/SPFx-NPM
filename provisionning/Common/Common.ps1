########################################################################################
## Common.ps1
## This script provides common function sregarding deployment.
##
## Author:          A.Chevychalov
## Created on:      12.06.2022
## Product Version: 1.0
## Script Version:  1.0
##
#########################################################################################

function Init-Env {
  <#
  .SYNOPSIS
  This method will be used to connect to tenant and init global variables
  .DESCRIPTION
  Detail
  .EXAMPLE
    Init-Env -Environment $env
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$False,
		HelpMessage='Get environment')]
    [string]$Environment = $null
  )

  begin {
    $applicationFolder = $global:settings.RootApplicationFolder
    Write-Verbose ("Trying to load and initialize configuration for this environment'{0}' ...`n" -f $applicationFolder)

	$basefile = "Configuration.psd1"

    if(-not([string]::IsNullOrEmpty($Environment))){
        $stagefile = "$Environment.psd1"
    };

    $basedir = "$applicationFolder\Config"
    Write-Verbose "Try to load configaration from $basedir..."
  }

  process {
    try
    {
		$baseSettings = Import-LocalizedData -BaseDirectory $basedir -FileName $basefile
		$stageSettings = Import-LocalizedData -BaseDirectory $basedir -FileName $stagefile

		$baseSettings.Keys | ForEach {$global:settings.Add($_, $baseSettings[$_]) }
		$stageSettings.Keys | ForEach {$global:settings.Add($_, $stageSettings[$_]) }

        Write-Verbose "The configuration has been loaded successfully..."
        Write-Verbose ($global:settings | Out-String)
    }
    catch [Exception]
    {
      Write-Error $_.Exception.Message
    }
  }
}

function Enable-Logging {
  <#
  .SYNOPSIS
  This method create log file, and enable PnP trace logging.
  .DESCRIPTION
  Detail
  .EXAMPLE
    Enable-Logging -Enable $true
  #>
  [CmdletBinding()]
  param
  (
  [Parameter(Mandatory=$False,
    ValueFromPipeline=$False,
    ValueFromPipelineByPropertyName=$False,
      HelpMessage='Get if logging is enabled".')]
    [Alias('host')]
    [boolean]$Enable
  )

  begin {
    $logFolder = Split-Path $script:MyInvocation.MyCommand.Path

    $dt = Get-Date -format s
    $prefix = $dt.Replace(":", "")
    $logFileName = "\log_$prefix.log"
    Write-Verbose "The log file name '$logFileName' has been generated."
  }

  process {

    try{
        if($Enable){
            $logFullFileName =  $logFolder + $logFileName
            New-Item $logFullFileName -ItemType file | Out-Null

            Start-Transcript -path $logFullFileName

            Set-PnPTraceLog -On -LogFile  $logFullFileName

            Write-Verbose "The Process will be logged to $logFullFileName.`n"
        }
    }
    catch [Exception]
    {
      Write-Error $_.Exception.Message
      return false
    }
  }
}

function ElapsedToString {
  <#
  .SYNOPSIS
  This function format elapsed time to string.
  .DESCRIPTION
  Detail
  .EXAMPLE
    Write-Ln -Elapsed $elapsed
  .PARAMETER info
  The info message as hashtable for output.
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='Getting Elapsed')]
    [Alias('host')]
    [TimeSpan]$Elapsed
  )

  begin {
  }

  process {
      $result = [string]::Format("{0:D2}dd:{1:D2}h:{2:D2}m:{3:D2}s:{4:D3}ms", 
                        $Elapsed.Days,
                        $Elapsed.Hours, 
                        $Elapsed.Minutes, 
                        $Elapsed.Seconds, 
                        $Elapsed.Milliseconds)

      Write-Verbose ("{0} Milliseconds => '{1}'..." -f $Elapsed, $result)

      return  $result
  }
}


