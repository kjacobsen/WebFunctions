Function Get-WebPage 
{
    <#
        .SYNOPSIS
        Get a webpage

        .DESCRIPTION
        Gets the webpage at the specified URL and returns the string representation of that page. Webpages can be accessed over an URI including http://, Https://, file://, \\server\folder\file.txt etc.

        .PARAMETER URL
        The url of the page we want to download and save as a string. URL must have format like: http://google.com, https://microsoft.com, file://c:\test.txt

        .PARAMETER Credentials
        [Optional] Credentials for remote server

        .PARAMETER WebProxy
        [Optional] Web Proxy to be used, if none supplied, System Proxy settings will be honored

        .PARAMETER Headers
        [Optional] Used to specify additional headers in HTTP request

        .INPUTS
        Nothing can be piped directly into this function

        .OUTPUTS
        String representing the page at the specified URL

        .EXAMPLE
        Get-Webpage "http://google.com"
        Gets the google page and returns it

        .NOTES
        NAME: Get-WebPage
        AUTHOR: kieran@thekgb.su
        LASTEDIT: 2012-10-14 9:15:00
        KEYWORDS:

        .LINK
        http://aperturescience.su/
    #>
    [CMDLetBinding()]
    Param
    (
        [Parameter(mandatory = $true)] [String] $URL,
        [System.Net.ICredentials] $Credentials,
        [System.Net.IWebProxy] $WebProxy,
        [System.Net.WebHeaderCollection] $Headers
    )

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

    #contains resultant page
    $result = $null

    $result = $webclient.downloadstring($URL)

    return $result
}
