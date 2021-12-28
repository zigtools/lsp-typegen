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

/**
 * Fixes that shitty typedoc alphabetical ordering (I love u typedoc but like why 😭😭)
 */
function sortChildren(children) {
    return children.sort((a, b) => a.id - b.id);
}

function isFunctionNamespace(child) {
    return child.children.reduce((prev, curr) => prev || (curr.kindString === "Function"), false);
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
    if (type === "object") return "ManuallyTranslateValue";
    if (type === "any" || type === "unknown") return "std.json.Value";
    return type;
}

function emitType(schema, type) {
    switch (type.type) {
        case "intrinsic":
            outStream.write(translateType(type.name));
            break;

        case "reference":
            outStream.write(wrapName(type.name));
            break;

        case "array":
            outStream.write("[]");
            emitType(schema, type.elementType);
            break;

        case "literal":
            outStream.write(`${type.value}`);
            break;

        case "union":
            if (type.types.reduce((prev, curr) => prev && (curr.type === "literal"), true)) {
            // if (type.types[0].type === "literal") {
                outStream.write("enum {");
                for (const child of type.types) {
                    // if (child.type === "reflection") continue;
                    emitType(schema, child);
                    outStream.write(",\n");
                }
                outStream.write(`\n\n
        usingnamespace StringBackedEnumStringify(@This());
        `);
            } else {
                const n = type.types.reduce((prev, curr) => prev || (curr.value === null), false);
                if (n)
                    outStream.write("?");
                    
                if (n && type.types.length === 2) {
                    emitType(schema, type.types.find(_ => _.value !== null));
                    break;
                } else {
                    outStream.write("union(enum) {");
                    for (const child of type.types) {
                        if (child.value === null) continue;
                        outStream.write(`${wrapName(child.name || child.type)}: `);
                        emitType(schema, child);
                        outStream.write(",\n");
                    }
                }
            }
            outStream.write("}");
            break;

        case "tuple":
            outStream.write("Tuple(&[_]type {");
            for (const child of type.elements) {
                emitType(schema, child);
                outStream.write(",")
            }
            outStream.write("})");
            break;

        case "intersection":
            outStream.write("struct {");
            for (const c of type.types) {
                if (c.type === "reference") {
                    let z = locateName(protocolSchema, c.name);
                    // console.log(locateName(c.name));
                    for (const zz of sortChildren(z.children))
                        emitChild(protocolSchema, zz);
                } else {
                    console.log("AAA", c.type);
                }
            }
            outStream.write("}");
            break;

        case "query":
            outStream.write("QUERY");
            break;

        case "reflection":
            if (type.declaration) {
                emitChild(schema, type.declaration);
            } else {
                throw new Error("BRUH!!!");
            }
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
                for (const cc of sortChildren(child.children)) emitChild(schema, cc);
            outStream.write(`};\n`);
            break;

        case "Property":
            // if (child.type.type === "reflection" && child.type.declaration.name !== "__type") return;
            emitComment(child);
            if (child.type.type === "literal") {
                outStream.write(`comptime ${wrapName(child.name)}: ${translateType(typeof child.type.value)} = ${JSON.stringify(child.type.value)},\n`);
            } else {
                outStream.write(`${wrapName(child.name)}: `);
                if (child.flags.isOptional) outStream.write("Undefinedable(");
                emitType(schema, child.type);
                if (child.flags.isOptional) outStream.write(")");
                outStream.write(",\n");
            }
            break;

        case "Type alias":
            if (child.type.type === "reflection") return;
            // if (schema.children.reduce((prev, curr) => prev || (curr.kindString !== "Type alias" && curr.name === child.name), false)) break;
            if (schema.children.reduce((prev, curr) => prev || (curr.kindString === "Namespace" && curr.name === child.name && !isFunctionNamespace(curr)), false)) break;

            // console.log()

            emitComment(child);
            outStream.write(`const ${wrapName(child.name)} = `);
            emitType(schema, child.type);
            outStream.write(";\n");
            break;

        case "Type literal":
            if (child.children) {
                outStream.write(`struct {`);
                for (const c of child.children)
                    emitChild(schema, c);
                outStream.write("}");
            } else {
                outStream.write("ManuallyTranslateValue");
                // console.log("BRUH TLs suck butt", child);
            }
            break;

        case "Method":
            break;

        case "Class":
            break;

        case "Function":
            break;

        case "Namespace":
            if (isFunctionNamespace(child)) {
                break;
            }

            // console.log(child.name, child.children.map(_ => _.type));

            if (child.children.reduce((prev, curr) => prev || (curr.type.type === "literal" && typeof curr.type.value === "number"), false)) {
                emitComment(child);
                outStream.write(`const ${wrapName(child.name)} = enum(i64) {`);
                if (sortChildren(child.children))
                    for (const cc of child.children) outStream.write(`${wrapName(cc.name)} = ${cc.defaultValue},`);
                outStream.write(`\n\n
        usingnamespace IntBackedEnumStringify(@This());
        `);
            } else {
                emitComment(child);
                outStream.write(`const ${wrapName(child.name)} = struct {`);
                if (child.children)
                    for (const cc of sortChildren(child.children)) emitChild(schema, cc);
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
                emitType(schema, child.type);
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

function isModuleSource(sources) {
    return sources && sources.find(_ => _.fileName.indexOf("typescript") !== -1) !== undefined;
}

/**
 * Damn nasty root types!! We don't want these!
 */
const NUKE = [/MessageSignature/, /HandlerResult/, /integer/, /decimal/, /LSP.+/, /_.*/];

outStream.write(base);
for (const child of sortChildren(typeSchema.children)) {
    JOE.add(child.name);
    if (NUKE.reduce((prev, curr) => prev || curr.test(child.name), false) || isModuleSource(child.sources)) continue;
    emitChild(typeSchema, child);
}
for (const child of sortChildren(protocolSchema.children.find(_ => _.name === "<internal>").children)) {
    if (JOE.has(child.name) || NUKE.reduce((prev, curr) => prev || curr.test(child.name), false) || isModuleSource(child.sources)) continue;
    emitChild(protocolSchema, child);
}
for (const child of sortChildren(protocolSchema.children)) {
    if (JOE.has(child.name) || NUKE.reduce((prev, curr) => prev || curr.test(child.name), false) || isModuleSource(child.sources)) continue;
    emitChild(protocolSchema, child);
}

outStream.close(() => {
    console.log("File generated!");

    var l = require("child_process").spawn("zig", ["fmt", "lsp.zig"]);
    l.on("exit", () => {
        console.log("File formatted!");
    });
});
// console.log(l.toString());
