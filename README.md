# Homework - Network Editor

## Pokretanje projekta

### Preduslovi
- Qt 6.10.2 (MinGW 64-bit) sa Qt Quick i Qt Quick Dialogs2 modulima
- CMake 3.16+
- Qt Creator

### Pokretanje iz Qt Creator-a (preporučeno)
1. Otvoriti `CMakeLists.txt` kao projekat u Qt Creator-u
2. Konfigurisati kit (Desktop Qt 6.10.2 MinGW 64-bit)
3. Kliknuti Run (zeleni play)

### Standalone pokretanje
U folderu `exe_start/` se nalazi `apphomework.exe` sa svim potrebnim DLL fajlovima. Može se pokrenuti direktno duplo-klikom bez Qt Creator-a.

## Arhitektura

Projekat koristi Qt Quick (QML) sa jednom C++ klasom za fajl I/O. Svaka vizuelna celina je izdvojena u poseban QML fajl.

```
homework/
├── main.cpp                  # Ulazna tačka, pokreće QML engine
├── projectmanager.h/.cpp     # C++ singleton za čuvanje/učitavanje JSON fajlova
├── Main.qml                  # Glavni prozor, povezuje sve komponente
├── CMakeLists.txt            # Build konfiguracija
└── qml/
    ├── MainToolbar.qml       # Toolbar (New/Save/Load/Reset/Grid/RunCheck)
    ├── LeftPanel.qml         # Lista elemenata sa ikonicama (drag & drop)
    ├── RightPanel.qml        # Properties editor za selektovani element
    ├── BottomPanel.qml       # Log panel sa timestampovima
    └── CentralWorkspace.qml  # Radna površina sa gridom, zoom, pan
```

### Komunikacija između komponenti

Komponente komuniciraju putem QML signala:
- `LeftPanel` → `elementSelected`, `elementInsert` → `Main.qml` prosleđuje ka workspace-u i desnom panelu
- `CentralWorkspace` → `elementClicked`, `logMessage` → `Main.qml` prosleđuje ka desnom panelu i logu
- `RightPanel` → `parameterChanged` → `Main.qml` loguje promenu
- `MainToolbar` → signali za svaku akciju → `Main.qml` poziva odgovarajuće funkcije

### Podaci

Svi elementi na workspace-u se čuvaju u `ListModel` (`placedItemsModel`) sa poljima:
- `name` — tip elementa (Čvor, Veza, Ulaz, Izlaz, Funkcija)
- `label` — auto-generisano ime (npr. Čvor_1, Veza_2)
- `posX`, `posY` — pozicija na radnoj površini
- `vrednost` — numerički parametar (0–1000)
- `status` — "Aktivno" ili "Neaktivno"

`ProjectManager` (C++ singleton, QML_ELEMENT) omogućava serijalizaciju stanja u JSON fajl.

## Šta je implementirano

### Toolbar akcije
- **New Project** — otvara folder picker, resetuje sesiju, kreira novi projekat
- **Save Project** — čuva stanje u JSON fajl putem FileDialog-a
- **Load Project** — učitava JSON fajl i restaurira stanje
- **Reset View** — vraća zoom na 1.0x i pan na (0, 0)
- **Toggle Grid** — uključuje/isključuje vizuelnu mrežu
- **Run Check** — validacija mreže (proverava prisustvo Ulaz/Izlaz/Veza, nepovezane čvorove)

### Levi panel
- Lista od 5 elemenata: Čvor, Veza, Ulaz, Izlaz, Funkcija
- Svaki element ima Canvas ikonicu (kružić, strelice, zupčanik)
- Klik selektuje element, dupli klik ubacuje na centar workspace-a
- Drag & drop iz panela na workspace

### Centralni workspace
- Grid mreža crtana Canvas-om, prati zoom i pan
- Zoom scroll točkićem (0.2x – 5.0x)
- Pan srednjim klikom miša
- Vizuelni prikaz postavljenih elemenata (Rectangle + Canvas ikonica + label)
- Selekcija klikom (plavi highlight)
- Pomeranje elemenata drag-om
- DropArea za prijem elemenata iz levog panela

### Desni panel (Properties editor)
- Naziv — editable, auto-generisano (npr. Čvor_1), ažurira label na workspace-u
- Tip — read-only, prikazuje tip elementa
- Vrednost — SpinBox 0–1000
- Status — dropdown (Aktivno / Neaktivno)
- Disabled kada nijedan element nije selektovan
- Svaka promena loguje "Element X updated"

### Donji panel (Event log)
- Timestampovane poruke za sve događaje
- Clear dugme za brisanje loga
- Auto-scroll na poslednju poruku

## Šta bi bilo sledeće

- **Povezivanje elemenata** — vizuelno crtanje veza (linija) između čvorova na workspace-u, sa mogućnošću brisanja veze
- **Brisanje elemenata** — desni klik kontekst meni ili Delete taster za uklanjanje elementa sa workspace-a
- **Undo/Redo** — istorija akcija sa Ctrl+Z / Ctrl+Y
- **Snap to grid** — automatsko poravnanje elemenata na mrežu prilikom pomeranja
- **Eksport** — eksport mreže u različite formate (PNG slika, SVG, PDF)
- **Zoom kontrole** — vizuelni indikator trenutnog zoom nivoa, zoom to fit
- **Pretraga elemenata** — filter/search u levom panelu za veće liste
- **Teme** — light/dark tema sa mogućnošću prebacivanja
- **Validacija u realnom vremenu** — automatska provera mreže pri svakoj promeni
- **Čuvanje parametara u JSON** — serijalizacija svih elemenata sa pozicijama i parametrima (trenutno se čuva samo view state)
