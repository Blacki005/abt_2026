<#
.SYNOPSIS
    Pro zadaný text vypíše počet znaků (s mezerami i bez mezer),
    počet samohlásek a počet slov.

.PARAMETER Text
    Text, který se má analyzovat. Lze zadat i přes pipeline.

.EXAMPLE
    Get-TextStats -Text "Dnes je krásný den."

.EXAMPLE
    "Ahoj, jak se máš?" | Get-TextStats
#>
function Get-TextStats {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$Text
    )
    process {
        # 1) Počet znaků VČETNĚ mezer = prostě délka celého řetězce.
        $charsWithSpaces = $Text.Length

        # 2) Počet znaků BEZ mezer = odstraníme všechny "bílé znaky"
        #    (mezery, tabulátory, konce řádků - třída \s) a změříme zbytek.
        $charsWithoutSpaces = ($Text -replace '\s').Length

        # 3) Počet samohlásek. Text nejdřív převedeme na malá písmena, aby porovnání nerozlišovalo velikost.
        $vowelMatches = Select-String -InputObject $Text.ToLower() -Pattern '[aeiouyáéěíóúůý]' -AllMatches
        $vowelCount = $vowelMatches.Matches.Count

        # 4) Počet slov: rozdělení textu podle jedné nebo více mezer (\s+).
        #    Where-Object vyřadí prázdné položky, které by vznikly, kdyby
        #    text začínal/končil mezerou nebo obsahoval mezery navíc.
        $words = $Text -split '\s+' | Where-Object { $_ -ne '' }
        $wordCount = $words.Count

        [PSCustomObject]@{
            Text                = $Text
            'Znaků s mezerami'  = $charsWithSpaces
            'Znaků bez mezer'   = $charsWithoutSpaces
            'Počet samohlásek'  = $vowelCount
            'Počet slov'        = $wordCount
        }
    }
}

# --- Interaktivní vstup z terminálu ---
$inputText = Read-Host "Zadejte text k analýze"
Get-TextStats -Text $inputText | Format-List