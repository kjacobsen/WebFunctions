Function Send-WebDAVFile 
{
    <#
        .SYNOPSIS
        Specifically designed function for uploading files to WebDAV shares. It specifically does not require webmethods to be specified.

        .DESCRIPTION
        Uploads file to URL specified, appending the filename to the end of the url. In theory supports HTTP, HTTPS, based WebDAV.
        Will pass any errors encountered up to caller!

        .PARAMETER URL
        The URL the file will be uploaded to. Format can be Protocol://servername/ or Protocol://server, destination filename should NOT be specified

        .PARAMETER LocalFile
        The localfile(s) to be uploaded. Supports Value From Pipeline

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
        Send-WebDAVFile http://myserver/webfolder c:\myfile.txt
        Sends the file myfile to the webdav folder, webfolder, on myserver

        .EXAMPLE
        dir c:\afolder | foreach { $_.fullname} | send-webdavfile "https://myserver/web"
        Get a directory list of c:\afolder, list their fullnames, and then send them to the web folder on myserver

        .EXAMPLE
        Upload-WebDAVFile -URL 'https://server/checkin' -LocalFile D:\Desktop\apps.txt -Credentials (New-Object system.net.networkcredential("username","password","domain"))
        Upload a file, specifying a login credential

        .NOTES
        NAME: Send-WebDAVFile
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
        [System.Net.ICredentials] $Credentials,
        [System.Net.IWebProxy] $WebProxy,
        [System.Net.WebHeaderCollection] $Headers
    )

    begin 
    {
        #check if we can access the upload values method
        if ((Get-Command Send-Webfile -ErrorAction silentlycontinue) -eq $null) 
        {
            throw 'Could not find the function Send-Webfile'
        }
    }

    process 
    {
        Send-Webfile -url $URL -localfile $LocalFile -webmethod 'PUT' -credentials $Credentials -webproxy $WebProxy -headers $Headers
    }
}
