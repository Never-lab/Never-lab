# Handoff — PS202 / vamanOS

**Data:** 2026-09-02  
**Obiettivo:** installare [vamanOS](https://github.com/NayamAmarshe/vamanos-r36s-ps202) sul clone R36S **PS202** (non Linux/ArkOS).  
**Stato:** preparato PC + audit SD; **install non partita** — manca device ADB e SD ancora sul PC.

## Hardware (confermato dal profilo vamanOS)

| Campo | Valore |
|-------|--------|
| Prodotto | R36S clone **PS202** / TICHIPS |
| Build attesa | `PS202_00001` |
| OS factory | Android **4.4.2** |
| SoC | MediaTek **MT6572** |
| Schermo | 640×480 landscape |
| Storage dati | SD FAT32 ~50 GB (montata come `/run/media/nicholas/disk` in sessione) |

**Non è** un R36S Rockchip: ArkOS / dArkOS / Arch R **non si applicano**. Flashare immagini Linux = rischio brick. Unica strada sensata: vamanOS via ADB.

## Audit SD (sessione ufficio)

- Layout factory: `roms/`, `System/` (BIOS), `themes/`, `gamePictures/`, `onlinegames/`, `gameconsole.db`, `TF.txt` = `TF OK`
- Partizione unica FAT32 ~50 G, ~41 G usati, ~9.8 G liberi
- **Tutte** le cartelle `roms/` attese da vamanOS presenti (nes/snes/gba/…/psp/psx/arcade/…)
- Save: ~149 `.srm`, ~482 state
- `themes/EPIC-CODY` già presente (vamanOS installa anche in `ps202/themes/`)
- Cartella **`ps202/` assente** (la crea l’installer: bios, backups, themes, …)
- Linux CFW: assente (corretto per questo hardware)

## Cosa c’è già sul PC (ufficio)

```
~/vamanos/
  platform-tools-dl/platform-tools/   # ADB 37.0.1
  vamanos-r36s-ps202/                 # git checkout tag v1 (2d1fe7b)
```

La release GitHub `v1` ha **assets vuoti**; usare il clone del repo (contiene `release-inputs/` ~197 M + `payload/`).

```bash
export PATH="$HOME/vamanos/platform-tools-dl/platform-tools:$PATH"
cd ~/vamanos/vamanos-r36s-ps202
```

Se riparti da **casa** e quella cartella non c’è:

```bash
mkdir -p ~/vamanos && cd ~/vamanos
git clone --depth 1 --branch v1 https://github.com/NayamAmarshe/vamanos-r36s-ps202.git
# platform-tools:
curl -fsSL -o pt.zip https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip -qo pt.zip -d platform-tools-dl
export PATH="$HOME/vamanos/platform-tools-dl/platform-tools:$PATH"
```

Serve anche **Python 3**.

## Checklist prima di `doctor`

1. Backup esterno ROM/save (consigliato; l’installer dice di non toccarli, ma meglio).
2. **Espelli** la SD dal PC e rimettila nella console.
3. USB debugging ON (Settings → About → 7× Build number → Developer options).
4. Cavo **dati** USB; autorizza il PC sul device.
5. `adb devices` deve mostrare un device `device` (non `unauthorized`).

## Comandi ufficiali (ordine)

```bash
export PATH="$HOME/vamanos/platform-tools-dl/platform-tools:$PATH"
cd ~/vamanos/vamanos-r36s-ps202

./install.sh doctor          # solo lettura — continua SOLO se PS202_00001
./install.sh install         # chiede codice INSTALL-... — non inventarlo
./install.sh verify          # dopo reboot

# se bootloop (read-only prima):
./recover-bootloop.sh doctor

# ripristino boot stock (rimuove root ADB):
./install.sh restore-boot    # codice RESTORE-...
```

Regole installer (`AGENTS.md` del progetto vamanOS):

- Non installare su altro hardware / build sconosciuta.
- Non flash full image / tool random.
- Non `pm clear`, non toccare ROM/save/keylayout.
- Tenere emulator vendor `com.xugame.gameconsole`.
- RetroArch solo dall’URL pinnato in `manifest.json`, install su SD (`-s`).

## Dove eravamo rimasti

1. Audit fatto; Linux scartato; scelta **vamanOS**.
2. Repo clonato + ADB installato.
3. Utente doveva: espellere SD, rimetterla in console, collegare USB + debugging.
4. Al handoff: **SD ancora montata sul PC**, `adb devices` vuoto → **doctor non eseguito**.

## Prossimo passo a casa

1. Ripeti checklist (SD in console + ADB).
2. `./install.sh doctor` → se OK `PS202_00001`, poi `install`.
3. Quando appare `INSTALL-...`, conferma esplicita e digita quel codice.
4. Non staccare il cavo fino a fine + reboot; poi `verify`.

## Link

- Installer: https://github.com/NayamAmarshe/vamanos-r36s-ps202
- Reddit annuncio: https://www.reddit.com/r/R36S/comments/1w4vgn8/release_vamanos_for_ps202_devices_is_out/
- Wiki clone PS202 (no CFW Linux): https://handhelds.wiki/R36S_Clones
