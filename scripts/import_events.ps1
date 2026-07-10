param([string]$Workbook = "EJ_North_Jersey_Lifestyle_Database_2026_FIXED.xlsx", [string]$Output = "src/data/events.json")
$ErrorActionPreference='Stop'; $root=Split-Path $PSScriptRoot -Parent; $src=Join-Path $root $Workbook; $tmp=Join-Path $env:TEMP ("ej-events-"+[guid]::NewGuid())
New-Item -ItemType Directory $tmp|Out-Null
try {
  Copy-Item $src (Join-Path $tmp 'book.zip'); Expand-Archive (Join-Path $tmp 'book.zip') (Join-Path $tmp 'x')
  $xl=Join-Path $tmp 'x/xl'; [xml]$ss=Get-Content -Raw (Join-Path $xl 'sharedStrings.xml')
  $strings=@($ss.sst.si|ForEach-Object { if($_.t){[string]$_.t}else{($_.r|ForEach-Object{$_.t}) -join ''} })
  [xml]$sheet=Get-Content -Raw (Join-Path $xl 'worksheets/sheet2.xml'); $ns=New-Object Xml.XmlNamespaceManager($sheet.NameTable); $ns.AddNamespace('m','http://schemas.openxmlformats.org/spreadsheetml/2006/main')
  function Val($c){ if($c.t -eq 's'){return $strings[[int]$c.v]}; if($c.t -eq 'inlineStr'){return [string]$c.is.t}; return [string]$c.v }
  function Col($r){ $letters=$r -replace '\d',''; $n=0; $letters.ToCharArray()|%{$n=$n*26+([int]$_-[int][char]'A'+1)}; $n-1 }
  $rows=@($sheet.SelectNodes('//m:sheetData/m:row',$ns)); $headers=@{}; foreach($c in $rows[0].c){$headers[(Col $c.r)]=(Val $c)}
  $events=@(); $seen=@{}; $warnings=@()
  foreach($row in $rows|Select-Object -Skip 1){ $raw=@{}; foreach($c in $row.c){$raw[$headers[(Col $c.r)]]=Val $c}; if(-not (($raw.Values -join '').Trim())){continue}
    $date=''; if($raw.Date){ if($raw.Date -match '^\d+(\.\d+)?$'){$date=[datetime]::FromOADate([double]$raw.Date).ToString('yyyy-MM-dd')}else{try{$date=([datetime]$raw.Date).ToString('yyyy-MM-dd')}catch{$warnings+="Row $($row.r): bad date '$($raw.Date)'"}} }
    function Time($v){if(-not $v){return $null}; if($v -match '^\d+(\.\d+)?$'){return [datetime]::FromOADate([double]$v).ToString('HH:mm')}; try{return ([datetime]$v).ToString('HH:mm')}catch{return $null}}
    function Num($v){if($null -eq $v -or $v -eq ''){return $null}; $n=0.0;if([double]::TryParse(($v -replace '[^0-9.-]',''),[ref]$n)){return $n};return $null}
    function Bool($v){if($null -eq $v -or $v -eq ''){return $null}; return [bool](($v -as [string]) -match '^(yes|y|true|1|verified)$')}
    $id=if($raw.'Event ID'){$raw.'Event ID'}else{"event-$($row.r)"}; $key=("$date|$($raw.Start)|$($raw.Event)|$($raw.Town)|$($raw.Venue)").ToLower()
    if($seen[$key]){$warnings+="Row $($row.r): duplicate of $($seen[$key])";continue};$seen[$key]=$id
    $issues=@(); if(-not $date){$issues+='date'};if(-not $raw.Event){$issues+='name'};if(-not $raw.Town){$issues+='town'}
    $events += [ordered]@{id=$id;date=$date;start=(Time $raw.Start);end=(Time $raw.End);name=$raw.Event;town=$raw.Town;venue=$raw.Venue;category=$raw.Category;genre=$raw.'Genre / Theme';rating=(Num $raw.'Star Rating');dateNightScore=(Num $raw.'Date Night Score');familyScore=(Num $raw.'Family Score');cost=$raw.Cost;outdoor=(Bool $raw.'Outdoor?');weatherDependent=(Bool $raw.'Weather Dependent?');bringChairs=(Bool $raw.'Bring Chairs?');food=$raw.'Food / Drink?';parking=$raw.Parking;notes=$raw.Notes;sourceType=$raw.'Source Type';sourceUrl=$raw.'Source URL';verified=(Bool $raw.Verified);updated=$raw.'Added / Updated';issues=$issues}
  }
  $out=Join-Path $root $Output; New-Item -ItemType Directory (Split-Path $out) -Force|Out-Null; $events|ConvertTo-Json -Depth 6|Set-Content -Encoding utf8 $out
  "Imported $($events.Count) unique events. Warnings: $($warnings.Count)"; $warnings|%{"WARNING: $_"}
} finally {Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue}
