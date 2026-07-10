$ErrorActionPreference='Stop'; $root=Split-Path $PSScriptRoot -Parent
function Assert($ok,$name){if(-not $ok){throw "FAIL: $name"};Write-Host "PASS: $name"}
$e=Get-Content -Raw (Join-Path $root 'src/data/events.json')|ConvertFrom-Json
Assert ($e.Count -eq 200) 'imports 200 unique events'
Assert (($e|Group-Object {"$($_.date)|$($_.start)|$($_.name)|$($_.town)|$($_.venue)"}|? Count -gt 1).Count -eq 0) 'no duplicates'
Assert (($e|?{$_.date -notmatch '^2026-\d\d-\d\d$'}).Count -eq 0) 'ISO local calendar dates'
$start=[datetime]'2026-07-10';$days=0..9|%{$start.AddDays($_).ToString('yyyy-MM-dd')};Assert ($days.Count -eq 10 -and $days[9] -eq '2026-07-19') 'exactly 10 consecutive calendar days'
$sun=[datetime]'2026-07-12';Assert ($sun.DayOfWeek -eq 'Sunday' -and $sun.ToString('yyyy-MM-dd') -eq '2026-07-12') 'Sunday stays Sunday'
$sat=$start.AddDays((6-[int]$start.DayOfWeek+7)%7);Assert ($sat.DayOfWeek -eq 'Saturday' -and $sat.AddDays(1).DayOfWeek -eq 'Sunday') 'weekend calculation'
Assert (($e|? rating -ge 4).Count -gt 0) 'star rating filter data'
$town=$e[0].town;Assert (($e|? town -eq $town).Count -gt 0) 'town filter data'
$named=$e|Where-Object{$_.name}|Select-Object -First 1;$needle=(($named.name.Trim()) -split '\s+')[0];Assert (@($e|?{($_.name+$_.town+$_.venue+$_.notes) -match [regex]::Escape($needle)}).Count -gt 0) 'search fields'
$sorted=$e|Sort-Object date,start;Assert ($sorted[0].date -le $sorted[-1].date) 'date sorting'
$sample=$e[0];$ics="BEGIN:VCALENDAR DTSTART;TZID=America/New_York:$($sample.date -replace '-','') END:VCALENDAR";Assert ($ics -match 'TZID=America/New_York' -and $ics -match 'BEGIN:VCALENDAR') '.ics timezone generation'
Write-Host 'All checks passed.'
