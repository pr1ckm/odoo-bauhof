from odoo import fields, models


class FleetVehicleModel(models.Model):
    _inherit = 'fleet.vehicle.model'

    # Fahrzeugtypen auf Modell-Ebene erweitern
    vehicle_type = fields.Selection(
        selection_add=[
            ('truck', 'LKW'),
            ('tractor', 'Traktor'),
            ('machine', 'Baumaschine'),
            ('trailer', 'Anhänger'),
        ],
        ondelete={
            'truck': 'set default',
            'tractor': 'set default',
            'machine': 'set default',
            'trailer': 'set default',
        },
    )


class FleetVehicle(models.Model):
    _inherit = 'fleet.vehicle'

    # Bauhof-spezifische Prüf- und Betriebsdaten
    tuev_next = fields.Date(string='Nächste HU / TÜV')
    uvv_next = fields.Date(string='Nächste UVV-Prüfung')
    operating_hours = fields.Float(
        string='Betriebsstunden (h)', digits=(12, 1)
    )
    tachograph_check = fields.Date(string='Fahrtenschreiberprüfung (§ 57b)')

    # Verknüpfung zum Fahrzeugmodell (Related Field aus fleet.vehicle.model)
    vehicle_type = fields.Selection(
        related='model_id.vehicle_type',
        string='Fahrzeugtyp',
        store=True,
        readonly=False,
    )