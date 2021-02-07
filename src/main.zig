const std = @import("std");

const c = @cImport({
    @cInclude("linux/i2c.h");
    @cInclude("linux/i2c-dev.h");
});

const FAN_ADDRESS: u8 = 0x1A;

fn getTemperature() !f32 {
    var file = try std.fs.cwd().openFile("/sys/class/thermal/thermal_zone0/temp", .{});
    defer file.close();

    var reader = file.reader();

    var buf: [128]u8 = undefined;
    const n = try reader.read(&buf);
    const data = std.mem.trim(u8, buf[0..n], "\n");

    const raw_temperature = try std.fmt.parseFloat(f32, data);

    return raw_temperature / 1000.0;
}

/// SMBus is an abstraction to write commands over an I2C bus.
const SMBus = struct {
    const Self = @This();

    file: std.fs.File,

    pub fn init(bus_number: usize) !Self {
        var buf: [64]u8 = undefined;
        const path = try std.fmt.bufPrint(&buf, "/dev/i2c-{d}", .{bus_number});

        const file = try std.fs.cwd().openFile(path, .{
            .write = true,
            .read = true,
        });

        return Self{
            .file = file,
        };
    }

    pub fn writeByte(self: Self, address: u8, command: u8) !void {
        _ = std.os.linux.ioctl(
            self.file.handle,
            c.I2C_SLAVE,
            address,
        );

        const msg = c.i2c_smbus_ioctl_data{
            .read_write = c.I2C_SMBUS_WRITE,
            .command = command,
            .size = c.I2C_SMBUS_BYTE,
            .data = null,
        };

        _ = std.os.linux.ioctl(
            self.file.handle,
            c.I2C_SMBUS,
            @ptrToInt(&msg),
        );
    }
};

fn computeFanSpeed(temperature: f32, min_temp: f32, max_temp: f32) u8 {
    if (temperature >= max_temp) {
        return 100;
    }

    if (temperature >= min_temp) {
        const value = ((temperature - min_temp) * 90.0 / (max_temp - min_temp)) + 10.0;
        if (value > 100) return 100;
        return @floatToInt(u8, value);
    }

    return 0;
}

const logger = std.log.scoped(.main);

pub fn main() anyerror!void {
    const min_temp: f32 = if (std.os.getenv("MIN_TEMP")) |v| try std.fmt.parseFloat(f32, v) else 55.0;
    const max_temp: f32 = if (std.os.getenv("MAX_TEMP")) |v| try std.fmt.parseFloat(f32, v) else 75.0;

    // This is /dev/i2c-1
    var bus = try SMBus.init(1);

    while (true) {
        const temperature = try getTemperature();

        const fan_speed = computeFanSpeed(temperature, min_temp, max_temp);

        logger.info("Setting fan speed at {d} for temperature {d}°C", .{ fan_speed, temperature });

        try bus.writeByte(FAN_ADDRESS, fan_speed);
        std.time.sleep(10 * std.time.ns_per_s);
    }
}
