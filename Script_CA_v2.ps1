$filterlist = "CAExchange", "CEPEncryption", "DomainController", "EFS", "EnrollmentAgentOffline", "Machine", "SubCA", "User", "WebServer", "EMPTY"
$formatdata2 = "dd/MM/yyyy hh:mm t t"
#setup duration

$duration = 60

$strDate = get-date -format yyyyMMdd-HHmmss
Write-Host $strDate

$exportFileName = “certificates_” + $strDate + “.csv”
$now = (Get-Date)
$Then = (Get-Date).AddDays($duration)
$mailbody = “”
$table = @()

$prueba1 = new-object system.collections.arraylist
 

certutil.exe -view csv > $exportFileName
 
$importall = Import-Csv $exportFileName | Where-Object {$_.‘Serial Number’ -notcontains ‘EMPTY’} | Select-Object -Property ‘Request ID’,‘Serial Number’,‘Requester Name’,‘Request Organization Unit’,‘Request Common Name’,‘Certificate Template’,‘Certificate Expiration Date’,‘Issued Distinguished Name’,‘Issued Common Name’ -ErrorAction SilentlyContinue

foreach ($OID in (Get-CATemplate).Oid)

{

    $importall | Where-Object “Certificate Template” -Match $OID | foreach-object {

        $_.‘Certificate Template’ = ($_.‘Certificate Template’).replace($OID+” “,“”)

    }

}

Write-Host $importall
$importall = $importall | Where-Object “Certificate Template” -in $filterlist

$mailbody += “The certificate expiry details:<br />”

$cultureinfo = Get-Culture

$formatdata = “$($cultureinfo.DateTimeFormat.ShortDatePattern) $($cultureinfo.DateTimeFormat.ShortTimePattern)“

for($i=0;$i -lt $importall.Count;$i++)

{
    
    $testdate = Get-date $importall[$i].‘Certificate Expiration Date’ -Format $formatdata
    $Certexpirydate = [datetime]::parseexact($testdate,'dd/MM/yyyy HH:mm',$null)
    
     If(($Certexpirydate -gt $now) -and ($Certexpirydate -le $then))

        {
           
            $date5 = $importall[$i].‘Certificate Expiration Date’ 
           
            $DateSystem = get-date  
            $DateCert = [datetime]::parseexact($date5,'dd/MM/yyyy HH:mm',$null)
             Write-Host $DateSystem
             Write-Host $DateCert

             $EXdATE = ($DateCert.Day - $DateSystem.Day)
        
             Write-Host $EXdATE
             
            write-host ‘Certificate ID:’ $importall[$i].‘Request ID’ -NoNewline 
            Write-Host ‘ with Serial Number:’ $importall[$i].‘Serial Number’ ‘will expire in ‘ -NoNewline 
            Write-Host '' $EXdATE 'Days!’-ForegroundColor Red
            write-host ‘This certificate has DN: ‘ -NoNewline
            write-host $importall[$i].‘Requester Name’ -ForegroundColor Cyan

            $table += $importall[$i] | Sort-Object ‘Certificate Expiration Date’ | Select-Object -Property ‘Request ID’,‘Serial Number’,‘Requester Name’,‘Request Organization Unit’,‘Request Common Name’,‘Certificate Template’,‘Certificate Expiration Date’,‘Issued Distinguished Name’,‘Issued Common Name’ 

        }

}

Write-Host $table  -ForegroundColor DarkYellow

#Configuracion correo 
$smtpFrom = “User_from@dominio.com”
$smtpTo = “User_to@dominio.com”  
$messageSubject = “Test_Subject”

#-----------------------------------------------------------------------------------------------------

$messageBody = "Hola, User: <p>"
$messageBody += "A continuacion encontrará la lista de <b><i>certificados que venceran</i></b>  en los próximos " + $duration +  " días" + "," + 'Favor de tomar las acciones correspondientes'
$messageBody += "<p>"
$messageBody += '<style type="text/css">'
$messageBody += '.tg  {border-collapse:collapse;border-spacing:0;}'
$messageBody += '.tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;'
$messageBody += 'overflow:hidden;padding:10px 5px;word-break:normal;}'
$messageBody += '.tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;'
$messageBody +=  'font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}'
$messageBody += '.tg .tg-0lax{text-align:left;vertical-align:top}'
$messageBody += '</style>'
$messageBody += '<p><table class="tg">'

$messageBody += ‘<th>Request ID</th><th>Serial Number</th><th>Requester Name</th><th>Request Organization Unit</th><th>Request Common Name</th><th>Certificate Template</th><th>Certificate Expiration Date</th><th>Issued Distinguished Name</th><th>Issued Common Name</th>’
foreach($row in $table)
    {

        $messageBody += “<tr><td>” + $row.‘Request ID’ + “</td><td>" + $row.‘Serial Number’ + "</td><td>” + $row.‘Requester Name’ + "</td><td>” + $row.‘Request Organization Unit’ + "</td><td>” + $row.‘Request Common Name’ + "</td><td>” + $row.‘Certificate Template’ + “</td><td>” + $row.‘Certificate Expiration Date’ + “</td><td>” + $row.‘Issued Distinguished Name’ + "</td><td>" + $row.‘Issued Common Name’ + "</td></tr>"
        
    }

$messageBody += ‘</table></p>’

$mail = New-Object System.Net.Mail.MailMessage $smtpFrom, $smtpTo, $messageSubject, $messageBody
$mail.IsBodyHtml=$true

#SMTP server
$smtpServer = “smtp.dominio.com”
$smtp = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
$smtp.EnableSsl = $true

#Credenciales de la cuenta de correo para envío de alertas
$smtp.Credentials = New-Object System.Net.NetworkCredential("User_to@dominio.com", "Password_email");

$smtp.Send($mail)  



