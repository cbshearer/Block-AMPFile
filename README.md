# block-AMPFile

- Use PowerShell to add one or more SHA256 hashes to your Cisco AMP simple custom detections list.
- You need your own API credential pair.
- Cisco AMP [API Documentation](https://api-docs.amp.cisco.com/api_resources?api_host=api.amp.cisco.com&api_version=v1).

## To use the module

- Import the module 

```PowerShell
PS C:\temp> Import-Module .\block-AMPFile.psm1
```

- If you want to install the module for long-term use
  - See [Microsoft documentation](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7).
  - Shortcut - just copy to its own folder in this location: $Env:ProgramFiles\WindowsPowerShell\Modules

```PowerShell
PS C:\temp> copy .\block-AMPFile.psm1 $Env:ProgramFiles\WindowsPowerShell\Modules\block-AMPFile\block-AMPFile.psm1
```

- Change parameters on the following lines:  
  - 24: AMP Client ID
  - 25: AMP Key
  - 36: GUID - If there isn't one saved on this line, an extra API call is run every time and the value of the GUID is displayed at the console. 

- Mandatory parameter
  - -f: file hash - AMP [wants a sha256 hash](https://api-docs.amp.cisco.com/api_actions/details?api_action=POST+%2Fv1%2Ffile_lists%2F%7B%3Afile_list_guid%7D%2Ffiles%2F%7B%3Asha256%7D&api_host=api.amp.cisco.com&api_resource=File+List+Item&api_version=v1).
  - Comma separated for multiple

- Examples:
```PowerShell
block-AMPFile -f bd32fccef3e226d3f22d6ccbd2e74b53e04d087d6cd2fb45ebfd7431ace1a5b1
block-AMPFile 160e934c01f0137b5ff230b7d1fa6c782a3fd80c5df43b6286c56634b6042c87,7c138b4db5f2cf643f1933f5d746ae36811cf0bc3325af82b4d0cf268351bac4
```