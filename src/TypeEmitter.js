const fs = require("fs");
const typedoc = require("typedoc");

const utils = require("./utils");

module.exports = class TypeEmitter {
    /**
     * Create an LSPooper (more technically a `TypeEmitter`)
     * 
     * @param {fs.WriteStream} writeStream 
     * @param {typedoc.JSONOutput.ProjectReflection} project 
     */
    constructor(writeStream, project) {
        this.writeStream = writeStream;
        this.project = project;
    }

    emitComment(child) {
        if (child.comment && child.comment.shortText) {
            this.writeStream.write("\n");
            for (const v of child.comment.shortText.split("\n"))
                this.writeStream.write(`/// ${v}\n`);
        }
    }

    locateChildById(id, parent) {
        parent = parent || this.project;
        for (const child of parent.children) {
            if (child.id === id) return child;
        }

        throw new Error(`Could not locate child by id: ${id}`);
    }
    
    locateChildByName(name, parent) {
        parent = parent || this.project;
        for (const child of parent.children) {
            if (child.name === name) return child;
        }
        
        for (const child of parent.children.find(_ => _.name === "<internal>").children) {
            if (child.name === name) return child;
        }
    
        throw new Error(`Could not locate child by name: ${name}`);
    }
    
    /**
     * 
     * @param {typedoc.Type} type 
     */
    emitType(type) {
        switch (type.type) {
            case "intrinsic":
                /**
                 * @type {typedoc.IntrinsicType}
                 */
                var intrinsic = type;

                this.writeStream.write(utils.translateType(intrinsic.name));
                break;
    
            case "reference":
                /**
                 * @type {typedoc.ReferenceType}
                 */
                var reference = type;

                this.writeStream.write(utils.wrapName(utils.translateType(reference.name)));
                break;
    
            case "array":
                /**
                 * @type {typedoc.ArrayType}
                 */
                var array = type;

                this.writeStream.write("[]");
                this.emitType(array.elementType);
                break;
    
            case "literal":
                /**
                 * @type {typedoc.LiteralType}
                 */
                var literal = type;

                this.writeStream.write(`${literal.value}`);
                break;
    
            case "union":
                /**
                 * @type {typedoc.UnionType}
                 */
                var union = type;

                if (union.types.reduce((prev, curr) => prev && (curr.type === "literal"), true)) {
                    this.writeStream.write("enum {");
                    for (const child of union.types) {
                        this.emitType(child);
                        this.writeStream.write(",\n");
                    }
                    this.writeStream.write(`\n\n
            usingnamespace StringBackedEnumStringify(@This());
            `);
                } else {
                    const n = union.types.reduce((prev, curr) => prev || (curr.value === null), false);
                    if (n)
                        this.writeStream.write("?");
                        
                    if (n && union.types.length === 2) {
                        this.emitType(union.types.find(_ => _.value !== null));
                        break;
                    } else {
                        this.writeStream.write("union(enum) {");
                        for (const child of union.types) {
                            if (child.value === null) continue;
                            this.writeStream.write(`${utils.wrapName(child.name || child.type)}: `);
                            this.emitType(child);
                            this.writeStream.write(",\n");
                        }
                    }
                }
                this.writeStream.write("}");
                break;
    
            case "tuple":
                /**
                 * @type {typedoc.TupleType}
                 */
                var tuple = type;

                this.writeStream.write("Tuple(&[_]type {");
                for (const child of tuple.elements) {
                    this.emitType(child);
                    this.writeStream.write(",")
                }
                this.writeStream.write("})");
                break;
    
            case "intersection":
                /**
                 * @type {typedoc.IntersectionType}
                 */
                var intersection = type;

                this.writeStream.write("struct {");
                for (const c of intersection.types) {
                    if (c.type === "reference") {
                        let z = this.locateChildByName(c.name);
                        for (const zz of utils.sortChildren(z.children))
                            this.emitChild(zz);
                    } else {
                        console.log("AAA", c.type);
                    }
                }
                this.writeStream.write("}");
                break;
    
            case "query":
                /**
                 * @type {typedoc.QueryType}
                 */
                var query = type;

                this.writeStream.write("QUERY");
                break;
    
            case "reflection":
                /**
                 * @type {typedoc.ReflectionType}
                 */
                var reflection = type;

                if (reflection.declaration) {
                    this.emitChild(reflection.declaration);
                } else {
                    throw new Error("BRUH!!!");
                }
                break;
        
            default:
                console.error("Unhandled type kind:", type.type);
                break;
        }
    }
    
    /**
     * 
     * @param {typedoc.JSONOutput.Reflection} child 
     * @returns 
     */
    emitChild(child) {
        if (child.name === "<internal>") return;
    
        switch (child.kind) {
            case typedoc.ReflectionKind.Reference:
                this.emitComment(child);
                this.writeStream.write(`pub const ${utils.wrapName(child.name)} = ${utils.wrapName(this.locateChildById(child.target).name)};\n`);
                break;
    
            case typedoc.ReflectionKind.Interface:
                this.emitComment(child);
                if (child.typeParameter) {
                    this.writeStream.write(`pub fn ${utils.wrapName(child.name)}(${child.typeParameter.map(_ => `comptime ${_.name}: type`)}) type {\nreturn struct {`);
                    if (child.children)
                        for (const cc of utils.sortChildren(child.children)) this.emitChild(cc);
                    this.writeStream.write(`};}\n`);
                } else {
                    this.writeStream.write(`pub const ${utils.wrapName(child.name)} = struct {`);
                    if (child.children)
                        for (const cc of utils.sortChildren(child.children)) this.emitChild(cc);
                    this.writeStream.write(`};\n`);
                }
                break;
    
            case typedoc.ReflectionKind.Property:
                this.emitComment(child);
                if (child.type.type === "literal") {
                    this.writeStream.write(`comptime ${utils.wrapName(child.name)}: ${utils.translateType(typeof child.type.value)} = ${JSON.stringify(child.type.value)},\n`);
                } else {
                    this.writeStream.write(`${utils.wrapName(child.name)}: `);
                    if (child.flags.isOptional) this.writeStream.write("Undefinedable(");
                    this.emitType(child.type);
                    if (child.flags.isOptional) this.writeStream.write(")");
                    this.writeStream.write(",\n");
                }
                break;
    
            case typedoc.ReflectionKind.TypeAlias:
                if (child.type.type === "reflection") return;
                if (this.project.children.reduce((prev, curr) => prev || (curr.kindString === "Namespace" && curr.name === child.name && !utils.isFunctionNamespace(curr)), false)) break;
    
                this.emitComment(child);
                this.writeStream.write(`pub const ${utils.wrapName(child.name)} = `);
                this.emitType(child.type);
                this.writeStream.write(";\n");
                break;
    
            case typedoc.ReflectionKind.TypeLiteral:
                if (child.children) {
                    this.writeStream.write(`struct {`);
                    for (const c of child.children)
                        this.emitChild(c);
                    this.writeStream.write("}");
                } else {
                    this.writeStream.write("ManuallyTranslateValue");
                }
                break;
    
            case typedoc.ReflectionKind.Method:
                break;
    
            case typedoc.ReflectionKind.Class:
                break;
    
            case typedoc.ReflectionKind.Function:
                break;
    
            case typedoc.ReflectionKind.Namespace:
                if (utils.isFunctionNamespace(child)) {
                    break;
                }
    
                if (child.children.reduce((prev, curr) => prev || (curr.type.type === "literal" && typeof curr.type.value === "number"), false)) {
                    this.emitComment(child);
                    this.writeStream.write(`pub const ${utils.wrapName(child.name)} = enum(i64) {`);
                    if (utils.sortChildren(child.children))
                        for (const cc of child.children) this.writeStream.write(`${utils.wrapName(cc.name)} = ${cc.defaultValue},`);
                    this.writeStream.write(`\n\n
            usingnamespace IntBackedEnumStringify(@This());
            `);
                } else {
                    this.emitComment(child);
                    this.writeStream.write(`pub const ${utils.wrapName(child.name)} = struct {`);
                    if (child.children)
                        for (const cc of utils.sortChildren(child.children)) this.emitChild(cc);
                }
                this.writeStream.write(`};\n`);
    
                break;
    
            case typedoc.ReflectionKind.Variable:
                this.emitComment(child);
                this.writeStream.write(`pub const ${utils.wrapName(child.name)} = `);
    
                if (child.defaultValue) {
                    if (child.defaultValue.startsWith("'"))
                        this.writeStream.write(`"${child.defaultValue.slice(1, -1)}"`);
                    else if (!isNaN(parseFloat(child.defaultValue)))
                        this.writeStream.write(child.defaultValue);
                    else if (child.defaultValue === "...") {
                        this.writeStream.write("ManuallyTranslateValue");
                    } else {
                        this.writeStream.write(child.defaultValue);
                    }
                } else {
                    this.emitType(child.type);
                }
                this.writeStream.write(";");
                break;
    
            case typedoc.ReflectionKind.Enum:
                this.emitComment(child);
                this.writeStream.write(`pub const ${utils.wrapName(child.name)} = struct {`);
                for (const cc of child.children) {
                    this.writeStream.write(`pub const ${utils.wrapName(cc.name)} = ${cc.defaultValue};`)
                }
                this.writeStream.write("};");
                break;
    
            case typedoc.ReflectionKind.Constructor:
                break;
        
            default:
                console.error("Unhandled child of kind:", child.name, child.kindString);
                break;
        }
    }
}
