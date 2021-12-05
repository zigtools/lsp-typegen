# lspoop

Crappy LSP spec-based Zig struct generator. It "works."

## Usage Instructions

```bash
# Install submodules
git submodule update --init --recursive

## Install TSJSONSchema
npm install typescript-json-schema -g`

## Generate schema
typescript-json-schema vendor/vscode-languageserver-node/protocol/src/common/tsconfig.json * --required --aliasRefs > src/schema.json

## Translate schema to Zig
zig build run

## Format so it looks good
zig fmt lsp.zig
```

## Dumpy

https://github.com/YousefED/typescript-json-schema
https://github.com/microsoft/vscode-languageserver-node/blob/main/protocol/src/common/protocol.ts

TODO: Translate jsonrpc
