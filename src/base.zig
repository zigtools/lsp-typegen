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

/// MIN_VALUE = -2147483648
/// MAX_VALUE = 2147483647
const integer = i32;
/// MIN_VALUE = 0
/// MAX_VALUE = 2147483647
const uinteger = u32;
/// Defines a decimal number. Since decimal numbers are very
/// rare in the language server specification we denote the
/// exact range with every decimal using the mathematics
/// interval notations (e.g. [0, 1] denotes all decimals d with
/// 0 <= d <= 1.
const decimal = f32;

/// The LSP any type
const LSPAny = std.json.Value;
