#Config file locations
#cls

if(-not $loc){$global:loc= $env:OneDrive+"\Powershell\New Way"}

$global:StudioName               = "$loc\StudioName.xml"
$global:StudioMainCategory       = "$loc\StudioMainCategory.xml"
$global:Category                 = "$loc\Category.xml"
$global:StarsAlias               = "$loc\StarsAlias.xml"
$global:StarCategory             = "$loc\StarCategory.xml"

# Define the config variable
$config = @{}

if(-not (Test-Path $StudioName)) {
    $config['StudioName'] = @{}
    $config['StudioName'] | Export-Clixml $StudioName
} else {
    $config['StudioName'] = Import-Clixml $StudioName
}

# Check for and import configuration
if(-not (Test-Path $StudioMainCategory)) {
    $config['StudioMainCategory'] = @{}
    $config['StudioMainCategory'] | Export-Clixml $StudioMainCategory
} else {
    $config['StudioMainCategory'] = Import-Clixml $StudioMainCategory
}

# Check for and import configuration
if(-not (Test-Path $Category)) {
    $config['Category'] = @{}
    $config['Category'] | Export-Clixml $Category
} else {
    $config['Category'] = Import-Clixml $Category
}

# Check for and import the Stars Alias configuration
if(-not (Test-Path $StarsAlias)) {
    $config['StarsAlias'] = @{}
    $config['StarsAlias'] | Export-Clixml $StarsAlias
} else {
    $config['StarsAlias'] = Import-Clixml $StarsAlias
}

# Check for and import configuration
if(-not (Test-Path $StarCategory)) {
    $config['StarCategory'] = @{}
    $config['StarCategory'] | Export-Clixml $StarCategory
} else {
    $config['StarCategory'] = Import-Clixml $StarCategory
}

function Set-ConfigItem
{
    param($Key, $Value, $Scope)
    
    $Key=$Key.Trim()
    $Value=$Value.trim()

    if(-not $Scope -or -not $Key)
    {
        throw 'Scope and key parameters must be provided'
    }
    # If the scope exists, add or set the item in the scope.
    if($Config[$Scope])
    {
        $Config[$Scope][$Key] = $Value
    }
    else 
    {
        throw "Scope not available"
    }
    
    # Also, update the config files
    Write-Config
}

function Check-Set-ConfigItem
{
    param($Key, $Value, $Scope)
    
    $Key=$Key.Trim()
    $Value=$Value.trim()

    if(-not $Scope -or -not $Key)
    {
        throw 'Scope and key parameters must be provided'
    }
    
    #
    if( (Get-ConfigItem -Scope $Scope -Key $Key) -ne $null ){
        Get-ConfigItem -Scope $Scope -Key $Key
    }
    else{
	    # If the scope exists, add or set the item in the scope.
        if($Config[$Scope])
        {
           $Config[$Scope][$Key] = $Value
        }
       
        Write-Config
        Write-Host "Not found so write it"
    }
}

function Get-ConfigItem
{
    param($Key, $Scope)

    $Key=$Key.Trim()
    
    if(-not $Scope -or -not $Key)
    {
        throw 'Scope and key parameters must be provided'
    }

    # If the scope exists, add or set the item in the scope.
    if($Config[$Scope])
    {
        $Config[$Scope][$Key]
    }
}

function Remove-ConfigItem
{
    param($Key, $Scope)
    if(-not $Scope)
    {
        throw 'Scope must be defined to remove an item.'
    }
    else
    {
        $config[$scope].Remove($Key)
    }
    Write-Config
}

function Get-Config
{
    param($Scope)
    
    if($Scope)
    {
        $config[$Scope].GetEnumerator() | 
            Sort-Object Name
    }
    else
    {
        foreach($scope in $config.GetEnumerator())
        {
                Write-Verbose $scope.Name "scope" -ForegroundColor White -BackgroundColor Green
                $scope.Value.GetEnumerator() | Sort-Object Name
        }
    }
}

function Write-Config
{
    $config['StudioName']             | Export-Clixml -Path $StudioName
    $config['StudioMainCategory']     | Export-Clixml -Path $StudioMainCategory
    $config['Category']               | Export-Clixml -Path $Category
    $config['StarCategory']           | Export-Clixml -Path $StarCategory
    $config['StarsAlias']             | Export-Clixml -Path $StarsAlias
}

#Export-ModuleMember -Function Set-ConfigItem,Get-ConfigItem,Remove-ConfigItem,Get-Config
#,Read-Config

