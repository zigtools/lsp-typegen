module.exports = {
    wrapName(name) {
        if (["type", "async", "struct", "enum", "export", "import", "error"].includes(name) || name.includes("$")) return `@"${name}"`;
        return name;
    },

    /**
     * Fixes that shitty typedoc alphabetical ordering (I love u typedoc but like why 😭😭)
     */
    sortChildren(children) {
        return children.sort((a, b) => a.id - b.id);
    },

    isFunctionNamespace(child) {
        return child.children.reduce((prev, curr) => prev || (curr.kindString === "Function"), false);
    },

    translateType(type) {
        if (type === "string") return "[]const u8";
        if (type === "number" || type === "uinteger" || type === "integer") return "i64";
        if (type === "boolean") return "bool";
        if (type === "object") return "std.json.ObjectMap";
        if (type === "any" || type === "unknown") return "std.json.Value";
        return type;
    },
};
