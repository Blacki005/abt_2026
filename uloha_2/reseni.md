# Show-ColorPalette.ps1 — dokumentace

**Vytvořeno pomocí:** Claude Sonnet 5 (Anthropic)

## Stručný popis funkce

Skript do terminálu vypíše paletu všech 16 standardních konzolových barev
(`System.ConsoleColor`) ve třech sloupcích vedle sebe — název barvy výchozí
barvou textu, název obarvený jako barva popředí a název na barevném pozadí.
Po doběhnutí vrátí barvy konzole do stavu, v jakém byly před spuštěním.

## Zdrojový kód

```powershell
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
```

## Doplňující vysvětlení

Tato část popisuje návrhová rozhodnutí a souvislosti, které komentáře přímo
v kódu neřeší.

- **Proč `[Enum]::GetValues([System.ConsoleColor])` stačí k zachování pořadí:**
  .NET enum `ConsoleColor` má podkladové hodnoty 0–15 přiřazené přesně v
  pořadí Black, DarkBlue, DarkGreen, … White. `GetValues()` tyto hodnoty vrací
  seřazené podle čísla, takže netřeba řadit ručně — pořadí odpovídá obrázku
  automaticky, bez jakéhokoli dalšího kódu.

- **Proč `try { } finally { }`:** Pokud by uživatel skript přerušil (Ctrl+C)
  nebo by nastala chyba uprostřed smyčky, blok `finally` i tak zaručí, že se
  barvy konzole vrátí do původního stavu — konzole tak nikdy nezůstane „zaseklá“
  v černém pozadí po neúspěšném běhu.

- **Proč `-NoNewline` jen u prvních dvou `Write-Host`:** Aby se všechny tři
  sloupce jednoho řádku vypsaly vedle sebe jako jeden řádek textu; teprve
  třetí volání (bez `-NoNewline`) řádek ukončí a posune kurzor na další.

- **Proč `PadRight($colWidth)`:** Názvy barev mají různou délku (`Red` vs.
  `DarkMagenta`), `PadRight` je doplní mezerami na stejnou šířku, takže
  barevné pruhy ve 2. a 3. sloupci mají na obrázku jednotnou šířku.

- **Spuštění:** `.\Show-ColorPalette.ps1` (případně je potřeba povolit
  spouštění skriptů: `Set-ExecutionPolicy -Scope Process RemoteSigned`).
