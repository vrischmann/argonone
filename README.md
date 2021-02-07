# argonone

This is a program for controlling the fan speed in a [Argon ONE Pi 4](https://www.argon40.com/argon-one-raspberry-pi-4-case.html) case.

## Requirements

[Zig master](https://ziglang.org/)

## Build

Run this:
```
$ zig build -Dtarget=aarch64-linux-musl
```

## Usage

Run it like this:
```
$ MIN_TEMP=30 MAX_TEMP=70 argonone
info(main): Setting fan speed at 46 for temperature 46.250999450683594°C
info(main): Setting fan speed at 46 for temperature 46.250999450683594°C
```

There's a `argonone.service` systemd unit you can use as well.
