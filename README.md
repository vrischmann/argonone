# argonone

This is a script for controlling the fan speed in a [Argon ONE Pi 4](https://www.argon40.com/argon-one-raspberry-pi-4-case.html) case.

I'm running base Debian buster, not Raspberry Pi OS and everything I found so far either didn't work or did too much.

I only care about controlling the fan so this script does just that.

## Dependencies

You need the package `python3-smbus` on Debian or equivalent on other distributions.

## Usage

Run it like this:
```
$ MIN_TEMP=30 MAX_TEMP=70 argonone
Setting fan speed at 2 for temperature 44.303°C
Setting fan speed at 2 for temperature 43.816°C
```

There's a `argonone.service` systemd unit you can use as well.
