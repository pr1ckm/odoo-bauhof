docker exec -i odoo18_web odoo shell -c /etc/odoo/odoo.conf -d fuhrpark << 'EOF'
Vehicle = env['fleet.vehicle']
Model = env['fleet.vehicle.model']
Brand = env['fleet.vehicle.model.brand']
Category = env['fleet.vehicle.model.category']
ServiceType = env['fleet.service.type']
State = env['fleet.vehicle.state']

# 1. Tabellen in korrekter Reihenfolge leeren (von Kind- zu Elterntabellen)
env['fleet.vehicle.odometer'].search([]).unlink()
env['fleet.vehicle.log.services'].search([]).unlink()
env['fleet.vehicle.log.contract'].search([]).unlink()
env['fleet.vehicle.assignation.log'].search([]).unlink()

Vehicle.search([]).unlink()
Model.search([]).unlink()
Brand.search([]).unlink()
Category.search([]).unlink()
ServiceType.search([]).unlink()
State.search([]).unlink()

env.cr.commit()
print("Alle Tabellen (inkl. abhängiger Logs/Odometer) erfolgreich geleert.")

# 2. Kategorien anlegen
categories = [
    "Kommunalfahrzeuge & Geräteträger",
    "LKW & Schwertransport",
    "Transporter & Pritschenwagen",
    "PKW & Dienstfahrzeuge",
    "Zweiräder (E-Bikes, Roller, Motorräder)",
    "Traktoren & Kommunalschlepper",
    "Radlader & Teleskoplader",
    "Baumaschinen & Bagger",
    "Grünpflege & Aufsitzmäher",
    "Anhänger & Tieflader"
]

cat_map = {}
for cat_name in categories:
    cat = Category.create({'name': cat_name})
    cat_map[cat_name] = cat.id

# 3. Dienstleistungstypen
services_data = [
    ("HU / AU (TÜV / DEKRA)", "service"),
    ("UVV-Prüfung LKW / Krane (DGUV 70/71)", "service"),
    ("UVV-Prüfung Ladebordwand & Hubarbeitsbühne", "service"),
    ("Sicherheitsprüfung (SP)", "service"),
    ("Fahrtenschreiberprüfung (§ 57b StVZO)", "service"),
    ("DGUV V3 Elektroprüfung (Fahrzeug / Aggregate)", "service"),
    ("Inspektion & Jahreswartung nach Herstellervorgabe", "service"),
    ("Öl-, Schmier- & Filterwechsel", "service"),
    ("Hydraulik-Service & Schlauchprüfung", "service"),
    ("Bremsen- & Fahrwerksinstandsetzung", "service"),
    ("Räder- & Reifenwechsel (Saisonwechsel)", "service"),
    ("Reifenerneuerung & Wuchten", "service"),
    ("Glasreparatur & Steinschlagbeseitigung", "service"),
    ("Karosserie-, Rost- & Schweißarbeiten", "service"),
    ("Winterdienst-Rüstung (Montage Schild & Streuer)", "service"),
    ("Winterdienst-Rückbau (Sommerbetrieb)", "service"),
    ("Kfz-Haftpflichtversicherung", "contract"),
    ("Vollkasko- / Teilkaskoversicherung", "contract"),
    ("Kommunal-Haftpflicht & Maschinenbruchversicherung", "contract"),
    ("Kfz-Steuer / Zulassungsabgaben", "contract"),
    ("Kommunal-Leasing (Fahrzeuge & Großgeräte)", "contract"),
    ("Langzeit-Miete / Saisonmiete (Geräte)", "contract"),
    ("Full-Service-Wartungsvertrag (Hersteller / Werkstatt)", "contract"),
    ("Telematik- & GPS-Tracking-Vertrag", "contract")
]
for s_name, s_type in services_data:
    ServiceType.create({'name': s_name, 'category': s_type})

# 4. Fahrzeugstatus
states_data = [
    ("Bestellt / Beschaffung", 10), 
    ("Einsatzbereit / Aktiv", 20),
    ("Werkstatt / Wartung", 30), 
    ("Ausgemustert / Inaktiv", 40),
    ("Verkauft / Verwertet", 50)
]
for st_name, seq in states_data:
    State.create({'name': st_name, 'sequence': seq})

model_fields = Model._fields
has_category = 'category_id' in model_fields

# 5. Marken & Modelle
models_data = [
    ("Mercedes-Benz", "Unimog U 430", "tractor", "Kommunalfahrzeuge & Geräteträger"),
    ("MAN", "TGM 18.290 4x4", "truck", "LKW & Schwertransport"),
    ("VW", "Transporter T6 Pritsche", "car", "Transporter & Pritschenwagen"),
    ("Skoda", "Octavia Combi (Bauhofleitung)", "car", "PKW & Dienstfahrzeuge"),
    ("Kramer", "8085 Radlader", "machine", "Radlader & Teleskoplader"),
    ("Hako", "Citymaster 1650", "machine", "Kommunalfahrzeuge & Geräteträger"),
    ("Multicar", "M31 Carrier", "truck", "Kommunalfahrzeuge & Geräteträger"),
    ("Reform", "Muli T10 X", "tractor", "Traktoren & Kommunalschlepper"),
    ("Liebherr", "L 506 Compact", "machine", "Radlader & Teleskoplader"),
    ("Weidemann", "1390 Hoftrac", "machine", "Radlader & Teleskoplader"),
    ("Cube", "Touring Hybrid E-Bike", "bike", "Zweiräder (E-Bikes, Roller, Motorräder)"),
    ("Unsinn", "K3542 Dreiseitenkipper", "trailer", "Anhänger & Tieflader")
]

brand_map = {}
model_map = {}

for brand_name, model_name, vtype, cat_name in models_data:
    if brand_name not in brand_map:
        brand = Brand.create({'name': brand_name})
        brand_map[brand_name] = brand.id
    
    vals = {
        'name': model_name,
        'brand_id': brand_map[brand_name],
        'vehicle_type': vtype,
    }
    if has_category and cat_name in cat_map:
        vals['category_id'] = cat_map[cat_name]

    model = Model.create(vals)
    model_map[model_name] = model.id

# 6. Fahrzeuge 
# Format: (Kennzeichen, Modellname, Laufleistung_Wert, Ist_Betriebsstunden_True_False, TÜV, UVV, Tacho, Standort, Bestelldatum, VIN, Kaufwert, List_preis)
vehicles_data = [
    ("DA-BH 101", "Unimog U 430", 1250.5, True, "2027-05-15", "2027-04-10", "2027-05-15", "Bauhof - Fahrzeughalle 1", "2022-03-10", "WDB4051011V123456", 245000.0, 275000.0),
    ("DA-BH 102", "TGM 18.290 4x4", 840.0, True, "2027-08-20", "2027-06-30", "2027-08-20", "Bauhof - Fahrzeughalle 1", "2021-06-15", "WMAL20ZZ9MY789012", 168000.0, 192000.0),
    ("DA-BH 103", "Transporter T6 Pritsche", 45200.0, False, "2027-03-12", "2027-03-12", False, "Bauhof - Werfthof", "2023-01-20", "WV1ZZZ7HZPH345678", 45000.0, 52000.0),
    ("DA-BH 104", "Octavia Combi (Bauhofleitung)", 78500.0, False, "2027-10-05", False, False, "Verwaltung / Rathaus", "2022-09-01", "TMBJJ7NX5NY901234", 34500.0, 41000.0),
    ("DA-BH 105", "8085 Radlader", 2100.0, True, False, "2027-03-15", False, "Bauhof - Freigelände Depot", "2020-04-12", "KRAL80850AB567890", 95000.0, 110000.0),
    ("DA-BH 106", "Citymaster 1650", 1540.2, True, "2027-11-10", "2027-10-01", False, "Bauhof - Halle 2 (Kehrmaschinen)", "2021-11-05", "HAK165001CD123456", 142000.0, 160000.0),
    ("DA-BH 107", "M31 Carrier", 1980.0, True, "2027-02-28", "2027-01-15", "2027-02-28", "Bauhof - Halle 2", "2019-08-14", "MUL3100EF78901234", 88000.0, 99000.0),
    ("DA-BH 108", "Muli T10 X", 610.5, True, "2027-07-01", "2027-05-20", False, "Bauhof - Abteilung Grünpflege", "2022-02-18", "REF10XGH567890123", 115000.0, 130000.0),
    ("DA-BH 109", "L 506 Compact", 3120.0, True, False, "2027-04-01", False, "Bauhof - Recyclinghof", "2021-03-30", "WLI506JK678901234", 79000.0, 92000.0),
    ("DA-BH 110", "1390 Hoftrac", 450.0, True, False, "2027-11-15", False, "Bauhof - Gärtnerei", "2023-05-10", "WAI1390LM89012345", 48000.0, 55000.0),
    ("DA-BH 111", "Touring Hybrid E-Bike", 125.0, False, False, False, False, "Bauhof - Fahrradschuppen", "2024-04-01", "CUBEEBIKE01020304", 3200.0, 3700.0),
    ("DA-BH 112", "Touring Hybrid E-Bike", 210.0, False, False, False, False, "Bauhof - Fahrradschuppen", "2024-04-01", "CUBEEBIKE02030405", 3200.0, 3700.0),
    ("DA-BH 115", "K3542 Dreiseitenkipper", 0.0, False, "2027-10-31", "2027-10-15", False, "Bauhof - Anhängerparkplatz", "2021-10-01", "UNS3542AN90123456", 12500.0, 14800.0)
]

for plate, model_name, val, is_hours, tuev, uvv, tacho, location, order_date, vin, purchase_val, list_price in vehicles_data:
    if model_name in model_map:
        vehicle_vals = {
            'license_plate': plate,
            'model_id': model_map[model_name],
            'tuev_next': tuev,
            'uvv_next': uvv,
            'tachograph_check': tacho,
            'location': location,
            'acquisition_date': order_date,
            'vin_sn': vin,
            'car_value': list_price,
        }
        
        # Sauber trennen zwischen Betriebsstunden und Kilometerstand
        if is_hours:
            vehicle_vals['operating_hours'] = val
            vehicle_vals['odometer'] = 0.0
        else:
            vehicle_vals['odometer'] = val
            vehicle_vals['operating_hours'] = 0.0

        if 'value' in Vehicle._fields:
            vehicle_vals['value'] = purchase_val

        if 'category_id' in Vehicle._fields:
            mod = Model.browse(model_map[model_name])
            if hasattr(mod, 'category_id') and mod.category_id:
                vehicle_vals['category_id'] = mod.category_id.id

        Vehicle.create(vehicle_vals)

env.cr.commit()
print("Fuhrpark-Import mit korrekten Betriebsstunden (operating_hours) erfolgreich abgeschlossen!")
EOF