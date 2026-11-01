## Podúloha 1 – Třída pro správu tiskáren a změna umístění faxu

Vlastnosti třídy:

```powershell
# 1. Zjistěte vlastnosti třídy umožňující spravovat tiskárny
(Get-CimClass -ClassName Win32_Printer).CimClassProperties
```

Změna umístění faxu a kontrola změny:

```powershell
# Změňte umístění faxu.
Get-CimInstance -Query "SELECT * FROM Win32_Printer WHERE Name LIKE '%Fax%'" |
    Set-CimInstance -Property @{ Location = 'College of Winterhold' }

# Kontrola změny
Get-CimInstance -Query "SELECT * FROM Win32_Printer WHERE Name LIKE '%Fax%'" |
    Select-Object Name, Location
```

---

## Podúloha 2 – Název disku C:

```powershell
#  2. Zjistěte, jak se nazývá váš disk C: a případně ho přejmenujte na "System".
$c = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
if ($c.VolumeName -ne 'System') {
    $c | Set-CimInstance -Property @{ VolumeName = 'System' }
}

# Kontrola změny
(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'").VolumeName
```

---

## Podúloha 3 – Nepoužité a uzamčené účty

### Řešení pomocí CIM

```powershell
# 3. Vypište seznam nepoužitých účtů (účtů, ke kterým se nikdo nikdy nepřihlásil) a seznam uzamčených účtů.
Write-Host "Uzamčené účty:"
Get-CimInstance -Query "SELECT * FROM Win32_UserAccount WHERE LocalAccount=True AND Lockout=True" |
    Select-Object Name, Domain, Lockout, Disabled
Write-Host "Nepoužité účty:"
Get-CimInstance -Query "SELECT * FROM Win32_NetworkLoginProfile WHERE LastLogon IS NULL" |
    Select-Object Name, FullName, LastLogon
```

### Řešení pomocí příkazů PowerShellu pro práci s uživatelskými účty

```powershell
# Řešení pomocí příkazů Powershellu pro práci s uživatelskými účty (uzamčené takto zjistit nelze):
Get-LocalUser |
    Where-Object { -not $_.LastLogon } |
    Select-Object Name, Enabled, LastLogon, PasswordLastSet
```
