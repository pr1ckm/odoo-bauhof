# Odoo 18 Kommunal-Fuhrparkmanagement (Bauhof-Edition – Proof of Concept)

[![Odoo v18.0](https://img.shields.io/badge/Odoo-18.0-purple.svg)](https://www.odoo.com)
[![Docker Compose](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://www.docker.com)
[![Python](https://img.shields.io/badge/Python-3.10%2B-yellow.svg)](https://www.python.org)
[![Status: PoC](https://img.shields.io/badge/Status-Proof%20of%20Concept-orange.svg)]()
[![License: OPL-1](https://img.shields.io/badge/License-OPL--1-green.svg)](https://www.odoo.com)

> **Hinweis:** Bei diesem Projekt handelt es sich ausdrücklich um einen **Proof of Concept (PoC) / einen experimentellen Versuch**, die spezifischen Anforderungen eines kommunalen Bauhofs (wie Betriebsstunden, Spezialfahrzeuge und gesetzliche Prüffristen) in Odoo 18 abzubilden und zu testen.

Ein maßgeschneidertes Odoo 18 Modul und Docker-Setup für das digitale Fuhrpark- und Maschinenmanagement in kommunalen Bauhöfen. 

Dieses Repository dient als technischer und konzeptioneller Versuch, Odoos Standard-Flottenmanagement (`fleet`) gezielt um kommunale Bedarfe zu erweitern: Von Betriebsstunden für Baumaschinen und Schlepper über gesetzliche Prüfintervalle bis hin zu praxisnahen Test-Stammdaten für den simulierten Bauhof-Einsatz.

---

## Inhaltsverzeichnis

1. [Projektcharakter (Proof of Concept)](#-projektcharakter-proof-of-concept)
2. [Funktionsumfang & Highlights](#-funktionsumfang--highlights)
3. [Projektstruktur & Dateien](#-projektstruktur--dateien)
4. [Systemvoraussetzungen](#-systemvoraussetzungen)
5. [Installation & Inbetriebnahme](#-installation--inbetriebnahme)
6. [Dateninitialisierung & Testdaten-Import](#-dateninitialisierung--testdaten-import)
7. [Lizenz](#-lizenz)

---

## Projektcharakter (Proof of Concept)

Das Repository wurde als **Machbarkeitsstudie und Testumgebung** entworfen, um zu evaluieren, wie gut sich Odoo 18 für den Einsatz in einer kommunal geprägten Fahrzeug- und Maschinenverwaltung eignet. 
* Es ist primär für Evaluations-, Test- und Entwicklungszwecke gedacht.
* Die Implementierungen (Modell-Erweiterungen, Views und Importskripte) zeigen einen exemplarischen Lösungsansatz auf.
* Für einen direkten Echtbetrieb (Production) sind ggf. weiterführende Tests, Sicherheitsüberprüfungen und Anpassungen erforderlich.

---

## Funktionsumfang

Im Rahmen dieses PoC wurden folgende Kernbereiche umgesetzt und getestet:

* **Erweiterte Fahrzeug- & Gerätetypen:** Neben klassischen PKW und LKW unterstützt das System im Rahmen dieses Versuchs nativ Baumaschinen, Traktoren/Kommunalschlepper und Anhänger.
* **Betriebsstunden vs. Kilometerstand:** Getrennte Erfassung von Betriebsstunden (`operating_hours`) für Großgeräte, Radlader und Kehrmaschinen parallel zum klassischen Tachometer.
* **Kommunale Prüffristen & Fristenmanagement:** Integrierte Test-Datumsfelder für:
  * Nächste HU / TÜV (`tuev_next`)
  * UVV-Prüfungen (DGUV 70/71 für LKW & Krane / Hubarbeitsbühnen)
  * Fahrtenschreiberprüfung nach § 57b StVZO
  * DGUV V3 Elektroprüfungen
* **Spezielle Dienstleistungs- & Vertragskategorien:** Vorkonfiguriert für Winterdienst-Rüstung/Rückbau, Kommunalversicherungen, Leasingverträge und Hydraulik-Services.
* **Lieferanten & Werkstätten:** Angepasste Ansichten und Filter zur schnellen Verwaltung externer Dienstleister und Werkstätten.

---

# Projektstruktur & Dateien

```text
.
├── docker-compose.yml                          # Container-Orchestrierung für PostgreSQL & Odoo
├── fahrzeug.sh                                 # Skript für automatisierten Stammdaten-Import
├── .env                                        # Umgebungsvariablen für Docker Compose
├── config/
│   └── odoo.conf                               # Optimierte Odoo-Serverkonfiguration
└── extra-addons/
    └── bauhof_fleet/                           # Custom Odoo-Modul (PoC Implementation)
        ├── __init__.py                         # Modul-Initialisierung
        ├── manifest.py                         # Modul-Metadaten & Abhängigkeiten
        ├── models/
        │   ├── __init__.py                     # Modell-Initialisierung
        │   ├── fleet_vehicle.py                # Python-Erweiterungen für Fuhrpark-Modelle
        │   └── maintenance_equipment.py        # Python-Erweiterungen für Wartung & Geräte
        └── views/
            ├── fleet_vehicle_view.xml          # UI-Ansichten für Fuhrpark
            └── maintenance_equipment_view.xml  # UI-Ansichten für Wartung & Geräte

---

## Systemvoraussetzungen

* **Docker** (ab Version 24.x)
* **Docker Compose** (ab v2.x)
* Mindestens 4 GB RAM und 2 CPU-Kerne auf dem Host-System empfohlen.

---

## Installation & Inbetriebnahme

### 1. Repository-Struktur anlegen
Erstelle auf deinem Server oder lokalen Rechner das Projektverzeichnis und die entsprechenden Unterordner:
```bash
mkdir -p odoo-bauhof/config odoo-bauhof/extra-addons/fleet_vehicle
```

### 2. Konfigurations- und Moduldateien platzieren
* Lege die `docker-compose.yml` in das Hauptverzeichnis (`odoo-bauhof/`).
* Lege die `odoo.conf` in den Ordner `odoo-bauhof/config/`.
* Platziere die Moduldateien (`fleet_vehicle.py`, `fleet_vehicle_views.xml` sowie eine entsprechende `__manifest__.py`) im Ordner `odoo-bauhof/extra-addons/fleet_vehicle/`.

### 3. Docker-Container starten
Starte die Testumgebung im Hintergrund über Docker Compose:
```bash
cd odoo-bauhof
docker compose up -d
```

Überprüfe den Status der Container:
```bash
docker compose ps
```

---

## Dateninitialisierung & Testdaten-Import

Da es sich um einen Proof of Concept handelt, enthält das Projekt ein mächtiges Odoo-Shell-Skript (`fahrzeuge.sh` / Import-Skript), welches das Datenmodell bereinigt und eine realistische Testumgebung mit kommunalen Kategorien, Dienstleistungstypen, Status, Marken und Beispielfahrzeugen (z. B. *Unimog U 430*, *MAN TGM*, *Kramer Radlader*, *E-Bikes*) befüllt.

Führe den Import über die Odoo-Shell im laufenden Docker-Container aus:

```bash
docker exec -i odoo18_web odoo shell -c /etc/odoo/odoo.conf -d fuhrpark << 'EOF'
# Hier das Import-Skript ausführen oder einfügen
EOF
```

Nach dem Durchlauf stehen erste fiktive Testdaten in deiner Odoo-Instanz zur Verfügung.

---

## Lizenz

Dieses Projekt steht unter der [Odoo Proprietary License v1.0 (OPL-1)](https://www.odoo.com) bzw. zur internen Erprobung und Evaluation zur Verfügung.