Describe "Testing URLs from PowerShell Modules Central repository" {
    #RegEx to gather URLs
    $regex = [regex]"(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'`".,<>?«»“”‘’]))"

    #Get current path
    $path = $PWD.Path
    #$path = Split-Path -Path $PWD.Path -Parent

    #Get FullName (aka path) from readme.md
    $repoStructure = @()
    $repoStructure += (Get-ChildItem -Path $path -Filter "readme.md").FullName

    #Exclude some folders
    $repoFolderStructure = Get-ChildItem -Path $path -Directory | Where-Object Name -NotMatch "\.github|\.git|Tests"

    foreach ($dir in ($repoFolderStructure)) {
        #Get FullName (aka path) from sub-folders
        $repoStructure += (Get-ChildItem -Path $dir.FullName -Filter "*.md").FullName

        $allURLs = @()

        #Get all URLs from all files
        foreach ($md in $repoStructure) {
            $allURLs += Select-String $regex -input (Get-Content $md) -AllMatches | ForEach-Object {$_.matches.Value}
        }
        $allURLs = $allURLs | Select-Object -Unique

        Write-Warning "Will test $($allURLs.Count) URLs"

        foreach ($url in $allURLs) {
            Context "Checking successful request" {
                It "Testing access to $url should be 200 (OK)"{
                    #We read the Version property
                    (Invoke-WebRequest -Uri $url).StatusCode | Should Be 200
                }
            }
        }
    }
}
