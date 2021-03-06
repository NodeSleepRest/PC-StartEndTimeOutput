$strStartEndInfo = [string]
$strStartUpTime = [string]
$strStartUpTimePath
$strFilePath
$intTotalCount
$intCountPerDate = 0
$dateTemp
$timeTemp
$arrDisp = @()

Split-Path $MyInvocation.MyCommand.path | Set-Location

#xmlファイルの読み込み
$xml = [XML](Get-Content -Encoding UTF8 ".\初期設定.xml") 

$strStartUpTimePath = $xml.path.Item("startuptimepath")."#text"
$strFilePath = $xml.path.Item("filepath")."#text"

#「システム」のイベントログを2000件取得し、ログオン/ログオフのログだけを抽出。
# さらにログ作成時間だけを変数に格納
$strStartEndInfo = Get-Eventlog system -newest 2000 | Where-Object {$_.InstanceID -eq 7001 -or $_.InstanceID -eq 7002} `
| Select-Object TimeGenerated

#抽出したログ作成時間を起動情報.txtに書き込み
$strStartEndInfo | Out-File -FilePath $strStartUpTimePath

$datetimeFile = Get-Content $strStartUpTimePath

$intTotalCount = $datetimeFile.Length

for($i=3;$i-lt$intTotalCount-2;$i++){
    #現在の行が一つ前の行の日付と異なる場合（新しい日付の行に入った場合）
    If($datetimeFile[$i].Substring(0,10) -ne $dateTemp){
        $arrDisp += New-Object PSObject -Property @{date=$datetimeFile[$i].Substring(0,10); end=$datetimeFile[$i].Substring(11).Trim(); start=""}
        If($intCountPerDate -gt 0 -and $intCountPerDate -gt 1){
            $arrDisp[$intCountPerDate-1].start = $timeTemp
        }
        $intCountPerDate++
    }
    $dateTemp = $datetimeFile[$i].Substring(0,10)
    $timeTemp = $datetimeFile[$i].Substring(11).Trim()
}

Write-Output $arrDisp

$arrDisp | Out-File -FilePath $strFilePath