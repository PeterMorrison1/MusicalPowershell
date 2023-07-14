$csv = Import-Csv .\note_frequency.csv
function GetFrequency($test) {
    $result = $csv | Where-Object -Property Note -Like $test
    $alternativetest = "$($test)4"
    
    if (-not $result) {
        $result = $csv | Where-Object -Property Note -Like $alternativetest
    }

    if (-not $result) {
        $result = $csv | Where-Object -Property Note -Match $test
    }

    if (-not $result) {
        $result = $csv | Where-Object -Property Note -Match $alternativetest
    }

    if ($result) {
        return $result.Frequency
    } else {
        return 261.63
    }
    
}

function PlaySound($freq, $timing) {
    [Console]::Beep($freq, $timing)
}

Get-Content .\song.txt | Foreach-Object {
    
    # BPM TO FREQUENCY:
    # 60,000 (ms) / BPM = duration of a quarter note - so at 171 bpm its 351ms
    if ($_.Split(':') -Contains "BPM") {
        $bpm = $_.Split(': ')[-1]
        $speed = 60000 / $bpm 
    }
    else {
        $pairs = $_.Split(',')
        foreach ($pair in $pairs) {
            Write-Host $pair

            if ($pair -match "\/\d.\d+|\/\d") {
                $ModifierString = $Matches.Values.split('/')[1]
                [double]$modifier = [convert]::ToDouble($ModifierString)
                $pair = $pair.split('/')[0]
            } else {
                $modifier = 1
            }


            $splitpair = $pair.Split('-')
            $i = 0
            foreach ($key in $splitpair) {
                $i += 1

                try {
                    if (($splitpair[$i][0] -eq $key[0]) -and ($splitpair[$i] -match "\d") -and ($key -notmatch "\d")) {
                        [int]$splitvalue = [convert]::ToInt32($splitpair[$i][1], 10)
                        $key = "$($key)$($splitvalue - 1)"
                    }
                }
                catch {
                }
                $keyfreq = GetFrequency $key
                PlaySound $keyfreq ($speed * $modifier)
            }
            # Start-Sleep -Milliseconds ($speed * $modifier) /2
        }
    }

    
}
