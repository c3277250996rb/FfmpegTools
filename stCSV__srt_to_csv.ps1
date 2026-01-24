param (
    [Parameter(Mandatory = $true)]
    [string]$srt
)

if (!(Test-Path $srt)) {
    Write-Host "文件不存在"
    exit
}

$out = [System.IO.Path]::ChangeExtension($srt, ".csv")

function TimeToSec($t) {

    # 严格匹配：HH:MM:SS,mmm
    if ($t -match '^(\d{2}):(\d{2}):(\d{2}),(\d{3})$') {

        $h = [int]$matches[1]
        $m = [int]$matches[2]
        $s = [int]$matches[3]
        $ms = [int]$matches[4]

        $sec =
            ($h * 3600) +
            ($m * 60) +
            $s +
            ($ms / 1000.0)

        return [Math]::Round([double]$sec, 3)
    }

    return $null
}

$lines = Get-Content $srt -Encoding UTF8
$result = @()

$i = 0
while ($i -lt $lines.Count) {

    # 序号行
    if ($lines[$i] -match '^\d+$') {

        $no = [int]$lines[$i]
        $i++

        # 时间轴
        if ($lines[$i] -match '(.+?) --> (.+)') {

            $t1 = TimeToSec $matches[1].Trim()
            $t2 = TimeToSec $matches[2].Trim()

            if ($t1 -ne $null -and $t2 -ne $null) {
                $start = $t1
                $length = [Math]::Round($t2 - $t1, 3)
            }
            else {
                $i++
                continue
            }

            $i++
        }
        else {
            $i++
            continue
        }

        # 字幕内容（支持多行）
        $text = ""
        while ($i -lt $lines.Count -and $lines[$i].Trim() -ne "") {
            if ($text -ne "") { $text += " " }
            $text += $lines[$i].Trim()
            $i++
        }

        $result += [PSCustomObject]@{
            no      = $no
            start  = "{0:F3}" -f $start
            length = "{0:F3}" -f $length
            string = $text
        }
    }

    $i++
}

$result | Export-Csv $out -Encoding UTF8 -NoTypeInformation
Write-Host "完成：$out"
