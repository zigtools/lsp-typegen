const fs = require("fs");
const path = require("path");

const base = fs.readFileSync(path.join(__dirname, "base.zig"));
const typeSchema = JSON.parse(fs.readFileSync(path.join(__dirname, "types_schema.json")));
const protocolSchema = JSON.parse(fs.readFileSync(path.join(__dirname, "protocol_schema.json")));

const outStream = fs.createWriteStream(path.join(process.cwd(), "lsp.zig"));

function wrapName(name) {
    if (["type", "async", "struct", "enum", "export", "import", "error"].includes(name) || name.includes("$")) return `@"${name}"`;
    return name;
}

function locateId(schema, id) {
    for (const child of schema.children) {
        if (child.id === id) return child;
    }

    throw new Error("BRUH");
}

function locateName(schema, name) {
    for (const child of schema.children) {
        if (child.name === name) return child;
    }
    
    for (const child of schema.children.find(_ => _.name === "<internal>").children) {
        if (child.name === name) return child;
    }

    console.log(name);
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
    if (type === "number") return "i64";
    if (type === "boolean") return "bool";
    return type;
}

function emitType(type) {
    switch (type.type) {
        case "intrinsic":
            outStream.write(translateType(type.name));
            break;

        case "reference":
            outStream.write(wrapName(type.name));
            break;

        case "array":
            outStream.write("[]");
            emitType(type.elementType);
            break;

        case "literal":
            outStream.write(`${type.value}`);
            break;

        case "union":
            if (type.types.reduce((prev, curr) => prev && (curr.type === "literal"), true)) {
            // if (type.types[0].type === "literal") {
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
                const n = type.types.reduce((prev, curr) => prev || (curr.value === null), false);
                if (n)
                    outStream.write("?");
                    
                if (n && type.types.length === 2) {
                    emitType(type.types.find(_ => _.value !== null));
                    break;
                } else {
                    outStream.write("union(enum) {");
                    for (const child of type.types) {
                        if (child.type === "reflection" || child.value === null) continue;
                        outStream.write(`${wrapName(child.name || child.type)}: `);
                        emitType(child);
                        outStream.write(",\n");
                    }
                }
            }
            outStream.write("}");
            break;

        case "tuple":
            outStream.write("Tuple(&[_]type {");
            for (const child of type.elements) {
                emitType(child);
                outStream.write(",")
            }
            outStream.write("})");
            break;

        case "intersection":
            outStream.write("struct {");
            for (const c of type.types) {
                let z = locateName(protocolSchema, c.name);
                // console.log(locateName(c.name));
                for (const zz of z.children)
                    emitChild(protocolSchema, zz);
            }
            outStream.write("}");
            break;

        case "query":
            outStream.write("QUERY");
            break;
    
        default:
            console.error("Unhandled type kind:", type.type);
            break;
    }
}

function emitChild(schema, child) {
    if (child.name === "<internal>") return;

    switch (child.kindString) {
        case "Reference":
            emitComment(child);
            outStream.write(`const ${wrapName(child.name)} = ${wrapName(locateId(schema, child.target).name)};\n`);
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
            if (child.type.type === "reflection") return;
            if (schema.children.reduce((prev, curr) => prev || (curr.kindString !== "Type alias" && curr.kindString !== "Namespace" && curr.name === child.name), false)) break;

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

            // console.log(child.name, child.children.map(_ => _.type));

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
                } else {
                    outStream.write(child.defaultValue);
                }
            } else {
                emitType(child.type);
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

        case "Constructor":
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
for (const child of protocolSchema.children) {
    if (JOE.has(child.name)) continue;
    emitChild(protocolSchema, child);
}
