# Requirements

Fonts:

- JetBrains Mono Nerd Font
- NotoSans Nerd Font

Programs:

- pavucontrol
- pipewire
- qt6ct (for styling tooltips for e.i tray)
- lm_sensors (`sensors`, for CPU temperatures)
- iproute2 (`ip`, for the active network interface and local IP)

Intel temperature labels use logical CPU IDs to match the usage tooltip. Hardware
threads sharing a core share one temperature row. Sensors that cannot be mapped
keep their hardware labels.

