function Show-Image{
param(
[Parameter(Mandatory=$True,Position=1)][string]$Source,
[Parameter(Mandatory=$False,Position=2)][string]$FormName='Image'
#<TODO><NiceToHave> Add 3rd parameter for scaling
)
# Loosely based on http://www.vistax64.com/powershell/202216-display-image-powershell.html
 
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
 
write-host $Source

#$file = (get-item 'C:\Users\Public\Pictures\Sample Pictures\Chrysanthemum.jpg')
$file = (get-item $Source)
 
$img = [System.Drawing.Image]::Fromfile($file);
 
# This tip from http://stackoverflow.com/questions/3358372/windows-forms-look-different-in-powershell-and-powershell-ise-why/3359274#3359274
[System.Windows.Forms.Application]::EnableVisualStyles();
$form = new-object Windows.Forms.Form
$form.Text = $FormName
$form.Width = $img.Size.Width;
$form.Height =  $img.Size.Height;
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Width =  $img.Size.Width;
$pictureBox.Height =  $img.Size.Height;
 
$pictureBox.Image = $img;
$form.controls.add($pictureBox)
$form.Add_Shown( { $form.Activate() } )
$form.ShowDialog()
 
}

#[Reflection.Assembly]::LoadWithPartialName("System.Drawing")
function Screenshot([Drawing.Rectangle]$bounds, $path) {
   $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
   $graphics = [Drawing.Graphics]::FromImage($bmp)

   $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)

   $bmp.Save($path)

   $graphics.Dispose()
   $bmp.Dispose()
}
<#Wrapper for full screen screenshot#>
function FullScreenshot{
param(
[Parameter(Mandatory=$True,Position=1)][string]$File
)
Add-Type -AssemblyName System.Windows.Forms
$screens = [System.Windows.Forms.Screen]::AllScreens

Screenshot $screens.bounds $File

<#
Custom solution based on:
https://stackoverflow.com/questions/2969321/how-can-i-do-a-screen-capture-in-windows-powershell
https://stackoverflow.com/questions/7967699/get-screen-resolution-using-wmi-powershell-in-windows-7

Also there is Microsoft-made solution for that:
https://gallery.technet.microsoft.com/scriptcenter/eeff544a-f690-4f6b-a586-11eea6fc5eb8
#>
}

function CheckForPath{
    param(
    [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "path", 
            ValueFromPipeline = $True)] 
            [string]$path, 
    [Parameter( 
            Mandatory = $True, 
            ParameterSetName = "sought", 
            ValueFromPipeline = $True)] 
            [string]$sought
    )

    $found = $False
    Get-ChildItem -Path $path | ForEach-Object {
       if ($found -eq $False -and $_.name -eq $sought) {$found=$True}
    }
    return $found
}

function Check-ProcessPorts {
param(
    [string]$processname
    )

$Process = get-process "*$processname*"
if (!$Process) {
write-host "No such process as $processname found"
} else {
$PProcess | ForEach-Object{Get-NetTCPConnection -OwningProcess $Process.Id | write-host}
}

}


<#-----------------------------For testing --------------------------------------#>
<#
FullScreenshot "Testimage.jpg"
Show-Image 'Testimage.jpg' 'You can input your text here'
CheckForPath -sought "Testimage.jpg" | Write-Host;
#Check-ProcessPorts 'firefox'
#>
