# lspoop

Crappy LSP spec-based Zig struct generator. It "works."

## Usage Instructions

```bash
# Clone typedefs
git clone https://github.com/microsoft/vscode-languageserver-node vendor/vscode-languageserver-node
cd vendor/vscode-languageserver-node
git checkout tags/release/protocol/3.16.0
npm install
cd ../..

# Install Typedoc
npm install typedoc --save-dev
npm install typedoc-plugin-missing-exports --save-dev

# Generate schemas
npx typedoc --tsconfig vendor/vscode-languageserver-node/types/src/tsconfig.json vendor/vscode-languageserver-node/types/src/main.ts --json src/types_schema.json --emit docs

npx typedoc --tsconfig vendor/vscode-languageserver-node/protocol/src/common/tsconfig.json vendor/vscode-languageserver-node/protocol/src/common/protocol.ts --json src/protocol_schema.json --emit docs

# Translate schema to Zig
node src/index.js

## Format so it looks good
zig fmt lsp.zig
```

## Dumpy

https://github.com/microsoft/vscode-languageserver-node/blob/main/protocol/src/common/protocol.ts
