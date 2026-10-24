## Test-Palindrome

```powershell
process {
    $normalized = $Text.Normalize('FormD')
    $matches = Select-String -InputObject $normalized -Pattern '[\p{L}]' -AllMatches
    $clean = ($matches.Matches.Value -join '').ToLower()

    if (-not $clean) { return $true }

    $reversed = -join $clean[-1..-$clean.Length]
    $clean -eq $reversed
}
```

**Funkce:** Ověří, zda text čtený odpředu odpovídá textu čtenému odzadu – ignoruje mezery, číslice, interpunkci, velikost písmen i diakritiku.

**Regulární výraz:** `[\p{L}]` – znaková třída, matchne jeden znak, který je písmeno = letter. Po `Normalize('FormD')` se diakritická znaménka oddělí jako samostatné znaky kategorie `Mn`, takže do třídy nespadnou a zmizí spolu s mezerami a interpunkcí.

**Zvláštnosti kódu:**
- `Select-String -AllMatches` + `.Matches.Value -join ''` extrahuje jen vyhovující znaky (alternativa k `-replace`).
- `$clean[-1..-$clean.Length]` otočí řetězec záporným rozsahem indexů, bez `[Array]::Reverse()`.
- Prázdný/jednoznakový řetězec se vrátí rovnou jako `$true` (ochrana proti chybě při indexování prázdného řetězce).

---

## Get-TextStats

```powershell
process {
    $charsWithSpaces    = $Text.Length
    $charsWithoutSpaces = ($Text -replace '\s').Length

    $vowelMatches = Select-String -InputObject $Text.ToLower() `
        -Pattern '[aeiouyáéěíóúůý]' -AllMatches
    $vowelCount = $vowelMatches.Matches.Count

    $words     = $Text -split '\s+' | Where-Object { $_ -ne '' }
    $wordCount = $words.Count

    [PSCustomObject]@{ ... }
}
```

**Regulární výrazy:**
- `\s` – třída bílých znaků (mezera, tabulátor, konec řádku); použita pro odstranění mezer (`-replace '\s'`) i pro rozdělení na slova (`-split '\s+'`).
- `[aeiouyáéěíóúůý]` – ruční výčet znaků považovaných za české samohlásky (vč. `y`/`ý` a `ě`), porovnávaný po převodu textu na malá písmena.

**Zvláštnosti kódu:**
- Počet slov: `-split '\s+'` + odfiltrování prázdných položek (`Where-Object { $_ -ne '' }`) – ošetří víc mezer za sebou i mezery na okraji textu.
- Samohlásky se počítají přes `.Matches.Count` (počet nálezů), ne přes délku spojeného řetězce jako u Test-Palindrome, kde se nalezené znaky naopak dál spojují do výsledného řetězce.
