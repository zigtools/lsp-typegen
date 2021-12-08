const std = @import("std");

var tree: std.json.ValueTree = undefined;

fn mustEscape(name: []const u8) bool {
    if (name[0] >= '0' and name[0] <= '9')
        return true;
    if (std.zig.Token.keywords.has(name)) return true;
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
    if (!required) try writer.writeAll("none: void,");
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

                    try writer.writeAll("struct {\n");
                    try writeStruct(writer, obj.get("properties").?.Object);
                    try writer.writeAll("}");
                } else {
                    try writer.writeAll(mapType(type_str, true));
                }
            },
            .Array => |types| {
                if (isOptional(types)) try writer.writeByte('?');

                var required = required_items != null;
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
        try writer.writeAll(cleanRef(mapType(ref.String[std.mem.lastIndexOf(u8, ref.String, "/").? + 1 ..], true)));
    } else if (obj.get("anyOf")) |any_of| {
        var required = required_items != null;
        try writeUnion(writer, any_of.Array, required);
        try writer.writeAll("}");
    }
    // else if (obj.get("allOf")) |all_of| {
    //     try writer.writeAll("}");
    // }
    else {
        try writer.writeAll("NoTypeOrRefPlaceholder");
    }
}

fn mapType(name: []const u8, infer_int: bool) []const u8 {
    if (std.mem.indexOf(u8, name, "integer") != null or std.mem.indexOf(u8, name, "decimal") != null or (infer_int and std.mem.eql(u8, name, "number"))) return "i64";
    if (std.mem.eql(u8, name, "string")) return "[]const u8";
    if (std.mem.eql(u8, name, "boolean")) return "bool";
    if (std.mem.eql(u8, name, "null")) return "null";
    if (std.mem.eql(u8, name, "object")) return "json.ObjectMap";

    return name;
}

fn writeStruct(writer: anytype, props: std.json.ObjectMap) anyerror!void {
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

fn sliceRef(ref: []const u8) []const u8 {
    return ref[std.mem.lastIndexOf(u8, ref, "/").? + 1 ..];
}

fn cleanRef(unslashed: []const u8) []const u8 {
    return if (std.mem.lastIndexOf(u8, unslashed, "_")) |ind| unslashed[0..ind] else unslashed;
}

fn writeAllOf(writer: anytype, arr: std.json.Array) anyerror!void {
    try writer.writeAll("struct {\n");
    // try writeStruct(writer, props);
    for (arr.items) |item| {
        var obj = item.Object;

        if (obj.get("$ref")) |ref_value| {
            var ref = sliceRef(ref_value.String);
            try writeStruct(writer, tree.root.Object.get("definitions").?.Object.get(ref).?.Object.get("properties").?.Object);
        }
    }
}

const FmtVarEscape = struct {
    str: []const u8,
    pub fn format(value: FmtVarEscape, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        const me = mustEscape(value.str);
        if (me) try writer.writeAll("@\"");
        try writer.writeAll(value.str);
        if (me) try writer.writeAll("\"");
    }
};

fn fmtVarEscape(str: []const u8) FmtVarEscape {
    return .{ .str = str };
}

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;
    const base = @embedFile("base.zig");

    var schema_file = try std.fs.cwd().openFile("src/schema.json", .{});
    defer schema_file.close();

    var schema_file_data = try schema_file.readToEndAlloc(allocator, (try schema_file.stat()).size);
    defer allocator.free(schema_file_data);

    var parser = std.json.Parser.init(allocator, false);
    tree = try parser.parse(schema_file_data);
    defer tree.deinit();

    var output_file = try std.fs.cwd().createFile("lsp.zig", .{});
    defer output_file.close();
    var writer = output_file.writer();

    try writer.writeAll(base);

    var definition = tree.root.Object.get("definitions").?;

    var def_iterator = definition.Object.iterator();
    itt: while (def_iterator.next()) |def_entry| {
        // Excludes
        if (def_entry.key_ptr.*[0] == '_') continue;
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "Proposed")) continue;
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "Protocol")) continue;
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "decimal")) continue;
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "integer")) continue;
        if (std.mem.startsWith(u8, def_entry.key_ptr.*, "uinteger")) continue;

        var def_obj = def_entry.value_ptr.Object;

        if (def_obj.get("$ref")) |ref| {
            var ref_str = sliceRef(ref.String);

            std.log.debug("Discarding direct point: {s} -> {s}", .{ def_entry.key_ptr.*, ref_str });
            continue :itt;
        }

        try writeDescription(writer, def_obj);

        try writer.writeAll("pub const ");

        var cleaned = cleanRef(def_entry.key_ptr.*);
        if (std.mem.indexOfAny(u8, cleaned, "$.<") != null) {
            try writer.print(
                \\@"{s}"
            , .{cleaned});
        } else {
            try writer.writeAll(cleaned);
        }

        try writer.writeAll(" = ");

        if (def_obj.get("enum")) |en| {
            const enum_values = en.Array;
            const enum_backing_type = def_obj.get("type").?.String;

            if (std.mem.eql(u8, enum_backing_type, "string")) {
                //
                try writer.print("enum {{ ", .{});
                for (enum_values.items) |val| {
                    try writer.print("{s},", .{fmtVarEscape(val.String)});
                }
                try writer.writeAll("usingnamespace StringBackedEnumStringify(@This());");
            } else {
                try writer.print(
                    \\enum({s}) {{
                    \\    // TODO: Implement enum names manually
                    \\
                , .{mapType(enum_backing_type, true)});
            }
        } else if (def_obj.get("properties")) |props_obj| {
            var props = props_obj.Object;

            try writer.writeAll("struct {\n");
            try writeStruct(writer, props);
        } else if (def_obj.get("type") != null and def_obj.get("type").? == .Array) {
            try writeUnion(writer, def_obj.get("type").?.Array, false);
        } else if (def_obj.get("type") != null and def_obj.get("type").? == .String) {
            try writer.writeAll(mapType(def_obj.get("type").?.String, true));
            try writer.writeAll(";\n");
            continue :itt;
        } else if (def_obj.get("allOf")) |all_of| {
            try writeAllOf(writer, all_of.Array);
        } else {
            try writer.writeAll("struct {");
        }

        try writer.writeAll("};\n");
    }
}

test {
    _ = @import("base.zig");
}
