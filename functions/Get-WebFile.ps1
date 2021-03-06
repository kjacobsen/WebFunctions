Function Get-WebFile 
{
    <#
        .SYNOPSIS
        Gets a file off the interwebs.

        .DESCRIPTION
        Gets the file at the specified URL and saves it to the hard disk. Files can be accessed over an URI including http://, Https://, file://,  ftp://, \\server\folder\file.txt etc.

        Specification of the destination filename, and/or directory that file(s) will be saved to is supported. 
        If no directory is supplied, files downloaded to current directory.
        If no filename is specified, files downnloaded with have filenamed based on URL, eg http://live.sysinternals.com/procexp.exe downloaded to proxecp.exe, http://google.com downloaded to google.com

        By default if a file already exists at the specified location, an exception will be generated and execution terminated.
        Will pass any errors encountered up to caller!

        .PARAMETER URL
        [Pipeline] The url of the file we want to download. URL must have format like: http://google.com, https://microsoft.com, file://c:\test.txt

        .PARAMETER Filename
        [Optional] Filename to save file to

        .PARAMETER Directory
        [Optional] Directory to save the file to

        .PARAMETER Credentials
        [Optional] Credentials for remote server

        .PARAMETER WebProxy
        [Optional] Web Proxy to be used, if none supplied, System Proxy settings will be honored

        .PARAMETER Headers
        [Optional] Used to specify additional headers in HTTP request

        .PARAMETER clobber
        [SWITCH] [Optional] Do we want to overwrite files? Default is to throw error if file already exists.

        .INPUTS
        Accepts strings representing URI to files we want to download from pipeline

        .OUTPUTS
        No output

        .EXAMPLE
        get-webfile "http://live.sysinternals.com/procexp.exe"

        .EXAMPLE
        get-webfile "http://live.sysinternals.com/procexp.exe" -filename "pants.exe"
        Download file at url but save as pants.exe

        .EXAMPLE
        gc filelist.txt | get-webfile -directory "c:\temp"
        Where filelist.txt contains a list of urls to download, files downloaded to c:\temp

        .NOTES
        NAME: Get-WebFile
        AUTHOR: kieran@thekgb.su
        LASTEDIT: 2012-10-14 9:15:00
        KEYWORDS: webclient, proxy, web, download

        .LINK
        http://aperturescience.su/
    #>
    [CMDLetBinding()]
    param
    (
        [Parameter(mandatory = $true, valuefrompipeline = $true)][String] $URL,
        [String] $Filename,
        [String] $Directory,
        [System.Net.ICredentials] $Credentials,
        [System.Net.IWebProxy] $WebProxy,
        [System.Net.WebHeaderCollection] $Headers,
        [switch] $Clobber
    )

    Begin
    {
        #make a webclient object
        $webclient = New-Object -TypeName Net.WebClient

        #set the pass through variables if they are not null
        if ($Credentials) 
        {
            $webclient.credentials = $Credentials
        }
        if ($WebProxy) 
        {
            $webclient.proxy = $WebProxy
        }
        if ($Headers) 
        {
            $webclient.headers.add($Headers)
        }
    }

    Process 
    {
        #destination to download file to
        $Destination = ''

        <#
            This is a very complicated bit of code, but it handles all of the possibilities for the filename and directory parameters

            1) If both are specified -> join the two together
            2) If no filename or destination directory is specified -> the destination is the current directory (converted from .) joined with the "leaf" part of the url
            3) If no filename is specified, but a directory is -> the destination is the specified directory joined with the "leaf" part of the url
            4) If filename is specified but a directory is not -> The destination  is the current directory (converted from .) joined with the specified filename
        #>
        if (($Filename -ne '') -and ($Directory -ne '')) 
        {
            $Destination = Join-Path -Path $Directory -ChildPath $Filename
        } 
        elseif ((($Filename -eq $null) -or ($Filename -eq '')) -and (($Directory -eq $null) -or ($Directory -eq ''))) 
        {
            $Destination = Join-Path -Path (Convert-Path -Path '.') -ChildPath (Split-Path -Path $URL -Leaf)
        } 
        elseif ((($Filename -eq $null) -or ($Filename -eq '')) -and ($Directory -ne '')) 
        {
            $Destination = Join-Path -Path $Directory -ChildPath (Split-Path -Path $URL -Leaf)
        } 
        elseif (($Filename -ne '') -and (($Directory -eq $null) -or ($Directory -eq ''))) 
        {
            $Destination = Join-Path -Path (Convert-Path -Path '.') -ChildPath $Filename
        }

        <#
            If the destination already exists and if clobber parameter is not specified then throw an error as we don't want to overwrite files, 
            else generate a warning and continue
        #>
        if (Test-Path $Destination) 
        {
            if ($Clobber) 
            {
                Write-Warning -Message 'Overwritting file'
            } 
            else 
            {
                throw "File already exists at destination: $Destination, specify -Clobber to overwrite"
            }
        }

        Write-Verbose -Message "Downloading $URL to $Destination"
        $webclient.DownloadFile($URL, $Destination)

    }
}
