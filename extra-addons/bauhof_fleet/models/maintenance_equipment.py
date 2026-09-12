from odoo import models, fields

class MaintenanceEquipment(models.Model):
    _inherit = 'maintenance.equipment'

    x_uvv_next = fields.Date(string='Nächste UVV-Prüfung')
    x_vehicle_id = fields.Many2one('fleet.vehicle', string='Trägerfahrzeug (Fuhrpark)')