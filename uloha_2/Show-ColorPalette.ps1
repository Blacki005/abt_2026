<#
.SYNOPSIS
    Vykreslí paletu 16 standardních konzolových barev (System.ConsoleColor)
    ve třech sloupcích, stejně jako na referenčním obrázku:

      1. sloupec - název barvy výchozí barvou textu (bílá na černé)
      2. sloupec - název barvy vybarvený jako barva popředí (foreground)
      3. sloupec - název barvy na pozadí dané barvy (background)

.NOTES
    Pořadí barev odpovídá přesně deklaraci enumu [System.ConsoleColor]
    (Black = 0 ... White = 15), což je totéž pořadí jako na obrázku.
#>

# Uložíme si původní barvy konzole, abychom je po skončení vrátili zpět
$origBg = $Host.UI.RawUI.BackgroundColor
$origFg = $Host.UI.RawUI.ForegroundColor

try {
    # Pozadí/popředí konzole nastavíme tak, aby odpovídalo obrázku.
    # Jako "výchozí" barvu textu používáme Gray, nikoli White - v klasické
    # konzoli je Gray běžná barva normálního textu, zatímco White je jasnější
    # odstín vyhrazený pro zvýraznění. Díky tomu zůstane text čitelný i na
    # bílém pozadí (viz 3. sloupec, řádek "White").
    $Host.UI.RawUI.BackgroundColor = 'Black'
    $Host.UI.RawUI.ForegroundColor = 'Gray'
    Clear-Host

    # Všech 16 hodnot enumu ConsoleColor v jejich přirozeném pořadí
    $colors = [Enum]::GetValues([System.ConsoleColor])

    # Šířka sloupce pro zarovnání (nejdelší název "DarkMagenta" = 11 znaků)
    $colWidth = 14

    foreach ($color in $colors) {
        $name = $color.ToString()
        $label = $name.PadRight($colWidth)

        # 1. sloupec - výchozí barva textu
        Write-Host $label -NoNewline

        # 2. sloupec - barva textu (foreground) = aktuální barva, pozadí černé
        Write-Host $label -ForegroundColor $color -NoNewline

        # 3. sloupec - barva pozadí (background) = aktuální barva
        #    Foreground necháváme Gray (ne White), aby byl text viditelný
        #    i na řádku, kde je pozadí White.
        Write-Host $label -BackgroundColor $color -ForegroundColor Gray
    }
}
finally {
    # Vrácení původních barev konzole
    $Host.UI.RawUI.BackgroundColor = $origBg
    $Host.UI.RawUI.ForegroundColor = $origFg
}