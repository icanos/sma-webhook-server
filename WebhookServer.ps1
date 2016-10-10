#
# Webhook Server for Service Management Automation to trigger runbooks.
#
# Date: 2016-10-10
# Author: Marcus Westin (@mawestin)
#


# Port that the webhook server runs on
$WebhookServerPort = 8099
$SmaWebserviceEndpoint = "https://localhost"

# A list of runbooks that aren't allowed to be started using the Webhook Server.
$RestrictedRunbooks = @(
    "Insert-Name-Of-Runbook-Here"
)

# Routes that can be accessed in this tiny webserver.
$Routes = @{
    "/run" = "Start-Runbook";
    "/stop" = "Stop-Server";
}

$Listener = New-Object System.Net.HttpListener





#
# Functions
#
Function Start-Runbook
{
    Param(
        $RunbookName
    )

    $JobGuid = Start-SmaRunbook -Name $RunbookName -WebserviceEndpoint $global:SmaWebserviceEndpoint

    return $JobGuid
}

# Stop the webhook server
Function Stop-Server
{
    $Listener.Stop()
    return $false
}






#
# ----------------------------------------------------------------------------------------------
# Server code, this doesn't do much fancy work... Just triggers the function associated with
# the route that is received.
#
$Url = "http://localhost:$($WebhookServerPort)/"
$Listener.Prefixes.Add($Url)
$Listener.Start()

Write-Host "Listening on $Url..."

while ($Listener.IsListening)
{
    $Context = $Listener.GetContext()
    $RequestUrl = $Context.Request.Url
    $Response = $Context.Response

    Write-Host ''
    Write-Host "> $RequestUrl"

    $LocalPath = $RequestUrl.LocalPath
    $Arguments = [System.Collections.Generic.List[System.String]]$LocalPath.Split('/')

    if ($Arguments.Count -gt 1)
    {
        $UrlSegment = $Arguments[1]

        # Remove blank space and name of the route and pass the rest as arguments
        $Arguments.RemoveAt(0)
        $Arguments.RemoveAt(0)
    }
    else
    {
        $UrlSegment = $LocalPath
    }

    $Route = $Routes.Get_Item("/$($UrlSegment)")

    if ($Route -eq $null)
    {
        $Response.StatusCode = 404
    }
    else
    {
        $Content = &"$Route" @Arguments
        if ($Content)
        {
            $Buffer = [System.Text.Encoding]::UTF8.GetBytes($Content)
            $Response.ContentLength64 = $Buffer.Length
            $Response.OutputStream.Write($Buffer, 0, $Buffer.Length)
        }
    }
    
    if ($Content)
    {
        $Response.Close()
    }

    $ResponseStatus = $Response.StatusCode
    Write-Host "< $ResponseStatus"
}

$Listener.Dispose()
