 # 输入路径
$videoDir = Read-Host "请输入【视频文件夹路径】"
$coverDir = Read-Host "请输入【封面图片文件夹路径】"

if (!(Test-Path $videoDir)) {
    Write-Host "视频文件夹不存在"
    pause
    exit
}

if (!(Test-Path $coverDir)) {
    Write-Host "封面文件夹不存在"
    pause
    exit
}

# 排序读取
$videos = Get-ChildItem $videoDir -Filter *.mp4 | Sort-Object Name
$covers = Get-ChildItem $coverDir -Filter *.jpg | Sort-Object Name

$count = [Math]::Min($videos.Count, $covers.Count)

for ($i = 0; $i -lt $count; $i++) {

    $video = $videos[$i].FullName
    $cover = $covers[$i].FullName
    $tmp   = Join-Path $videoDir ("_tmp_" + $videos[$i].Name)

    Write-Host "[$($i+1)] $($videos[$i].Name) ← $($covers[$i].Name)"

    ffmpeg -y `
        -i "$video" `
        -i "$cover" `
        -map 0 `
        -map 1 `
        -c copy `
        -disposition:v:1 attached_pic `
        "$tmp"

    Move-Item -Force "$tmp" "$video"
}

Write-Host ""
Write-Host "? 封面替换完成"
pause 
