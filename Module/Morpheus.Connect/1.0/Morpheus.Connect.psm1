Function Connect-Morpheus {
    <#
    .Synopsis
       Makes connection to your Morpheus Appliance.
    .DESCRIPTION
       A connection is made to your Morpheus Appliance via port 443.  All calls are made to this connection
       object until the terminal is closed.
    .EXAMPLE
       Connect-Morpheus -URL test.morpheus.com
    .EXAMPLE
       Connect-Morpheus -URL test.morpheus.com -ApiCredential (Get-Credential)
       Connect to the given Morpheus instance using an API access token. Note:  the _password_ portion of the ApiCredential parameter value is used as the API access token
    .EXAMPLE
       Connect-Morpheus -URL https://test.morpheus.com -Username TestUser
    .EXAMPLE
       Connect-Morpheus -URL https://test.morpheus.com -Username TestUser -Password S@mplePa55
    #>


    Param (
        ## Morpheus data destination to which to connect
        [Parameter(Mandatory=$true)][string]$URL,

        ## Username for connecting with username/password pair
        [Parameter(Mandatory=$true, ParameterSetName="AuthWithUser")][string]$Username,

        ## Password to use for username/password authentication
        [parameter(ParameterSetName="AuthWithUser")]$Password,

        ## Credential with API access token as the password, for connecting to Morpheus with an API access token
        [parameter(Mandatory=$true, ParameterSetName="AuthWithApiToken")][System.Management.Automation.PSCredential]$ApiCredential
    )

    process {
        if (!$URL.StartsWith('https://')) {
            $URL = ('https://' + $URL)
            }

        $global:URL = $URL

        ## if using API access token
        if ($PSCmdlet.ParameterSetName -eq "AuthWithApiToken") {
            $global:Header = @{
                ## use the ApiCredential "password" field, which is the API access token
                "Authorization" = ("BEARER {0}" -f $ApiCredential.GetNetworkCredential().Password)
                }
        } ## end if
        ## else, using username/password
        else {
            if (-not($Password)) {
                $Password = Read-host 'Enter Password' -AsSecureString
                $PlainTextPassword= [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR( ($Password) ))
                }
            else {
                $PlainTextPassword = $Password
                }

            Try {
                $Errors = $null
                ####  Morpheus Variables  ####
                $Body = "username=$Username&password=$PlainTextPassword"
                $AuthURL = "/oauth/token?grant_type=password&scope=write&client_id=morph-customer"

                ####  Create User Token   ####
                $Token = Invoke-WebRequest -Method POST -Uri ($URL + $AuthURL) -Body $Body | select -ExpandProperty content|
                    ConvertFrom-Json | select -ExpandProperty access_token
                $global:Header = @{
                    "Authorization" = "BEARER $Token"
                    }
                }

            Catch {
                $Errors = $true
                Write-Host "Failed to authenticate credentials" -ForegroundColor Red
                }
            Finally {
                if (!$Errors) {
                    Write-Host "Successfully connected to $URL.`nUse `"Get-Command -Module Morpheus`" to discover available commands." -ForegroundColor Yellow
                    }
                }
        } ## end else
    } ## end process
}

## export these via the PowerShell Data file (psd1)
# Export-ModuleMember -Variable URL,Header