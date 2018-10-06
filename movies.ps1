#cls
$p = "A:\FM\[GammaEntertainment]\[GirlFriendsFilms]\Cheer Squad Sleepovers\21"
$p2 = "A:\FM\``[GammaEntertainment``]\``[GirlFriendsFilms``]\Cheer Squad Sleepovers\21"
cd "$p2"

."D:\Powershell\New Way\Config.ps1"

$regex = "\[([\w|\s*-]+)\]([\w|\s]+(?:\[[\w|\s]+\])?.*)\s*-\s*([\w|,|\s.]+)";
$option = [System.StringSplitOptions]::RemoveEmptyEntries

Get-ChildItem -LiteralPath $p -Filter *.mp4 |
    ForEach-Object {
        $FileName = $_.BaseName
        $file_name = $FileName + ".nfo";
        $groups = [regex]::Match($FileName, $regex).Captures.Groups

          if($groups)
          {
                $studio = Get-ConfigItem -Scope 'StudioName' -Key $groups[1].Value.Trim()
                $stud=$studio.Split(",", $option);
                $studio2=$null
                foreach ($stu in $stud)
                {
                   $studio2+= "<studio>$stu</studio>";
                }

                $Category = Get-ConfigItem -Scope 'Category' -Key (Get-ConfigItem -Scope 'StudioMainCategory' -Key $groups[1].Value.Trim())

                $Title  = $groups[2].Value.Trim();

                $star   = $groups[3].Value.Trim();
                if($star)
                {
                    $st      = $star.Split(",", $option);
                    $actor=$null
                    $StarCategory_c=$Category+","+$studio
                    foreach ($s in $st)
                    {
                       $sts = Get-ConfigItem -Scope 'StarsAlias' -Key $s.Trim()
                       if ($sts){$sts=$sts}else{$sts=$s.Trim()}
                       $c=(Get-ConfigItem -Scope 'StarCategory' -Key $sts);
                       if($c){$StarCategory_c+=$c+','}

                       $actor+= "<actor><name>$sts</name><type>Actor</type></actor>";
                    }
                }

                $st_cat=$StarCategory_c.Split(",", $option);
                $genre=$null
                foreach ($c in $st_cat)
                {
                    $genre+="<genre>"+$c.Trim()+"</genre>";
                }
                
                $t_name = ($Title+" - "+$star).Trim()
                $file = "<?xml version=""1.0"" encoding=""utf-8"" standalone=""yes""?>
                <movie>
                    <customrating>XXX</customrating>
                    <lockdata>true</lockdata>
                    <rating>4.5</rating>
                    <criticrating>5</criticrating>

                    <mpaa>XXX</mpaa>
                    <isuserfavorite>false</isuserfavorite>
                    <playcount>0</playcount>
                    <watched>false</watched>

                <title>$t_name</title>
        
                $genre
                $studio2
                $actor
           
                </movie>
                    ";

                if(![System.IO.File]::Exists("$p`\$file_name"))
                {
                    New-Item -Path $p2 -Name "$file_name" -Type "file" -Value $file
                    Write-Host "Created new file and text content added";
                }
          }
}