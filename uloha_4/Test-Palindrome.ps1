<#
.SYNOPSIS
    Ověří, zda je zadaný text palindrom - tedy zda se čte stejně oběma
    směry, bez ohledu na mezery, velikost písmen a diakritiku.

.PARAMETER Text
    Text, který se má otestovat. Lze zadat i přes pipeline.

.EXAMPLE
    Test-Palindrome -Text "Kobyla má malý bok"

.EXAMPLE
    "Dal kopat Ota poklad" | Test-Palindrome
#>
function Test-Palindrome {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$Text
    )
    process {
        # 1) Rozložení znaků s diakritikou na základní písmeno + kombinující
        #    diakritické znaménko (Unicode normalizace do tvaru D).
        $normalized = $Text.Normalize('FormD')

        # 2) vybere vsechny charaktery z daneho stringu (tedy z nej vyradi cisla, diakritiku a interpunkci)
        $matches = Select-String -InputObject $normalized -Pattern '[\p{L}]' -AllMatches

        # 3) spojeni nalezenych znaku s prazdnym retezcem - vysledek je string bez diakritiky atd.
        $clean = ($matches.Matches.Value -join '').ToLower()

        if (-not $clean) { return $true }   # prázdný text je triviálně palindrom

        # 4) Otočení řetězce (záporný rozsah indexů čte znaky odzadu)
        $reversed = -join $clean[-1..-$clean.Length]
        $clean -eq $reversed
    }
}

# --- Testovací sada ---
$testCases = @(
    "Jelenovi pivo nelej???",
    "Kobyla má malý bok",
    "Kupředu udeř puk!",
    "Dal kopat Ota poklad.",
    "Toto neni palindrom"   # kontrolní příklad, který palindrom NENÍ
)

$testCases | ForEach-Object {
    [PSCustomObject]@{ Text = $_; JePalindrom = Test-Palindrome -Text $_ }
} | Format-Table -AutoSize
