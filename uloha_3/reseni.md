## 1. Vytvoření aliasů

```powershell
New-Alias -Name np -Value notepad.exe -Description "Otevře Poznámkový blok"
New-Alias -Name ct -Value control.exe -Description "Otevře Ovládací panely"
```

Ověření:

```powershell
Get-Alias np, ct
```

Očekávaný výstup (zjednodušeně):

```
CommandType     Name
-----------     ----
Alias           np -> notepad.exe
Alias           ct -> control.exe
```

---

## 2. Export aliasů do JSON

```powershell
Get-Alias np, ct |
    Select-Object Name, Definition, Description |
    ConvertTo-Json |
    Out-File -FilePath .\alias-backup.json -Encoding utf8
```

- `Select-Object` omezí export jen na vlastnosti potřebné ke zpětnému vytvoření aliasu (jméno, cíl příkazu, popis) — ostatní vlastnosti objektu `AliasInfo` (např. `Options`, `CommandType`) pro obnovu nejsou potřeba.
- `ConvertTo-Json` převede pole objektů na JSON text.
- `Out-File` zapíše výsledek do `alias-backup.json`.

---

## 3. Export aliasů do XML

```powershell
Get-Alias np, ct | Export-Clixml -Path .\alias-backup.xml
```

`Export-Clixml` je nativní PowerShell cmdlet pro serializaci objektů do XML (formát CLIXML) — na rozdíl od ručního `ConvertTo-Json` zachovává i typové informace objektu, takže není potřeba nic dalšího vybírat.

---

## 4. Smazání obou aliasů

```powershell
Remove-Alias -Name np, ct
```

Ověření, že aliasy skutečně zmizely:

```powershell
Get-Alias np, ct -ErrorAction SilentlyContinue
```

(příkaz by neměl vrátit žádný alias; bez `-ErrorAction SilentlyContinue` by PowerShell nahlásil chybu „alias nenalezen“).

---

## 5. Obnova aliasů z JSON souboru

```powershell
$fromJson = Get-Content -Path .\alias-backup.json -Raw | ConvertFrom-Json
foreach ($alias in $fromJson) {
    New-Alias -Name $alias.Name -Value $alias.Definition -Description $alias.Description -Force
}
```

Ověření:

```powershell
Get-Alias np, ct
```

---

## 6. Smazání aliasů podruhé

```powershell
Remove-Alias -Name np, ct
```

---

## 7. Obnova aliasů z XML souboru

```powershell
$fromXml = Import-Clixml -Path .\alias-backup.xml
foreach ($alias in $fromXml) {
    New-Alias -Name $alias.Name -Value $alias.Definition -Description $alias.Description -Force
}
```

Ověření:

```powershell
Get-Alias np, ct
```

---

## Poznámky k replikaci

- `-Force` u `New-Alias` zajistí přepsání aliasu, pokud by už náhodou existoval (např. při opakovaném spuštění protokolu) — bez něj by `New-Alias` na existující alias skončil chybou.
- Aliasy vytvořené pomocí `New-Alias` platí jen pro aktuální PowerShell relaci. Pro trvalé zachování po restartu konzole je třeba stejné příkazy vložit do profilu (`$PROFILE`).
---
