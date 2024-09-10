resource "tailscale_device_subnet_routes" "lab_routes" {
  device_id = data.tailscale_device.ts_router.id
  routes    = var.lab_routes
}