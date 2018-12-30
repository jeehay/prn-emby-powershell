function Get-Star-Name-From-Comments($path='')
{
    #$path  = "C:\Temp\Show Dogs 2018 1080p.mp4"
    $shell = New-Object -COMObject Shell.Application
    $folder = Split-Path $path
    $file = Split-Path $path -Leaf
    $shellfolder = $shell.Namespace($folder)
    $shellfile = $shellfolder.ParseName($file)
    $m = $shellfolder.GetDetailsOf($shellfile, 24)

    $s = $m.Split(':')
    if ($s[0] -eq "STARS")
    {
        return $s[1]
    }
    
    #You'll need to know what the ID of the extended attribute is. This will show you all of the ID's:
    #0..287 | Foreach-Object { '{0} = {1}' -f $_, $shellfolder.GetDetailsOf($null, $_) }
    
    #Once you find the one you want you can access it like this:
    return $false
}

function Get-Video-Genre($path='')
{
    $shell = New-Object -COMObject Shell.Application
    $folder = Split-Path $path
    $file = Split-Path $path -Leaf
    $shellfolder = $shell.Namespace($folder)
    $shellfile = $shellfolder.ParseName($file)
    return $shellfolder.GetDetailsOf($shellfile, 16)
}