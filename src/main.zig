const std = @import("std");

fn mustEscape(name: []const u8) bool {
    if (name[0] >= '0' and name[0] <= '9')
        return true;
    if (std.mem.eql(u8, name, "type")) return true;
    return false;
}

fn writeDescription(writer: anytype, obj: std.json.ObjectMap) !void {
    if (obj.get("description")) |desc| {
        var lines = std.mem.split(u8, desc.String, "\n");

        while (lines.next()) |line|
            try writer.print("/// {s}\n", .{line});
    }
}

fn writeUnionItem(writer: anytype, item: std.json.Value) anyerror!void {
    switch (item) {
        .String => |type_str| {
            if (std.mem.eql(u8, type_str, "null")) return;
            try writer.print("{s}: {s},\n", .{ type_str, mapType(type_str, true) });
        },
        .Array => |arr| {
            for (arr.items) |item2| try writeUnionItem(writer, item2);
        },
        .Object => |obj| {
            if (obj.get("type")) |t|
                try writeUnionItem(writer, t)
            else {
                // TODO: WriteTypeName
                try writeType(writer, obj);
                try writer.writeAll(": ");
                try writeType(writer, obj);
                try writer.writeAll(",\n");
            }
        },
        else => {},
    }
}

fn writeUnion(writer: anytype, arr: std.json.Array, required: bool) anyerror!void {
    _ = required;
    try writer.writeAll("union(enum) {\n");
    for (arr.items) |item| try writeUnionItem(writer, item);
}

fn isOptional(arr: std.json.Array) bool {
    for (arr.items) |item| {
        switch (item) {
            .String => |type_str| {
                if (std.mem.eql(u8, type_str, "null")) return true;
            },
            else => {},
        }
    }
    return false;
}

fn writeType(writer: anytype, obj: std.json.ObjectMap) anyerror!void {
    var required_items: ?std.json.Array = if (obj.get("required")) |r| r.Array else null;

    if (obj.get("type")) |ttype| {
        switch (ttype) {
            .String => |type_str| {
                if (std.mem.eql(u8, type_str, "array")) {
                    try writer.writeAll("[]");
                    try writeType(writer, obj.get("items").?.Object);
                } else if (std.mem.eql(u8, type_str, "object")) {
                    if (obj.get("properties") == null) {
                        try writer.writeAll("PropertiesPlaceholder");
                        return;
                    }

                    try writeStruct(writer, obj.get("properties").?.Object);
                    try writer.writeAll("}");
                } else {
                    try writer.writeAll(mapType(type_str, true));
                }
            },
            .Array => |types| {
                if (isOptional(types)) try writer.writeByte('?');

                var required = false;
                if (required_items) |reqs| {
                    rr: for (reqs.items) |i| {
                        for (types.items) |t| {
                            if (std.mem.eql(u8, i.String, t.String)) {
                                required = true;
                                break :rr;
                            }
                        }
                    }
                }

                try writeUnion(writer, types, required);
                try writer.writeAll("}");
            },
            else => {
                try writer.writeAll("NotStringTypePlaceholder");
            },
        }
    } else if (obj.get("$ref")) |ref| {
        try writer.writeAll(mapType(ref.String[std.mem.lastIndexOf(u8, ref.String, "/").? + 1 ..], true));
    } else if (obj.get("anyOf")) |any_of| {
        try writeUnion(writer, any_of.Array, false);
        try writer.writeAll("}");
    } else {
        try writer.writeAll("NoTypeOrRefPlaceholder");
    }
}

fn mapType(name: []const u8, infer_int: bool) []const u8 {
    if (std.mem.indexOf(u8, name, "integer") != null or std.mem.indexOf(u8, name, "decimal") != null or (infer_int and std.mem.eql(u8, name, "number"))) return "i64";
    if (std.mem.eql(u8, name, "string")) return "[]const u8";
    if (std.mem.eql(u8, name, "boolean")) return "bool";
    if (std.mem.eql(u8, name, "null")) return "null";

    return name;
}

fn writeStruct(writer: anytype, props: std.json.ObjectMap) anyerror!void {
    try writer.writeAll("struct {\n");
    var props_iterator = props.iterator();

    while (props_iterator.next()) |prop_entry| {
        if (prop_entry.key_ptr.*[0] == '_') continue;

        try writeDescription(writer, prop_entry.value_ptr.Object);
        if (mustEscape(prop_entry.key_ptr.*)) {
            try writer.print(
                \\@"{s}": 
            , .{prop_entry.key_ptr.*});
        } else {
            try writer.print(
                \\{s}: 
            , .{prop_entry.key_ptr.*});
        }

        try writeType(writer, prop_entry.value_ptr.Object);
        try writer.writeAll(",\n");
    }
}

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    var schema_file = try std.fs.cwd().openFile("src/schema.json", .{});
    defer schema_file.close();

    var schema_file_data = try schema_file.readToEndAlloc(allocator, (try schema_file.stat()).size);
    defer allocator.free(schema_file_data);

    var parser = std.json.Parser.init(allocator, false);
    var tree = try parser.parse(schema_file_data);
    defer tree.deinit();

    var output_file = try std.fs.cwd().createFile("lsp.zig", .{});
    defer output_file.close();
    var writer = output_file.writer();

    var definition = tree.root.Object.get("definitions").?;

    var def_iterator = definition.Object.iterator();
    itt: while (def_iterator.next()) |def_entry| {
        // Excludes
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "Proposed")) continue;
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "Protocol")) continue;
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "decimal")) continue;
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "integer")) continue;
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "uinteger")) continue;

        var def_obj = def_entry.value_ptr.Object;

        try writeDescription(writer, def_obj);

        try writer.writeAll("pub const ");

        if (std.mem.indexOfAny(u8, def_entry.key_ptr.*, "$.<") != null) {
            try writer.print(
                \\@"{s}"
            , .{def_entry.key_ptr.*});
        } else {
            try writer.writeAll(def_entry.key_ptr.*);
        }

        try writer.writeAll(" = ");

        if (def_obj.get("enum")) |_| {
            const enum_backing_type = def_obj.get("type").?.String;

            if (std.mem.eql(u8, enum_backing_type, "string")) {
                //
                try writer.print("enum {{ ", .{});
            } else {
                try writer.print(
                    \\enum({s}) {{
                    \\    // TODO: Implement enum names manually
                    \\
                , .{mapType(enum_backing_type, true)});
            }
        } else if (def_obj.get("properties")) |props_obj| {
            var props = props_obj.Object;

            try writeStruct(writer, props);
        } else if (def_obj.get("type") != null and def_obj.get("type").? == .Array) {
            try writeUnion(writer, def_obj.get("type").?.Array, false);
        } else if (def_obj.get("$ref")) |ref| {
            var ref_str = ref.String[std.mem.lastIndexOf(u8, ref.String, "/").? + 1 ..];

            try writer.writeAll(ref_str);
            try writer.writeAll(";\n");
            continue :itt;
        } else {
            try writer.writeAll("struct {");
        }

        try writer.writeAll("};\n");
    }
}

test {
    _ = @import("base.zig");
}
