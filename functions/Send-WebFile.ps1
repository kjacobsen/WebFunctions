Function Send-WebFile 
{
    <#
        .SYNOPSIS
        Sends a file to the interwebs.

        .DESCRIPTION
        Uploads file to URL specified, appending the filename to the end of the url. In theory supports HTTP, HTTPS, FTP, FTPS, URLs. 
        For WebDav use method PUT, for FTP, leave out or use STOR.
        Note, I have written function send-webdavfile for uploading files to webdav pages (simply calls this function with correct webmethod)
        Also works really well for file:// and \\server\share paths.
        Will pass any errors encountered up to caller!

        .PARAMETER URL
        The URL the file will be uploaded to. Format can be Protocol://servername/ or Protocol://server, destination filename should NOT be specified

        .PARAMETER LocalFile
        [PIPELINE] The localfile(s) to be uploaded.

        .PARAMETER WebMethod
        [Optional] This is the HTTP method used to upload data, examples include POST (DEFAULT), STOR, PUT.

        .PARAMETER Credentials
        [Optional] Credentials for remote server

        .PARAMETER WebProxy
        [Optional] Web Proxy to be used, if none supplied, System Proxy settings will be honored

        .PARAMETER Headers
        [Optional] Used to specify additional headers in HTTP request

        .INPUTS
        Accepts strings of paths to files in Pipeline

        .OUTPUTS
        If data is returned by source, that data will be returned as an ascii string, otherwise null is returned.

        .EXAMPLE
        Send-WebFile http://myserver/folder c:\myfile.txt
        Sends the file myfile to the folder, folder, on myserver

        .EXAMPLE
        dir c:\afolder | foreach { $_.fullname} | send-webfile "ftp://myftpserver"
        Get a directory list of c:\afolder, list their fullnames, and then ftp the files to myftpserver

        .NOTES
        NAME: Send-Webfile
        AUTHOR: kieran@thekgb.su
        LASTEDIT: 2012-10-14 9:15:00
        KEYWORDS:

        .LINK
        http://aperturescience.su/
    #>
    [CMDLetBinding()]
    param
    (
        [Parameter(mandatory = $true)] [String] $URL,
        [Parameter(mandatory = $true, valuefrompipeline = $true)] [String] $LocalFile,
        [String] $WebMethod,
        [System.Net.ICredentials] $Credentials,
        [System.Net.IWebProxy] $WebProxy,
        [System.Net.WebHeaderCollection] $Headers
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

        #Set the encoding type, we will use UTF8
        $webclient.Encoding = [System.Text.Encoding]::UTF8

    }

    Process 
    {
        #test that the file we are trying to send exists, else throw error.
        if (! (Test-Path $LocalFile)) 
        {
            Throw "Could not find local file $LocalFile"
        }

        #get the shot name for the file, that is, for c:\folder\file.txt, we just want the file.txt part
        $shortfilename = Split-Path -Path $LocalFile -Leaf

        #the remote url will need to have a filename put on the end, but we need to be careful as the user might have already put a trailing backslash
        if ($URL.EndsWith('/')) 
        {
            $fullurl = $URL + $shortfilename
        } 
        else 
        {
            $fullurl = $URL + '/' + $shortfilename
        }

        #the result variable will contain the body/page that is return to us when we upload the file (usefulness may vary)
        $result = $null

        #if webmethod was specified, call upload file, specifying that method, otherwise use the usualy upload file and let webclient pick the method
        if ($WebMethod) 
        {
            Write-Verbose -Message "Uploading $LocalFile to $fullurl using method $WebMethod"
            $result = $webclient.UploadFile($fullurl, $WebMethod, $LocalFile)
        } 
        else 
        {
            Write-Verbose -Message "Uploading $LocalFile to $fullurl using method autoselected"
            $result = $webclient.UploadFile($fullurl, $LocalFile)
        }

        #if we got a result (we might not if an error occured, then format that data back to a string, otherwise, as we got no data
        if ($result) 
        {
            Write-Verbose -Message 'Remote sent response'
            return [System.Text.Encoding]::ASCII.GetString($result)
        } 
        else 
        {
            Write-Verbose -Message 'No Response from Remote'
            return $null
        }
    }
}
