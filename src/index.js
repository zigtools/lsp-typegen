const fs = require("fs");
const path = require("path");
const utils = require("./utils");

const base = fs.readFileSync(path.join(__dirname, "base.zig"));
const typeSchema = JSON.parse(fs.readFileSync(path.join(__dirname, "types_schema.json")));
const protocolSchema = JSON.parse(fs.readFileSync(path.join(__dirname, "protocol_schema.json")));

const writeStream = fs.createWriteStream(path.join(process.cwd(), "lsp_generated.zig"));
const TypeEmitter = require("./TypeEmitter");

let JOE = new Set();

function isModuleSource(sources) {
    return sources && sources.find(_ => _.fileName.indexOf("typescript") !== -1) !== undefined;
}

var typeSchemaEmitter = new TypeEmitter(writeStream, typeSchema);
var protocolSchemaEmitter = new TypeEmitter(writeStream, protocolSchema);

/**
 * Damn nasty root types!! We don't want these!
 */
const NUKE = [/MessageSignature/, /HandlerResult/, /integer/, /decimal/, /LSP.+/, /_.*/, /.+Handler/];
let requestTypes = protocolSchema.children.filter(_ => _.name.endsWith("Request")).map(_ => _.name);
let notificationTypes = protocolSchema.children.filter(_ => _.name.endsWith("Notification")).map(_ => _.name);

writeStream.write(base);
for (const child of utils.sortChildren(typeSchema.children)) {
    JOE.add(child.name);
    if (NUKE.reduce((prev, curr) => prev || curr.test(child.name), false) || isModuleSource(child.sources)) continue;
    typeSchemaEmitter.emitChild(child);
}
for (const child of utils.sortChildren(protocolSchema.children.find(_ => _.name === "<internal>").children)) {
    if (JOE.has(child.name) || NUKE.reduce((prev, curr) => prev || curr.test(child.name), false) || isModuleSource(child.sources)) continue;
    protocolSchemaEmitter.emitChild(child);
}
for (const child of utils.sortChildren(protocolSchema.children)) {
    if (JOE.has(child.name) || NUKE.reduce((prev, curr) => prev || curr.test(child.name), false) || isModuleSource(child.sources)) continue;
    protocolSchemaEmitter.emitChild(child);
}

writeStream.write(`\npub const Request = union(enum) {${requestTypes.map(_ => `${_}: ${_},`).join("\n")}};`);
writeStream.write(`\npub const Notification = union(enum) {${notificationTypes.map(_ => `${_}: ${_},`).join("\n")}};`);

writeStream.close(() => {
    console.log("File generated!");

    var l = require("child_process").spawn("zig", ["fmt", "lsp_generated.zig"]);
    l.on("exit", () => {
        console.log("File formatted!");
    });
});
