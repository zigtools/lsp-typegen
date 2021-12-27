const fs = require("fs");
const path = require("path");

const base = fs.readFileSync(path.join(__dirname, "base.zig"));
const typeSchema = JSON.parse(fs.readFileSync(path.join(__dirname, "types_schema.json")));
const protocolSchema = JSON.parse(fs.readFileSync(path.join(__dirname, "protocol_schema.json")));

const outStream = fs.createWriteStream(path.join(process.cwd(), "lsp.zig"));

function wrapName(name) {
    if (["type", "async", "struct", "enum"].includes(name)) return `@"${name}"`;
    return name;
}

function locateId(schema, id) {
    for (const child of schema.children) {
        if (child.id === id) return child;
    }

    throw new Error("BRUH");
}

function emitComment(child) {
    if (child.comment && child.comment.shortText) {
        outStream.write("\n");
        for (const v of child.comment.shortText.split("\n"))
            outStream.write(`/// ${v}\n`);
    }
}

function translateType(type) {
    if (type === "string") return "[]const u8";
    if (type === "number") return "ManuallyTranslateNumberType";
    return type;
}

function emitType(type) {
    switch (type.type) {
        case "intrinsic":
            outStream.write(translateType(type.name));
            break;

        case "reference":
            outStream.write(type.name);
            break;

        case "array":
            outStream.write("[]");
            emitType(type.elementType);
            break;

        case "literal":
            outStream.write(`${type.value}`);
            break;

        case "union":
            if (type.types[0].type === "literal") {
                outStream.write("enum {");
                for (const child of type.types) {
                    if (child.type === "reflection") continue;
                    emitType(child);
                    outStream.write(",\n");
                }
                outStream.write(`\n\n
        usingnamespace IntBackedEnumStringify(@This());
        `);
            } else {
                outStream.write("union(enum) {");
                for (const child of type.types) {
                    if (child.type === "reflection") continue;
                    outStream.write(`${wrapName(child.name)}: `);
                    emitType(child);
                    outStream.write(",\n");
                }
            }
            outStream.write("}");
            break;

        case "tuple":
            outStream.write("Tuple(&[_]type {")
            for (const child of type.elements) {
                emitType(child);
                outStream.write(",")
            }
            outStream.write("})");
            break;
    
        default:
            console.error("Unhandled type kind:", type.type);
            break;
    }
}

function emitChild(schema, child) {
    switch (child.kindString) {
        case "Reference":
            emitComment(child);
            outStream.write(`const ${wrapName(child.name)} = ${locateId(schema, child.target).name};\n`);
            break;

        case "Interface":
            emitComment(child);
            outStream.write(`const ${wrapName(child.name)} = struct {`);
            if (child.children)
                for (const cc of child.children) emitChild(schema, cc);
            outStream.write(`};\n`);
            break;

        case "Property":
            if (child.type.type === "reflection") return;
            emitComment(child);
            outStream.write(`${wrapName(child.name)}: `);
            emitType(child.type);
            outStream.write(",\n");
            break;

        case "Type alias":
            if (schema.children.reduce((prev, curr) => prev || (curr.kindString !== "Type alias" && curr.name === child.name), false)) break;

            emitComment(child);
            outStream.write(`const ${wrapName(child.name)} = `);
            emitType(child.type);
            outStream.write(";\n");
            break;

        case "Method":
            break;

        case "Class":
            break;

        case "Function":
            break;

        case "Namespace":
            if (child.children.reduce((prev, curr) => prev || (curr.kindString === "Function"), false)) {
                break;
            }

            if (child.children.reduce((prev, curr) => prev || (curr.type.type === "literal" && typeof curr.type.value === "number"), false)) {
                emitComment(child);
                outStream.write(`const ${wrapName(child.name)} = enum {`);
                if (child.children)
                    for (const cc of child.children) outStream.write(`${wrapName(cc.name)} = ${cc.defaultValue},`);
                outStream.write(`\n\n
        usingnamespace IntBackedEnumStringify(@This());
        `);
            } else {
                emitComment(child);
                outStream.write(`const ${wrapName(child.name)} = struct {`);
                if (child.children)
                    for (const cc of child.children) emitChild(schema, cc);
            }
            outStream.write(`};\n`);

            break;

        case "Variable":
            emitComment(child);
            outStream.write(`const ${wrapName(child.name)} = `);

            if (child.defaultValue) {
                if (child.defaultValue.startsWith("'"))
                    outStream.write(`"${child.defaultValue.slice(1, -1)}"`);
                else if (!isNaN(parseFloat(child.defaultValue)))
                    outStream.write(child.defaultValue);
                else if (child.defaultValue === "...") {
                    outStream.write("ManuallyTranslateValue");
                }
            } else {
                console.log("Variable!!!", child.name);
            }
            outStream.write(";");
            break;

        case "Enumeration":
            emitComment(child);
            outStream.write(`const ${wrapName(child.name)} = struct {`);
            for (const cc of child.children) {
                outStream.write(`const ${wrapName(cc.name)} = ${cc.defaultValue};`)
            }
            outStream.write("};");
            break;
    
        default:
            console.error("Unhandled child of kind:", child.name, child.kindString);
            break;
    }
}

let JOE = new Set();

outStream.write(base);
for (const child of typeSchema.children) {
    JOE.add(child.name);
    if (child.name === "integer" || child.name === "uinteger" || child.name === "decimal" || child.name.startsWith("LSP")) continue;
    emitChild(typeSchema, child);
}
// for (const child of protocolSchema.children) {
//     if (JOE.has(child.name)) continue;
//     emitChild(protocolSchema, child);
// }
