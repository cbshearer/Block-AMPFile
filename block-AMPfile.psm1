## Add files to Cisco AMP custom block list
## Chris Shearer
## 14-SEP-2020
## AMP API Docs: https://api-docs.amp.cisco.com/api_resources?api_host=api.amp.cisco.com&api_version=v1
## Github repository for this module: https://github.com/cbshearer/Block-AMPFile


Function Block-AMPFile
{
        ## Add to AMP
        

        ## Accept CLI parameters
            param ([Parameter(Mandatory=$true)] [array]$f)

        ## specify TLS
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

        ## Assign variables if they were entered from the CLI
            if ($f){$badFiles = @($f)}
            else {Write-Host -f magenta "No hashes found, exiting."}

        ## Pull credential data from CSV file
                $AMPClientID = "xxxxxxxxxxxxxxxxxxx"
                $AMPKey = "yyyyyyyyyyyyyyyyyyyyyyyy"
        
        ## Loop through the hashes

        ## Other AMP specific variables
          #  $CredFile   = import-csv 'credentials.csv'
            $day = get-date -f yyyy-MM-dd                               ## Date as 4 digit year, 2 digit month, 2 digit day (for AMP description)
            $AMPDescription = "Added by PowerShell"                     ## Note on AMP list entry
            $AMPcredpair = "$($AMPClientID):$($AMPKey)"                 ## Creating the credential
            $AMPencodedcredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($AMPcredpair))
            $AMPBody  = @{description = "$AMPDescription $day"}         ## Adding the description to the body
            $GUID = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"              ## This can be set to your GUID (inside the quotes) once you know it so it doesn't need to run the query every time and waste an api call.

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
                write-host "GUID is:" $GUID ". This needs to be updated in  your module"                    ## Enter this into the $GUID variable (line 75 above)
            }

        ## Loop through the array.
            foreach ($AMPFile in $badFiles)
                {
                    $AMPURIEndpoint = "https://api.amp.cisco.com/v1/file_lists/" + $GUID + "/files/" + $AMPFile 
                    ## Display each hash and endpoint
                        Write-Host -f cyan "==================="
                        write-host "Hash  : " -NoNewline; Write-Host -f cyan $AMPFile 
                        write-host "URI   : " -NoNewline; Write-Host -f cyan $AMPURIEndpoint

                        $AMPParameters  = @{
                                URI     = $AMPURIEndpoint
                                Headers = @{ 'Authorization' = "Basic $AMPencodedcredentials" }
                                Method  = 'POST'
                                Body    = $AMPBody
                            }
                    ## Add this hash to AMP
                        $AMPadd = try {Invoke-webrequest @AMPparameters -ErrorAction SilentlyContinue }
                                  catch { 
                                            $prob =  $_.exception | Select-Object  
                                            write-host "Error : " -NoNewline; write-host -f magenta $prob.message
                                        }

                        $AMPadd = $AMPadd | ConvertFrom-Json
                        write-host "Result:" $ampadd.data.source

                }
                
}

Export-ModuleMember -Function Block-AMPFile