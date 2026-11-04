# Requirements

Fonts:

- JetBrains Mono Nerd Font
- NotoSans Nerd Font

Programs:

- pavucontrol
- pipewire
- qt6ct (for styling tooltips for e.i tray)
- lm_sensors (`sensors`, for CPU temperatures)

Run the resource calculation checks with:

```sh
QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -input tests
```
