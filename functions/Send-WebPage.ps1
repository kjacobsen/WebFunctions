Function Send-WebPage 
{
    <#
        .SYNOPSIS
        Sends data, POST, to a web page.

        .DESCRIPTION
        This function can be used to post a set of values to a web page. This function uses the webclient to upload a NameValueCollection of web parameters to the url specified. 
        The function will return the response from the server.

        .PARAMETER URL
        The URL we wish to post data to.

        .PARAMETER Values
        NameValueCollection, each is the URL parameters and their corresponding values. Eg, <User, BobSmith>

        .PARAMETER Credentials
        [Optional] Credentials for remote server

        .PARAMETER WebProxy
        [Optional] Web Proxy to be used, if none supplied, System Proxy settings will be honored

        .PARAMETER Headers
        [Optional] Used to specify additional headers in HTTP request

        .INPUTS
        Nothing can be piped directly into this function

        .OUTPUTS
        String, the response from the server.

        .EXAMPLE
        See ApertureScience.su for examples

        .NOTES
        NAME: Send-WebPage
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
        [Parameter(mandatory = $true)] [System.Collections.Specialized.NameValueCollection] $Values,
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

    Write-Verbose -Message "sending values to $URL"

    #some pages/sites return data to us, store in $result
    $result = $null

    #call upload values and POST data, throw on any errors
    $result = $webclient.UploadValues($URL, 'POST', $Values)

    #return the decoded response form UTF8
    return [System.Text.Encoding]::UTF8.GetString($result)
}
