const std = @import("std");
const json = std.json;

pub fn IntBackedEnumStringify(comptime T: type) type {
    return struct {
        pub fn jsonStringify(value: T, options: json.StringifyOptions, out_stream: anytype) !void {
            try json.stringify(@enumToInt(value), options, out_stream);
        }
    };
}

test "int-backed enum stringify" {
    const MyEnum = enum(i64) {
        one = 1,
        two = 2,

        usingnamespace IntBackedEnumStringify(@This());
    };

    var buf: [2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);

    try json.stringify(MyEnum.one, .{}, fbs.writer());
    try std.testing.expectEqual(@as(u8, '1'), buf[0]);

    try json.stringify(MyEnum.two, .{}, fbs.writer());
    try std.testing.expectEqual(@as(u8, '2'), buf[1]);
}

pub fn StringBackedEnumStringify(comptime T: type) type {
    return struct {
        pub fn jsonStringify(value: T, options: json.StringifyOptions, out_stream: anytype) !void {
            inline for (std.meta.fields(T)) |field| {
                if (@enumToInt(value) == field.value) {
                    try json.stringify(field.name, options, out_stream);
                    return;
                }
            }

            unreachable;
        }
    };
}

test "string-backed enum stringify" {
    const MyEnum = enum {
        one,
        two,

        usingnamespace StringBackedEnumStringify(@This());
    };

    var buf: [10]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);

    try json.stringify(MyEnum.one, .{}, fbs.writer());
    try std.testing.expectEqualSlices(u8, "\"one\"", buf[0..5]);

    try json.stringify(MyEnum.two, .{}, fbs.writer());
    try std.testing.expectEqualSlices(u8, "\"two\"", buf[5..]);
}
