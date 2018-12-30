cls
$p = "A:\FM\[GammaEntertainment]\[GirlFriendsFilms]\Hot Lesbian Love\01"
$p2 = "A:\FM\``[GammaEntertainment``]\``[GirlFriendsFilms``]\Hot Lesbian Love\01"
cd "$p2"
$add_new_studio=0;

if(-not $loc){$global:loc= $env:OneDrive+"\Powershell\New Way"}

."$loc\Config.ps1"
."$loc\Funcations.ps1"

$regex = "\[([\w|\s*-]+)\]([\w|\s]+(?:\[[\w|\s]+\])?.*)\s*-\s*([\w|,|\s.']+)";
$option = [System.StringSplitOptions]::RemoveEmptyEntries

Get-ChildItem -LiteralPath $p -Filter *.mp4 |
    ForEach-Object {
        $name = $_.BaseName
        $NFOName = $name +".nfo";
        $groups = [regex]::Match($name, $regex).Captures.Groups

        if($groups)
        {
            if (![System.IO.File]::Exists("$p`\$NFOName"))
            {
                #get studio info
                $studioName_c = $groups[1].Value.Trim()
                try{
                    $studio = Get-ConfigItem -Scope 'StudioName' -Key $studioName_c
                }catch{
                    Write-Error "Studio Not found. Lets try to add it"
                }

                if($studio)
                {
                    #studio information
                    $stud=$studio.Split(",", $option);
                    $studio2=$null
                    foreach ($stu in $stud)
                    {
                       $studio2+= "<studio>$stu</studio>";
                    }

                    #lets check to see if video has genre setup
                    $tp = $p+"\"+$_.Name
                    $video_genre = Get-Video-Genre($tp);
                    $Category=''
                    $default=$false
                    if($video_genre)
                    {
                        $g = $video_genre.Split(",", $option);
                        #if its more then 1 catgory then do this
                        if($g -is [system.array] -and $g.Length -gt 1)
                        {
                            foreach ($s in $g)
                            {
                                $Category += Get-ConfigItem -Scope 'Category' -Key $s.Trim()
                                $Category+=','
                                if($s -eq "lesbian" -or $s -eq "sex" -or $s -eq "solo"){$default=$true}
                            }

                        }else{
                            #if single catgory is found then do this
                            $s=$video_genre.Trim()
                            $Category += Get-ConfigItem -Scope 'Category' -Key $s
                            if($s -eq "lesbian" -or $s -eq "sex" -or $s -eq "solo"){$default=$true}
                        }

                        #if main catgory is not found then do this
                        if(-not $default )
                        {
                            Write-Warning "Main Catgory not found so lets add it from Studio Main Category"
                            $Category += ','
                            $c=Get-ConfigItem -Scope 'StudioMainCategory' -Key $studioName_c
                            $cc=$c.Split(",", $option);
                            $c=''
                            foreach ($c in $cc)
                            {
                                $Category += Get-ConfigItem -Scope 'Category' -Key $c.Trim()
                                $Category+=','
                            }
                        }
                    }else{#if genre is empty then look for catgory in xml file, this will be main catgory
                        Write-Warning "Genre is not found inside video"
                        $Category += ','
                        $c=Get-ConfigItem -Scope 'StudioMainCategory' -Key $studioName_c
                        $cc=$c.Split(",", $option);
                        $c=''
                        foreach ($c in $cc)
                        {
                            $Category += Get-ConfigItem -Scope 'Category' -Key $c.Trim()
                            $Category+=','
                        }
                    }
                    #end of catgory

                    #star info now
                    $star= $groups[3].Value.Trim();
                    $st = $star.Split(",", $option);
                    $actor=$null;
                    if($st -is [system.array] -and $st.Length -gt 1)
                    {
                        $star=@()
                        foreach ($s in $st)
                        {
                           #check to see if star has a alias, if yes then get it
                           $sts = Get-ConfigItem -Scope 'StarsAlias' -Key $s.Trim()
                           if ($sts){$sts=$sts}else{$sts=$s.Trim()}
                           #check and get catgory for stars, if assign any
                           $c=(Get-ConfigItem -Scope 'StarCategory' -Key $sts);
                           if($c){$Category+=','+$c}
                           #create xml actor data
                           $actor+= "
                                      <actor><name>$sts</name><type>Actor</type></actor>
                                    ";
                            $star+=$sts;
                        }#end foreach
                    }else{
                        #check to see if star has a alias, if yes then get it
                        $sts = Get-ConfigItem -Scope 'StarsAlias' -Key $star
                        if ($sts){$sts=$sts}else{$sts=$star}
                        #check and get catgory for stars, if assign any
                        $c=(Get-ConfigItem -Scope 'StarCategory' -Key $sts);
                        if($c){$Category+=','+$c}
                        #create xml actor data
                        $actor= "
                                  <actor><name>$sts</name><type>Actor</type></actor>
                                ";
                        $star=$sts
                    }
                
                    #now lets put the catgory into xml format
                    $Category = $Category + ","+$studio
                    $Category=$Category.Split(",", $option);
                    $genre=$null
                    foreach ($c in $Category)
                    {
                        $c=$c -replace "&", "&amp;";
                        $genre+="<genre>"+$c.Trim()+"</genre>";
                    }

                    #now lets put the xml together
                    $Title  = $groups[2].Value.Trim() -replace "&", "&amp;";
                    $star = $star -join ", "
                    $Title = $Title + " - " + $star
                    
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

                    <title>$Title</title>

                    $genre
                    $studio2
                    $actor
           
                    </movie>
                        ";

                    #now let save the nfo file
                    if(![System.IO.File]::Exists("$p`\$NFOName"))
                    {
                        New-Item -Path "$p2" -Name "$NFOName" -Type "file" -Value $file;
                        Write-Host "Created new file and text content added";
                    }
                }
                else
                {
                    if($add_new_studio -eq 1)
                    {
                        #//try adding the studio
                        Write-Warning "Studio not found so lets add one"

                        $sn = Read-Host "Enter Studio Name for $studioName_c e.g. Sweetheart Video"
                        $sn
                        $c = Read-Host "Enter $studioName_c ($sn) Main Catgory e.g. Sex or lesbian or belowjob"
                        try{
                            if($sn)
                            {
                                try{
                                    Set-ConfigItem -Scope StudioName -Key $studioName_c -Value "$sn"
                                    Write-Host "Studio Name writen: $studioName_c - $sn"
                                }catch{
                                    Write-Warning "Studio Name not saved"
                                }
                            }
                    
                            if($c)
                            {
                                try{
                                    Set-ConfigItem -Scope 'StudioMainCategory' -Key $studioName_c -Value $c
                                    Write-Host "Studio $sn Main Catgory Saved"
                                }catch{
                                    Write-Warning "Studio Main Catgory is not saved"
                                }
                            }
                        }catch{
                            Write-Warning "Unable to add Studio Name/Catgory"
                        }
                    }
                }
            }
        }
        
        else
        {
            Write-Warning "Your file is not correct format ""[Studio] File Name - Stars,star2"" $name"
        }
    }