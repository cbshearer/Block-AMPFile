[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Function Add-toAMP($AMPFile)
{
        ## Add to AMP
        ## AMP API Docs: https://api-docs.amp.cisco.com/api_resources?api_host=api.amp.cisco.com&api_version=v1

        ## Pull credential data from CSV file
            $AMPClientID = "xxxxxxxxxxxxxx"
            $AMPKey = "yyyyyyyyyyyyyyyyyyy"
        
        ## Other AMP specific variables
            $day = get-date -f yyyy-MM-dd                               ## Date as 4 digit year, 2 digit month, 2 digit day (for AMP description)
            $AMPDescription = "Added via PowerShell"                    ## Note on AMP list entry
            $AMPcredpair = "$($AMPClientID):$($AMPKey)"                 ## Creating the credential
            $AMPencodedcredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($AMPcredpair))
            $AMPBody  = @{description = "$AMPDescription $day"}         ## Adding the description to the body
            $GUID = $null                                               ## This can be set to your GUID (inside the quotes) once you know it so it doesn't need to run the query every time and waste an api call.

        ## API Query to find AMP Simple Custom Detection GUID and define it as $GUID if it is unknown.
            if ($GUID -like $null)
            {
                $AMPURIEndpointFolder= "https://api.amp.cisco.com/v1/file_lists/simple_custom_detections"
                $AMPFolderParameters = @{
                    URI     = $AMPURIEndpointFolder
                    Headers = @{ 'Authorization' = "Basic $AMPencodedcredentials" }
                    Method  = 'GET'
                    }
                
                $ampFolderGUID = Invoke-RestMethod @AMPFolderParameters 

                $GUID = $AMPFolderGUID.data.GUID
                write-host "GUID is:" $GUID                     ## Enter this into the $GUID variable (line 75 above), and uncomment that line to save yourself some API calls.
            }

            $AMPURIEndpoint = "https://api.amp.cisco.com/v1/file_lists/" + $GUID + "/files/" + $AMPFile 
            ## Display each hash and endpoint
                write-host "Hash:" $AMPFile 
                write-host "URI :" $AMPURIEndpoint

                $AMPParameters  = @{
                        URI     = $AMPURIEndpoint
                        Headers = @{ 'Authorization' = "Basic $AMPencodedcredentials" }
                        Method  = 'POST'
                        Body    = $AMPBody
                    }
            ## Add this hash to AMP
                $AMPadd = Invoke-RestMethod @AMPparameters -ErrorAction SilentlyContinue -ErrorVariable $Err
                
                if ($Err) 
                    {
                        $err | select-object *
                        return $Err
                    }
                $AMPadd.data | Format-List
                
}

$badfiles  = @()
$badfiles += "027cc450ef5f8c5f653329641ec1fed91f694e0d229928963b30f6b0d7d3a745"
#$badfiles += ""

foreach ($badfile in $badfiles)
    {
        Add-toAMP($badfile)
    }
