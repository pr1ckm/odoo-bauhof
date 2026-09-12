{
    'name': 'Bauhof Fuhrpark & Geräte-Erweiterungen',
    'version': '18.0.1.0.1',
    'category': 'Fleet',
    'summary': 'Erweitert Fleet, Maintenance und HR um TÜV, UVV, Betriebsstunden und Führerscheinkontrolle',
    'author': 'Bauhof IT',
    'depends': ['base', 'fleet', 'maintenance'],
    'data': [
        'views/fleet_vehicle_views.xml',
        'views/maintenance_equipment_views.xml',
    ],
    'installable': True,
    'application': False,
    'license': 'LGPL-3',
}