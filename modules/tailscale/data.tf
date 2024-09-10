data "tailscale_device" "ts_router" {
  hostname = var.ts_router_hostname
  wait_for = "300s"
}