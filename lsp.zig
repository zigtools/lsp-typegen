const std = @import("std");
const json = std.json;
const Tuple = std.meta.Tuple;

pub fn IntBackedEnumStringify(comptime T: type) type {
    return struct {
        pub fn jsonStringify(value: T, options: json.StringifyOptions, out_stream: anytype) !void {
            try json.stringify(@enumToInt(value), options, out_stream);
        }
    };
}

test "int-backed enum stringify" {
    const MyEnum = enum(i64) {
        one = 1,
        two = 2,

        usingnamespace IntBackedEnumStringify(@This());
    };

    var buf: [2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);

    try json.stringify(MyEnum.one, .{}, fbs.writer());
    try std.testing.expectEqual(@as(u8, '1'), buf[0]);

    try json.stringify(MyEnum.two, .{}, fbs.writer());
    try std.testing.expectEqual(@as(u8, '2'), buf[1]);
}

/// The LSP any type
const LSPAny = std.json.Value;

/// A set of predefined code action kinds
const CodeActionKind = struct {
/// Empty kind.
const Empty = "";
/// Base kind for quickfix actions: 'quickfix'
const QuickFix = "quickfix";
/// Base kind for refactoring actions: 'refactor'
const Refactor = "refactor";
/// Base kind for refactoring extraction actions: 'refactor.extract'
const RefactorExtract = "refactor.extract";
/// Base kind for refactoring inline actions: 'refactor.inline'
const RefactorInline = "refactor.inline";
/// Base kind for refactoring rewrite actions: 'refactor.rewrite'
const RefactorRewrite = "refactor.rewrite";
/// Base kind for source actions: `source`
const Source = "source";
/// Base kind for auto-fix source actions: `source.fixAll`.
const SourceFixAll = "source.fixAll";
/// Base kind for an organize imports source action: `source.organizeImports`
const SourceOrganizeImports = "source.organizeImports";};

/// The reason why code actions were requested.
const CodeActionTriggerKind = enum {Automatic = 2,Invoked = 1,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// The kind of a completion entry.
const CompletionItemKind = enum {Class = 7,Color = 16,Constant = 21,Constructor = 4,Enum = 13,EnumMember = 20,Event = 23,Field = 5,File = 17,Folder = 19,Function = 3,Interface = 8,Keyword = 14,Method = 2,Module = 9,Operator = 24,Property = 10,Reference = 18,Snippet = 15,Struct = 22,Text = 1,TypeParameter = 25,Unit = 11,Value = 12,Variable = 6,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// Completion item tags are extra annotations that tweak the rendering of a completion
/// item.
const CompletionItemTag = enum {Deprecated = 1,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// The diagnostic's severity.
const DiagnosticSeverity = enum {Error = 1,Hint = 4,Information = 3,Warning = 2,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// The diagnostic tags.
const DiagnosticTag = enum {Deprecated = 2,Unnecessary = 1,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// A document highlight kind.
const DocumentHighlightKind = enum {Read = 2,Text = 1,Write = 3,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// Defines whether the insert text in a completion item should be interpreted as
/// plain text or a snippet.
const InsertTextFormat = enum {PlainText = 1,Snippet = 2,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// How whitespace and indentation is handled during completion
/// item insertion.
const InsertTextMode = enum {adjustIndentation = 2,asIs = 1,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// A symbol kind.
const SymbolKind = enum {Array = 18,Boolean = 17,Class = 5,Constant = 14,Constructor = 9,Enum = 10,EnumMember = 22,Event = 24,Field = 8,File = 1,Function = 12,Interface = 11,Key = 20,Method = 6,Module = 2,Namespace = 3,Null = 21,Number = 16,Object = 19,Operator = 25,Package = 4,Property = 7,String = 15,Struct = 23,TypeParameter = 26,Variable = 13,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// Symbol tags are extra annotations that tweak the rendering of a symbol.
const SymbolTag = enum {Deprecated = 1,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// Enum of known range kinds
const FoldingRangeKind = struct {const Comment = "comment";const Imports = "imports";const Region = "region";};
/// A set of predefined token modifiers. This set is not fixed
/// an clients can specify additional token types via the
/// corresponding client capabilities.
const SemanticTokenModifiers = struct {const abstract = "abstract";const @"async" = "async";const declaration = "declaration";const defaultLibrary = "defaultLibrary";const definition = "definition";const deprecated = "deprecated";const documentation = "documentation";const modification = "modification";const readonly = "readonly";const static = "static";};
/// A set of predefined token types. This set is not fixed
/// an clients can specify additional token types via the
/// corresponding client capabilities.
const SemanticTokenTypes = struct {const class = "class";const comment = "comment";const decorator = "decorator";const @"enum" = "enum";const enumMember = "enumMember";const event = "event";const function = "function";const interface = "interface";const keyword = "keyword";const macro = "macro";const method = "method";const modifier = "modifier";const namespace = "namespace";const number = "number";const operator = "operator";const parameter = "parameter";const property = "property";const regexp = "regexp";const string = "string";const @"struct" = "struct";const @"type" = "type";const typeParameter = "typeParameter";const variable = "variable";};
/// A special text edit with an additional change annotation.
const AnnotatedTextEdit = struct {
/// The actual identifier of the change annotation
annotationId: []const u8,

/// The string to be inserted. For delete operations use an
/// empty string.
newText: []const u8,

/// The range of the text document to be manipulated. To insert
/// text into a document create a range where start === end.
range: Range,
};

/// Represents an incoming call, e.g. a caller of a method or constructor.
const CallHierarchyIncomingCall = struct {
/// The item that makes the call.
from: CallHierarchyItem,

/// The ranges at which the calls appear. This is relative to the caller
/// denoted by [`this.from`](#CallHierarchyIncomingCall.from).
fromRanges: []Range,
};

/// Represents programming constructs like functions or constructors in the context
/// of call hierarchy.
const CallHierarchyItem = struct {
/// A data entry field that is preserved between a call hierarchy prepare and
/// incoming calls or outgoing calls requests.
data: LSPAny,

/// More detail for this item, e.g. the signature of a function.
detail: []const u8,

/// The kind of this item.
kind: SymbolKind,

/// The name of this item.
name: []const u8,

/// The range enclosing this symbol not including leading/trailing whitespace but everything else, e.g. comments and code.
range: Range,

/// The range that should be selected and revealed when this symbol is being picked, e.g. the name of a function.
/// Must be contained by the [`range`](#CallHierarchyItem.range).
selectionRange: Range,

/// Tags for this item.
tags: []1,

/// The resource identifier of this item.
uri: []const u8,
};

/// Represents an outgoing call, e.g. calling a getter from a method or a method from a constructor etc.
const CallHierarchyOutgoingCall = struct {
/// The range at which this item is called. This is the range relative to the caller, e.g the item
/// passed to [`provideCallHierarchyOutgoingCalls`](#CallHierarchyItemProvider.provideCallHierarchyOutgoingCalls)
/// and not [`this.to`](#CallHierarchyOutgoingCall.to).
fromRanges: []Range,

/// The item that is called.
to: CallHierarchyItem,
};

/// Additional information that describes document changes.
const ChangeAnnotation = struct {
/// A human-readable string which is rendered less prominent in
/// the user interface.
description: []const u8,

/// A human-readable string describing the actual change. The string
/// is rendered prominent in the user interface.
label: []const u8,

/// A flag which indicates that user confirmation is needed
/// before applying the change.
needsConfirmation: bool,
};

/// A code action represents a change that can be performed in code, e.g. to fix a problem or
/// to refactor code.
const CodeAction = struct {
/// A command this code action executes. If a code action
/// provides a edit and a command, first the edit is
/// executed and then the command.
command: Command,

/// A data entry field that is preserved on a code action between
/// a `textDocument/codeAction` and a `codeAction/resolve` request.
data: LSPAny,

/// The diagnostics that this code action resolves.
diagnostics: []Diagnostic,

/// The workspace edit this code action performs.
edit: WorkspaceEdit,

/// Marks this as a preferred action. Preferred actions are used by the `auto fix` command and can be targeted
/// by keybindings.
isPreferred: bool,

/// The kind of the code action.
kind: []const u8,

/// A short, human-readable, title for this code action.
title: []const u8,
};

/// Contains additional diagnostic information about the context in which
/// a [code action](#CodeActionProvider.provideCodeActions) is run.
const CodeActionContext = struct {
/// An array of diagnostics known on the client side overlapping the range provided to the
/// `textDocument/codeAction` request. They are provided so that the server knows which
/// errors are currently presented to the user for the given range. There is no guarantee
/// that these accurately reflect the error state of the resource. The primary parameter
/// to compute code actions is the provided range.
diagnostics: []Diagnostic,

/// Requested kind of actions to return.
only: [][]const u8,

/// The reason why code actions were requested.
triggerKind: CodeActionTriggerKind,
};

/// Structure to capture a description for an error code.
const CodeDescription = struct {
/// An URI to open with more information about the diagnostic error.
href: []const u8,
};

/// A code lens represents a [command](#Command) that should be shown along with
/// source text, like the number of references, a way to run tests, etc.
const CodeLens = struct {
/// The command this code lens represents.
command: Command,

/// A data entry field that is preserved on a code lens item between
/// a [CodeLensRequest](#CodeLensRequest) and a [CodeLensResolveRequest]
/// (#CodeLensResolveRequest)
data: LSPAny,

/// The range in which this code lens is valid. Should only span a single line.
range: Range,
};

/// Represents a color in RGBA space.
const Color = struct {
/// The alpha component of this color in the range [0-1].
alpha: i64,

/// The blue component of this color in the range [0-1].
blue: i64,

/// The green component of this color in the range [0-1].
green: i64,

/// The red component of this color in the range [0-1].
red: i64,
};

/// Represents a color range from a document.
const ColorInformation = struct {
/// The actual color value for this color range.
color: Color,

/// The range in the document where this color appears.
range: Range,
};
const ColorPresentation = struct {
/// An optional array of additional [text edits](#TextEdit) that are applied when
/// selecting this color presentation. Edits must not overlap with the main [edit](#ColorPresentation.textEdit) nor with themselves.
additionalTextEdits: []TextEdit,

/// The label of this color presentation. It will be shown on the color
/// picker header. By default this is also the text that is inserted when selecting
/// this color presentation.
label: []const u8,

/// An [edit](#TextEdit) which is applied to a document when selecting
/// this presentation for the color.  When `falsy` the [label](#ColorPresentation.label)
/// is used.
textEdit: TextEdit,
};

/// Represents a reference to a command. Provides a title which
/// will be used to represent a command in the UI and, optionally,
/// an array of arguments which will be passed to the command handler
/// function when invoked.
const Command = struct {
/// Arguments that the command handler should be
/// invoked with.
arguments: []LSPAny,

/// The identifier of the actual command handler.
command: []const u8,

/// Title of the command, like `save`.
title: []const u8,
};

/// A completion item represents a text snippet that is
/// proposed to complete text that is being typed.
const CompletionItem = struct {
/// An optional array of additional [text edits](#TextEdit) that are applied when
/// selecting this completion. Edits must not overlap (including the same insert position)
/// with the main [edit](#CompletionItem.textEdit) nor with themselves.
additionalTextEdits: []TextEdit,

/// An optional [command](#Command) that is executed *after* inserting this completion. *Note* that
/// additional modifications to the current document should be described with the
/// [additionalTextEdits](#CompletionItem.additionalTextEdits)-property.
command: Command,

/// An optional set of characters that when pressed while this completion is active will accept it first and
/// then type that character. *Note* that all commit characters should have `length=1` and that superfluous
/// characters will be ignored.
commitCharacters: [][]const u8,

/// A data entry field that is preserved on a completion item between a
/// [CompletionRequest](#CompletionRequest) and a [CompletionResolveRequest](#CompletionResolveRequest).
data: LSPAny,

/// Indicates if this item is deprecated.
deprecated: bool,

/// A human-readable string with additional information
/// about this item, like type or symbol information.
detail: []const u8,

/// A human-readable string that represents a doc-comment.
documentation: union(enum) {string: []const u8,
MarkupContent: MarkupContent,
},

/// A string that should be used when filtering a set of
/// completion items. When `falsy` the [label](#CompletionItem.label)
/// is used.
filterText: []const u8,

/// A string that should be inserted into a document when selecting
/// this completion. When `falsy` the [label](#CompletionItem.label)
/// is used.
insertText: []const u8,

/// The format of the insert text. The format applies to both the `insertText` property
/// and the `newText` property of a provided `textEdit`. If omitted defaults to
/// `InsertTextFormat.PlainText`.
insertTextFormat: InsertTextFormat,

/// How whitespace and indentation is handled during completion
/// item insertion. If ignored the clients default value depends on
/// the `textDocument.completion.insertTextMode` client capability.
insertTextMode: InsertTextMode,

/// The kind of this completion item. Based of the kind
/// an icon is chosen by the editor.
kind: CompletionItemKind,

/// The label of this completion item.
label: []const u8,

/// Additional details for the label
labelDetails: CompletionItemLabelDetails,

/// Select this item when showing.
preselect: bool,

/// A string that should be used when comparing this item
/// with other items. When `falsy` the [label](#CompletionItem.label)
/// is used.
sortText: []const u8,

/// Tags for this completion item.
tags: []1,

/// An [edit](#TextEdit) which is applied to a document when selecting
/// this completion. When an edit is provided the value of
/// [insertText](#CompletionItem.insertText) is ignored.
textEdit: union(enum) {TextEdit: TextEdit,
InsertReplaceEdit: InsertReplaceEdit,
},
};

/// Additional details for a completion item label.
const CompletionItemLabelDetails = struct {
/// An optional string which is rendered less prominently after {@link CompletionItem.detail}. Should be used
/// for fully qualified names or file path.
description: []const u8,

/// An optional string which is rendered less prominently directly after {@link CompletionItem.label label},
/// without any spacing. Should be used for function signatures or type annotations.
detail: []const u8,
};

/// Represents a collection of [completion items](#CompletionItem) to be presented
/// in the editor.
const CompletionList = struct {
/// This list it not complete. Further typing results in recomputing this list.
isIncomplete: bool,

/// The completion items.
items: []CompletionItem,
};

/// Create file operation.
const CreateFile = struct {
/// An optional annotation identifier describing the operation.
annotationId: []const u8,

/// A create
kind: create,

/// Additional options
options: CreateFileOptions,

/// The resource to create.
uri: []const u8,
};

/// Options to create a file.
const CreateFileOptions = struct {
/// Ignore if exists.
ignoreIfExists: bool,

/// Overwrite existing file. Overwrite wins over `ignoreIfExists`
overwrite: bool,
};

/// Delete file operation
const DeleteFile = struct {
/// An optional annotation identifier describing the operation.
annotationId: []const u8,

/// A delete
kind: delete,

/// Delete options.
options: DeleteFileOptions,

/// The file to delete.
uri: []const u8,
};

/// Delete file options
const DeleteFileOptions = struct {
/// Ignore the operation if the file doesn't exist.
ignoreIfNotExists: bool,

/// Delete the content recursively if a folder is denoted.
recursive: bool,
};

/// Represents a diagnostic, such as a compiler error or warning. Diagnostic objects
/// are only valid in the scope of a resource.
const Diagnostic = struct {
/// The diagnostic's code, which usually appear in the user interface.
code: union(enum) {string: []const u8,
number: i64,
},

/// An optional property to describe the error code.
/// Requires the code field (above) to be present/not null.
codeDescription: CodeDescription,

/// A data entry field that is preserved between a `textDocument/publishDiagnostics`
/// notification and `textDocument/codeAction` request.
data: LSPAny,

/// The diagnostic's message. It usually appears in the user interface
message: []const u8,

/// The range at which the message applies
range: Range,

/// An array of related diagnostic information, e.g. when symbol-names within
/// a scope collide all definitions can be marked via this property.
relatedInformation: []DiagnosticRelatedInformation,

/// The diagnostic's severity. Can be omitted. If omitted it is up to the
/// client to interpret diagnostics as error, warning, info or hint.
severity: DiagnosticSeverity,

/// A human-readable string describing the source of this
/// diagnostic, e.g. 'typescript' or 'super lint'. It usually
/// appears in the user interface.
source: []const u8,

/// Additional metadata about the diagnostic.
tags: []DiagnosticTag,
};

/// Represents a related message and source code location for a diagnostic. This should be
/// used to point to code locations that cause or related to a diagnostics, e.g when duplicating
/// a symbol in a scope.
const DiagnosticRelatedInformation = struct {
/// The location of this related diagnostic information.
location: Location,

/// The message of this related diagnostic information.
message: []const u8,
};

/// A document highlight is a range inside a text document which deserves
/// special attention. Usually a document highlight is visualized by changing
/// the background color of its range.
const DocumentHighlight = struct {
/// The highlight kind, default is [text](#DocumentHighlightKind.Text).
kind: DocumentHighlightKind,

/// The range this highlight applies to.
range: Range,
};

/// A document link is a range in a text document that links to an internal or external resource, like another
/// text document or a web site.
const DocumentLink = struct {
/// A data entry field that is preserved on a document link between a
/// DocumentLinkRequest and a DocumentLinkResolveRequest.
data: LSPAny,

/// The range this link applies to.
range: Range,

/// The uri this link points to.
target: []const u8,

/// The tooltip text when you hover over this link.
tooltip: []const u8,
};

/// Represents programming constructs like variables, classes, interfaces etc.
/// that appear in a document. Document symbols can be hierarchical and they
/// have two ranges: one that encloses its definition and one that points to
/// its most interesting range, e.g. the range of an identifier.
const DocumentSymbol = struct {
/// Children of this symbol, e.g. properties of a class.
children: []DocumentSymbol,

/// Indicates if this symbol is deprecated.
deprecated: bool,

/// More detail for this symbol, e.g the signature of a function.
detail: []const u8,

/// The kind of this symbol.
kind: SymbolKind,

/// The name of this symbol. Will be displayed in the user interface and therefore must not be
/// an empty string or a string only consisting of white spaces.
name: []const u8,

/// The range enclosing this symbol not including leading/trailing whitespace but everything else
/// like comments. This information is typically used to determine if the the clients cursor is
/// inside the symbol to reveal in the symbol in the UI.
range: Range,

/// The range that should be selected and revealed when this symbol is being picked, e.g the name of a function.
/// Must be contained by the the `range`.
selectionRange: Range,

/// Tags for this document symbol.
tags: []1,
};

/// Represents a folding range. To be valid, start and end line must be bigger than zero and smaller
/// than the number of lines in the document. Clients are free to ignore invalid ranges.
const FoldingRange = struct {
/// The zero-based character offset before the folded range ends. If not defined, defaults to the length of the end line.
endCharacter: i64,

/// The zero-based end line of the range to fold. The folded area ends with the line's last character.
/// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
endLine: i64,

/// Describes the kind of the folding range such as `comment' or 'region'. The kind
/// is used to categorize folding ranges and used by commands like 'Fold all comments'. See
/// [FoldingRangeKind](#FoldingRangeKind) for an enumeration of standardized kinds.
kind: []const u8,

/// The zero-based character offset from where the folded range starts. If not defined, defaults to the length of the start line.
startCharacter: i64,

/// The zero-based start line of the range to fold. The folded area starts after the line's last character.
/// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
startLine: i64,
};

/// Value-object describing what options formatting should use.
const FormattingOptions = struct {
/// Insert a newline character at the end of the file if one does not exist.
insertFinalNewline: bool,

/// Prefer spaces over tabs.
insertSpaces: bool,

/// Size of a tab in spaces.
tabSize: i64,

/// Trim all newlines after the final newline at the end of the file.
trimFinalNewlines: bool,

/// Trim trailing whitespaces on a line.
trimTrailingWhitespace: bool,
};

/// The result of a hover request.
const Hover = struct {
/// The hover's content
contents: union(enum) {MarkupContent: MarkupContent,
MarkedString: MarkedString,
array: []MarkedString,
},

/// An optional range
range: Range,
};

/// Provide an inline value through an expression evaluation.
/// If only a range is specified, the expression will be extracted from the underlying document.
/// An optional expression can be used to override the extracted expression.
const InlineValueEvaluatableExpression = struct {
/// If specified the expression overrides the extracted expression.
expression: []const u8,

/// The document range for which the inline value applies.
/// The range is used to extract the evaluatable expression from the underlying document.
range: Range,
};

/// Provide inline value as text.
const InlineValueText = struct {
/// The document range for which the inline value applies.
range: Range,

/// The text of the inline value.
text: []const u8,
};

/// Provide inline value through a variable lookup.
/// If only a range is specified, the variable name will be extracted from the underlying document.
/// An optional variable name can be used to override the extracted name.
const InlineValueVariableLookup = struct {
/// How to perform the lookup.
caseSensitiveLookup: bool,

/// The document range for which the inline value applies.
/// The range is used to extract the variable name from the underlying document.
range: Range,

/// If specified the name of the variable to look up.
variableName: []const u8,
};
const InlineValuesContext = struct {
/// The document range where execution has stopped.
/// Typically the end position of the range denotes the line where the inline values are shown.
stoppedLocation: Range,
};

/// A special text edit to provide an insert and a replace operation.
const InsertReplaceEdit = struct {
/// The range if the insert is requested
insert: Range,

/// The string to be inserted.
newText: []const u8,

/// The range if the replace is requested.
replace: Range,
};

/// Represents a location inside a resource, such as a line
/// inside a text file.
const Location = struct {range: Range,
uri: []const u8,
};

/// Represents the connection of two locations. Provides additional metadata over normal [locations](#Location),
/// including an origin range.
const LocationLink = struct {
/// Span of the origin of this link.
originSelectionRange: Range,

/// The full target range of this link. If the target for example is a symbol then target range is the
/// range enclosing this symbol not including leading/trailing whitespace but everything else
/// like comments. This information is typically used to highlight the range in the editor.
targetRange: Range,

/// The range that should be selected and revealed when this link is being followed, e.g the name of a function.
/// Must be contained by the the `targetRange`. See also `DocumentSymbol#range`
targetSelectionRange: Range,

/// The target resource identifier of this link.
targetUri: []const u8,
};

/// A `MarkupContent` literal represents a string value which content is interpreted base on its
/// kind flag. Currently the protocol supports `plaintext` and `markdown` as markup kinds.
const MarkupContent = struct {
/// The type of the Markup
kind: MarkupKind,

/// The content itself
value: []const u8,
};

/// A text document identifier to optionally denote a specific version of a text document.
const OptionalVersionedTextDocumentIdentifier = struct {
/// The text document's uri.
uri: []const u8,

/// The version number of this document. If a versioned text document identifier
/// is sent from the server to the client and the file is not open in the editor
/// (the server has not received an open notification before) the server can send
/// `null` to indicate that the version is unknown and the content on disk is the
/// truth (as specified with document content ownership).
version: ?i64,
};

/// Represents a parameter of a callable-signature. A parameter can
/// have a label and a doc-comment.
const ParameterInformation = struct {
/// The human-readable doc-comment of this signature. Will be shown
/// in the UI but can be omitted.
documentation: union(enum) {string: []const u8,
MarkupContent: MarkupContent,
},

/// The label of this parameter information.
label: union(enum) {string: []const u8,
tuple: Tuple(&[_]type {i64,i64,}),
},
};

/// Position in a text document expressed as zero-based line and character offset.
/// The offsets are based on a UTF-16 string representation. So a string of the form
/// `a𐐀b` the character offset of the character `a` is 0, the character offset of `𐐀`
/// is 1 and the character offset of b is 3 since `𐐀` is represented using two code
/// units in UTF-16.
const Position = struct {
/// Character offset on a line in a document (zero-based). Assuming that the line is
/// represented as a string, the `character` value represents the gap between the
/// `character` and `character + 1`.
character: i64,

/// Line position in a document (zero-based).
line: i64,
};

/// A range in a text document expressed as (zero-based) start and end positions.
const Range = struct {
/// The range's end position.
end: Position,

/// The range's start position
start: Position,
};

/// Value-object that contains additional information when
/// requesting references.
const ReferenceContext = struct {
/// Include the declaration of the current symbol.
includeDeclaration: bool,
};

/// Rename file operation
const RenameFile = struct {
/// An optional annotation identifier describing the operation.
annotationId: []const u8,

/// A rename
kind: rename,

/// The new location.
newUri: []const u8,

/// The old (existing) location.
oldUri: []const u8,

/// Rename options.
options: RenameFileOptions,
};

/// Rename file options
const RenameFileOptions = struct {
/// Ignores if target exists.
ignoreIfExists: bool,

/// Overwrite target if existing. Overwrite wins over `ignoreIfExists`
overwrite: bool,
};

/// A selection range represents a part of a selection hierarchy. A selection range
/// may have a parent selection range that contains it.
const SelectionRange = struct {
/// The parent selection range containing this range. Therefore `parent.range` must contain `this.range`.
parent: SelectionRange,

/// The [range](#Range) of this selection range.
range: Range,
};
const SemanticTokens = struct {
/// The actual tokens.
data: []i64,

/// An optional result id. If provided and clients support delta updating
/// the client will include the result id in the next semantic token request.
/// A server can then instead of computing all semantic tokens again simply
/// send a delta.
resultId: []const u8,
};
const SemanticTokensDelta = struct {
/// The semantic token edits to transform a previous result into a new result.
edits: []SemanticTokensEdit,
resultId: []const u8,
};
const SemanticTokensEdit = struct {
/// The elements to insert.
data: []i64,

/// The count of elements to remove.
deleteCount: i64,

/// The start offset of the edit.
start: i64,
};
const SemanticTokensLegend = struct {
/// The token modifiers a server uses.
tokenModifiers: [][]const u8,

/// The token types a server uses.
tokenTypes: [][]const u8,
};

/// Signature help represents the signature of something
/// callable. There can be multiple signature but only one
/// active and only one active parameter.
const SignatureHelp = struct {
/// The active parameter of the active signature. If omitted or the value
/// lies outside the range of `signatures[activeSignature].parameters`
/// defaults to 0 if the active signature has parameters. If
/// the active signature has no parameters it is ignored.
/// In future version of the protocol this property might become
/// mandatory to better express the active parameter if the
/// active signature does have any.
activeParameter: i64,

/// The active signature. If omitted or the value lies outside the
/// range of `signatures` the value defaults to zero or is ignored if
/// the `SignatureHelp` has no signatures.
activeSignature: i64,

/// One or more signatures.
signatures: []SignatureInformation,
};

/// Represents the signature of something callable. A signature
/// can have a label, like a function-name, a doc-comment, and
/// a set of parameters.
const SignatureInformation = struct {
/// The index of the active parameter.
activeParameter: i64,

/// The human-readable doc-comment of this signature. Will be shown
/// in the UI but can be omitted.
documentation: union(enum) {string: []const u8,
MarkupContent: MarkupContent,
},

/// The label of this signature. Will be shown in
/// the UI.
label: []const u8,

/// The parameters of this signature.
parameters: []ParameterInformation,
};

/// Represents information about programming constructs like variables, classes,
/// interfaces etc.
const SymbolInformation = struct {
/// The name of the symbol containing this symbol. This information is for
/// user interface purposes (e.g. to render a qualifier in the user interface
/// if necessary). It can't be used to re-infer a hierarchy for the document
/// symbols.
containerName: []const u8,

/// Indicates if this symbol is deprecated.
deprecated: bool,

/// The kind of this symbol.
kind: SymbolKind,

/// The location of this symbol. The location's range is used by a tool
/// to reveal the location in the editor. If the symbol is selected in the
/// tool the range's start information is used to position the cursor. So
/// the range usually spans more than the actual symbol's name and does
/// normally include thinks like visibility modifiers.
location: Location,

/// The name of this symbol.
name: []const u8,

/// Tags for this completion item.
tags: []1,
};

/// A simple text document. Not to be implemented. The document keeps the content
/// as string.
const TextDocument = struct {
/// The identifier of the language associated with this document.
languageId: []const u8,

/// The number of lines in this document.
lineCount: i64,

/// The associated URI for this document. Most documents have the __file__-scheme, indicating that they
/// represent files on disk. However, some documents may have other schemes indicating that they are not
/// available on disk.
uri: []const u8,

/// The version number of this document (it will increase after each
/// change, including undo/redo).
version: i64,
};

/// Describes textual changes on a text document. A TextDocumentEdit describes all changes
/// on a document version Si and after they are applied move the document to version Si+1.
/// So the creator of a TextDocumentEdit doesn't need to sort the array of edits or do any
/// kind of ordering. However the edits must be non overlapping.
const TextDocumentEdit = struct {
/// The edits to be applied.
edits: []union(enum) {TextEdit: TextEdit,
AnnotatedTextEdit: AnnotatedTextEdit,
},

/// The text document to change.
textDocument: OptionalVersionedTextDocumentIdentifier,
};

/// A literal to identify a text document in the client.
const TextDocumentIdentifier = struct {
/// The text document's uri.
uri: []const u8,
};

/// An item to transfer a text document from the client to the
/// server.
const TextDocumentItem = struct {
/// The text document's language identifier
languageId: []const u8,

/// The content of the opened text document.
text: []const u8,

/// The text document's uri.
uri: []const u8,

/// The version number of this document (it will increase after each
/// change, including undo/redo).
version: i64,
};

/// A text edit applicable to a text document.
const TextEdit = struct {
/// The string to be inserted. For delete operations use an
/// empty string.
newText: []const u8,

/// The range of the text document to be manipulated. To insert
/// text into a document create a range where start === end.
range: Range,
};

/// A change to capture text edits for existing resources.
const TextEditChange = struct {};
const TypeHierarchyItem = struct {
/// A data entry field that is preserved between a type hierarchy prepare and
/// supertypes or subtypes requests. It could also be used to identify the
/// type hierarchy in the server, helping improve the performance on
/// resolving supertypes and subtypes.
data: LSPAny,

/// More detail for this item, e.g. the signature of a function.
detail: []const u8,

/// The kind of this item.
kind: SymbolKind,

/// The name of this item.
name: []const u8,

/// The range enclosing this symbol not including leading/trailing whitespace
/// but everything else, e.g. comments and code.
range: Range,

/// The range that should be selected and revealed when this symbol is being
/// picked, e.g. the name of a function. Must be contained by the
/// [`range`](#TypeHierarchyItem.range).
selectionRange: Range,

/// Tags for this item.
tags: []1,

/// The resource identifier of this item.
uri: []const u8,
};

/// A text document identifier to denote a specific version of a text document.
const VersionedTextDocumentIdentifier = struct {
/// The text document's uri.
uri: []const u8,

/// The version number of this document.
version: i64,
};

/// A workspace edit represents changes to many resources managed in the workspace. The edit
/// should either provide `changes` or `documentChanges`. If documentChanges are present
/// they are preferred over `changes` if the client can handle versioned document edits.
const WorkspaceEdit = struct {
/// Depending on the client capability `workspace.workspaceEdit.resourceOperations` document changes
/// are either an array of `TextDocumentEdit`s to express changes to n different text documents
/// where each text document edit addresses a specific version of a text document. Or it can contain
/// above `TextDocumentEdit`s mixed with create, rename and delete file / folder operations.
documentChanges: []union(enum) {TextDocumentEdit: TextDocumentEdit,
CreateFile: CreateFile,
RenameFile: RenameFile,
DeleteFile: DeleteFile,
},
};

/// A special workspace symbol that supports locations without a range
const WorkspaceSymbol = struct {
/// The name of the symbol containing this symbol. This information is for
/// user interface purposes (e.g. to render a qualifier in the user interface
/// if necessary). It can't be used to re-infer a hierarchy for the document
/// symbols.
containerName: []const u8,

/// A data entry field that is preserved on a workspace symbol between a
/// workspace symbol request and a workspace symbol resolve request.
data: LSPAny,

/// The kind of this symbol.
kind: SymbolKind,

/// The location of the symbol.
location: union(enum) {Location: Location,
},

/// The name of this symbol.
name: []const u8,

/// Tags for this completion item.
tags: []1,
};

/// An identifier to refer to a change annotation stored with a workspace edit.
const ChangeAnnotationIdentifier = []const u8;

/// The kind of a code action.
const CodeActionKind = []const u8;
const CodeActionTriggerKind = enum {1,
2,



        usingnamespace IntBackedEnumStringify(@This());
        };
const CompletionItemKind = enum {1,
2,
3,
4,
5,
6,
7,
8,
9,
10,
11,
12,
13,
14,
15,
16,
17,
18,
19,
20,
21,
22,
23,
24,
25,



        usingnamespace IntBackedEnumStringify(@This());
        };
const CompletionItemTag = 1;

/// The declaration of a symbol representation as one or many [locations](#Location).
const Declaration = union(enum) {Location: Location,
array: []Location,
};

/// Information about where a symbol is declared.
const DeclarationLink = LocationLink;

/// The definition of a symbol represented as one or many [locations](#Location).
/// For most programming languages there is only one location at which a symbol is
/// defined.
const Definition = union(enum) {Location: Location,
array: []Location,
};

/// Information about where a symbol is defined.
const DefinitionLink = LocationLink;
const DiagnosticSeverity = enum {1,
2,
3,
4,



        usingnamespace IntBackedEnumStringify(@This());
        };
const DiagnosticTag = enum {1,
2,



        usingnamespace IntBackedEnumStringify(@This());
        };
const DocumentHighlightKind = enum {1,
2,
3,



        usingnamespace IntBackedEnumStringify(@This());
        };

/// A tagging type for string properties that are actually document URIs.
const DocumentUri = []const u8;

/// Inline value information can be provided by different means:
/// - directly as a text value (class InlineValueText).
/// - as a name to use for a variable lookup (class InlineValueVariableLookup)
/// - as an evaluatable expression (class InlineValueEvaluatableExpression)
/// The InlineValue types combines all inline value types into one type.
const InlineValue = union(enum) {InlineValueText: InlineValueText,
InlineValueVariableLookup: InlineValueVariableLookup,
InlineValueEvaluatableExpression: InlineValueEvaluatableExpression,
};
const InsertTextFormat = enum {1,
2,



        usingnamespace IntBackedEnumStringify(@This());
        };
const InsertTextMode = enum {1,
2,



        usingnamespace IntBackedEnumStringify(@This());
        };

/// MarkedString can be used to render human readable text. It is either a markdown string
/// or a code-block that provides a language and a code snippet. The language identifier
/// is semantically equal to the optional language identifier in fenced code blocks in GitHub
/// issues. See https://help.github.com/articles/creating-and-highlighting-code-blocks/#syntax-highlighting
const MarkedString = union(enum) {string: []const u8,
};
const MarkupKind = enum {plaintext,
markdown,



        usingnamespace IntBackedEnumStringify(@This());
        };
const SymbolKind = enum {1,
2,
3,
4,
5,
6,
7,
8,
9,
10,
11,
12,
13,
14,
15,
16,
17,
18,
19,
20,
21,
22,
23,
24,
25,
26,



        usingnamespace IntBackedEnumStringify(@This());
        };
const SymbolTag = 1;

/// A tagging type for string properties that are actually URIs
const URI = []const u8;
const EOL = ManuallyTranslateValue;const ColorOptions = DocumentColorOptions;
const ColorProviderOptions = DocumentColorOptions;
const ColorRegistrationOptions = DocumentColorRegistrationOptions;
const FoldingRangeProviderOptions = FoldingRangeOptions;
const SelectionRangeProviderOptions = SelectionRangeOptions;

/// A request sent from the server to the client to modified certain resources.
const ApplyWorkspaceEditRequest = struct {const @"type" = ManuallyTranslateValue;};

/// A request to resolve the incoming calls for a given `CallHierarchyItem`.
const CallHierarchyIncomingCallsRequest = struct {const HandlerSignature = RequestHandler;
const method = "callHierarchy/incomingCalls";const @"type" = ManuallyTranslateValue;};

/// A request to resolve the outgoing calls for a given `CallHierarchyItem`.
const CallHierarchyOutgoingCallsRequest = struct {const HandlerSignature = RequestHandler;
const method = "callHierarchy/outgoingCalls";const @"type" = ManuallyTranslateValue;};

/// A request to result a `CallHierarchyItem` in a document at a given position.
/// Can be used as an input to a incoming or outgoing call hierarchy.
const CallHierarchyPrepareRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/prepareCallHierarchy";const @"type" = ManuallyTranslateValue;};

/// A request to provide commands for the given text document and range.
const CodeActionRequest = struct {const method = "textDocument/codeAction";const @"type" = ManuallyTranslateValue;};

/// Request to resolve additional information for a given code action.The request's
/// parameter is of type [CodeAction](#CodeAction) the response
/// is of type [CodeAction](#CodeAction) or a Thenable that resolves to such.
const CodeActionResolveRequest = struct {const method = "codeAction/resolve";const @"type" = ManuallyTranslateValue;};

/// A request to refresh all code actions
const CodeLensRefreshRequest = struct {const method = ManuallyTranslateValue;const @"type" = ManuallyTranslateValue;};

/// A request to provide code lens for the given text document.
const CodeLensRequest = struct {const method = "textDocument/codeLens";const @"type" = ManuallyTranslateValue;};

/// A request to resolve a command for a given code lens.
const CodeLensResolveRequest = struct {const method = "codeLens/resolve";const @"type" = ManuallyTranslateValue;};

/// A request to list all presentation for a color. The request's
/// parameter is of type [ColorPresentationParams](#ColorPresentationParams) the
/// response is of type [ColorInformation[]](#ColorInformation) or a Thenable
/// that resolves to such.
const ColorPresentationRequest = struct {const HandlerSignature = RequestHandler;
const @"type" = ManuallyTranslateValue;};

/// Request to request completion at a given text document position. The request's
/// parameter is of type [TextDocumentPosition](#TextDocumentPosition) the response
/// is of type [CompletionItem[]](#CompletionItem) or [CompletionList](#CompletionList)
/// or a Thenable that resolves to such.
const CompletionRequest = struct {const method = "textDocument/completion";const @"type" = ManuallyTranslateValue;};

/// Request to resolve additional information for a given completion item.The request's
/// parameter is of type [CompletionItem](#CompletionItem) the response
/// is of type [CompletionItem](#CompletionItem) or a Thenable that resolves to such.
const CompletionResolveRequest = struct {const method = "completionItem/resolve";const @"type" = ManuallyTranslateValue;};

/// How a completion was triggered
const CompletionTriggerKind = enum {Invoked = 1,TriggerCharacter = 2,TriggerForIncompleteCompletions = 3,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// The 'workspace/configuration' request is sent from the server to the client to fetch a certain
/// configuration setting.
const ConfigurationRequest = struct {const HandlerSignature = RequestHandler;
const @"type" = ManuallyTranslateValue;};

/// A request to resolve the type definition locations of a symbol at a given text
/// document position. The request's parameter is of type [TextDocumentPositioParams]
/// (#TextDocumentPositionParams) the response is of type [Declaration](#Declaration)
/// or a typed array of [DeclarationLink](#DeclarationLink) or a Thenable that resolves
/// to such.
const DeclarationRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/declaration";const @"type" = ManuallyTranslateValue;};

/// A request to resolve the definition location of a symbol at a given text
/// document position. The request's parameter is of type [TextDocumentPosition]
/// (#TextDocumentPosition) the response is of either type [Definition](#Definition)
/// or a typed array of [DefinitionLink](#DefinitionLink) or a Thenable that resolves
/// to such.
const DefinitionRequest = struct {const method = "textDocument/definition";const @"type" = ManuallyTranslateValue;};

/// The configuration change notification is sent from the client to the server
/// when the client's configuration has changed. The notification contains
/// the changed configuration as defined by the language client.
const DidChangeConfigurationNotification = struct {const @"type" = ManuallyTranslateValue;};

/// The document change notification is sent from the client to the server to signal
/// changes to a text document.
const DidChangeTextDocumentNotification = struct {const method = "textDocument/didChange";const @"type" = ManuallyTranslateValue;};

/// The watched files notification is sent from the client to the server when
/// the client detects changes to file watched by the language client.
const DidChangeWatchedFilesNotification = struct {const @"type" = ManuallyTranslateValue;};

/// The `workspace/didChangeWorkspaceFolders` notification is sent from the client to the server when the workspace
/// folder configuration changes.
const DidChangeWorkspaceFoldersNotification = struct {const HandlerSignature = NotificationHandler;
const @"type" = ManuallyTranslateValue;};

/// The document close notification is sent from the client to the server when
/// the document got closed in the client. The document's truth now exists where
/// the document's uri points to (e.g. if the document's uri is a file uri the
/// truth now exists on disk). As with the open notification the close notification
/// is about managing the document's content. Receiving a close notification
/// doesn't mean that the document was open in an editor before. A close
/// notification requires a previous open notification to be sent.
const DidCloseTextDocumentNotification = struct {const method = "textDocument/didClose";const @"type" = ManuallyTranslateValue;};

/// The did create files notification is sent from the client to the server when
/// files were created from within the client.
const DidCreateFilesNotification = struct {const HandlerSignature = NotificationHandler;
const method = "workspace/didCreateFiles";const @"type" = ManuallyTranslateValue;};

/// The will delete files request is sent from the client to the server before files are actually
/// deleted as long as the deletion is triggered from within the client.
const DidDeleteFilesNotification = struct {const HandlerSignature = NotificationHandler;
const method = "workspace/didDeleteFiles";const @"type" = ManuallyTranslateValue;};

/// The document open notification is sent from the client to the server to signal
/// newly opened text documents. The document's truth is now managed by the client
/// and the server must not try to read the document's truth using the document's
/// uri. Open in this sense means it is managed by the client. It doesn't necessarily
/// mean that its content is presented in an editor. An open notification must not
/// be sent more than once without a corresponding close notification send before.
/// This means open and close notification must be balanced and the max open count
/// is one.
const DidOpenTextDocumentNotification = struct {const method = "textDocument/didOpen";const @"type" = ManuallyTranslateValue;};

/// The did rename files notification is sent from the client to the server when
/// files were renamed from within the client.
const DidRenameFilesNotification = struct {const HandlerSignature = NotificationHandler;
const method = "workspace/didRenameFiles";const @"type" = ManuallyTranslateValue;};

/// The document save notification is sent from the client to the server when
/// the document got saved in the client.
const DidSaveTextDocumentNotification = struct {const method = "textDocument/didSave";const @"type" = ManuallyTranslateValue;};

/// A request to list all color symbols found in a given text document. The request's
/// parameter is of type [DocumentColorParams](#DocumentColorParams) the
/// response is of type [ColorInformation[]](#ColorInformation) or a Thenable
/// that resolves to such.
const DocumentColorRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/documentColor";const @"type" = ManuallyTranslateValue;};

/// A request to to format a whole document.
const DocumentFormattingRequest = struct {const method = "textDocument/formatting";const @"type" = ManuallyTranslateValue;};

/// Request to resolve a [DocumentHighlight](#DocumentHighlight) for a given
/// text document position. The request's parameter is of type [TextDocumentPosition]
/// (#TextDocumentPosition) the request response is of type [DocumentHighlight[]]
/// (#DocumentHighlight) or a Thenable that resolves to such.
const DocumentHighlightRequest = struct {const method = "textDocument/documentHighlight";const @"type" = ManuallyTranslateValue;};

/// A request to provide document links
const DocumentLinkRequest = struct {const method = "textDocument/documentLink";const @"type" = ManuallyTranslateValue;};

/// Request to resolve additional information for a given document link. The request's
/// parameter is of type [DocumentLink](#DocumentLink) the response
/// is of type [DocumentLink](#DocumentLink) or a Thenable that resolves to such.
const DocumentLinkResolveRequest = struct {const method = "documentLink/resolve";const @"type" = ManuallyTranslateValue;};

/// A request to format a document on type.
const DocumentOnTypeFormattingRequest = struct {const method = "textDocument/onTypeFormatting";const @"type" = ManuallyTranslateValue;};

/// A request to to format a range in a document.
const DocumentRangeFormattingRequest = struct {const method = "textDocument/rangeFormatting";const @"type" = ManuallyTranslateValue;};

/// A request to list all symbols found in a given text document. The request's
/// parameter is of type [TextDocumentIdentifier](#TextDocumentIdentifier) the
/// response is of type [SymbolInformation[]](#SymbolInformation) or a Thenable
/// that resolves to such.
const DocumentSymbolRequest = struct {const method = "textDocument/documentSymbol";const @"type" = ManuallyTranslateValue;};

/// A request send from the client to the server to execute a command. The request might return
/// a workspace edit which the client will apply to the workspace.
const ExecuteCommandRequest = struct {const @"type" = ManuallyTranslateValue;};

/// The exit event is sent from the client to the server to
/// ask the server to exit its process.
const ExitNotification = struct {const @"type" = ManuallyTranslateValue;};
const FailureHandlingKind = struct {
/// Applying the workspace change is simply aborted if one of the changes provided
/// fails. All operations executed before the failing operation stay executed.
const Abort = "abort";
/// If the workspace edit contains only textual file changes they are executed transactional.
/// If resource changes (create, rename or delete file) are part of the change the failure
/// handling strategy is abort.
const TextOnlyTransactional = "textOnlyTransactional";
/// All operations are executed transactional. That means they either all
/// succeed or no changes at all are applied to the workspace.
const Transactional = "transactional";
/// The client tries to undo the operations already executed. But there is no
/// guarantee that this is succeeding.
const Undo = "undo";};

/// The file event type
const FileChangeType = enum {Changed = 2,Created = 1,Deleted = 3,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// A pattern kind describing if a glob pattern matches a file a folder or
/// both.
const FileOperationPatternKind = struct {
/// The pattern matches a file only.
const file = "file";
/// The pattern matches a folder only.
const folder = "folder";};

/// A request to provide folding ranges in a document. The request's
/// parameter is of type [FoldingRangeParams](#FoldingRangeParams), the
/// response is of type [FoldingRangeList](#FoldingRangeList) or a Thenable
/// that resolves to such.
const FoldingRangeRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/foldingRange";const @"type" = ManuallyTranslateValue;};

/// Request to request hover information at a given text document position. The request's
/// parameter is of type [TextDocumentPosition](#TextDocumentPosition) the response is of
/// type [Hover](#Hover) or a Thenable that resolves to such.
const HoverRequest = struct {const method = "textDocument/hover";const @"type" = ManuallyTranslateValue;};

/// A request to resolve the implementation locations of a symbol at a given text
/// document position. The request's parameter is of type [TextDocumentPositioParams]
/// (#TextDocumentPositionParams) the response is of type [Definition](#Definition) or a
/// Thenable that resolves to such.
const ImplementationRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/implementation";const @"type" = ManuallyTranslateValue;};

/// Known error codes for an `InitializeError`;
const InitializeError = enum {unknownProtocolVersion = 1,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// The initialize request is sent from the client to the server.
/// It is sent once as the request after starting up the server.
/// The requests parameter is of type [InitializeParams](#InitializeParams)
/// the response if of type [InitializeResult](#InitializeResult) of a Thenable that
/// resolves to such.
const InitializeRequest = struct {const @"type" = ManuallyTranslateValue;};

/// The initialized notification is sent from the client to the
/// server after the client is fully initialized and the server
/// is allowed to send requests from the server to the client.
const InitializedNotification = struct {const @"type" = ManuallyTranslateValue;};

/// A request to provide ranges that can be edited together.
const LinkedEditingRangeRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/linkedEditingRange";const @"type" = ManuallyTranslateValue;};

/// The log message notification is sent from the server to the client to ask
/// the client to log a particular message.
const LogMessageNotification = struct {const @"type" = ManuallyTranslateValue;};

/// The message type
const MessageType = enum {Error = 1,Info = 3,Log = 4,Warning = 2,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// A request to get the moniker of a symbol at a given text document position.
/// The request parameter is of type [TextDocumentPositionParams](#TextDocumentPositionParams).
/// The response is of type [Moniker[]](#Moniker[]) or `null`.
const MonikerRequest = struct {const method = "textDocument/moniker";const @"type" = ManuallyTranslateValue;};

/// A request to test and perform the setup necessary for a rename.
const PrepareRenameRequest = struct {const method = "textDocument/prepareRename";const @"type" = ManuallyTranslateValue;};
const PrepareSupportDefaultBehavior = enum {Identifier = 1,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// Diagnostics notification are sent from the server to the client to signal
/// results of validation runs.
const PublishDiagnosticsNotification = struct {const @"type" = ManuallyTranslateValue;};

/// A request to resolve project-wide references for the symbol denoted
/// by the given text document position. The request's parameter is of
/// type [ReferenceParams](#ReferenceParams) the response is of type
/// [Location[]](#Location) or a Thenable that resolves to such.
const ReferencesRequest = struct {const method = "textDocument/references";const @"type" = ManuallyTranslateValue;};

/// The `client/registerCapability` request is sent from the server to the client to register a new capability
/// handler on the client side.
const RegistrationRequest = struct {const @"type" = ManuallyTranslateValue;};

/// A request to rename a symbol.
const RenameRequest = struct {const method = "textDocument/rename";const @"type" = ManuallyTranslateValue;};
const ResourceOperationKind = struct {
/// Supports creating new files and folders.
const Create = "create";
/// Supports deleting existing files and folders.
const Delete = "delete";
/// Supports renaming existing files and folders.
const Rename = "rename";};

/// A request to provide selection ranges in a document. The request's
/// parameter is of type [SelectionRangeParams](#SelectionRangeParams), the
/// response is of type [SelectionRange[]](#SelectionRange[]) or a Thenable
/// that resolves to such.
const SelectionRangeRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/selectionRange";const @"type" = ManuallyTranslateValue;};
const SemanticTokensDeltaRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/semanticTokens/full/delta";const @"type" = ManuallyTranslateValue;};
const SemanticTokensRangeRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/semanticTokens/range";const @"type" = ManuallyTranslateValue;};
const SemanticTokensRefreshRequest = struct {const HandlerSignature = RequestHandler0;
const method = ManuallyTranslateValue;const @"type" = ManuallyTranslateValue;};
const SemanticTokensRegistrationType = struct {const method = "textDocument/semanticTokens";const @"type" = ManuallyTranslateValue;};
const SemanticTokensRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/semanticTokens/full";const @"type" = ManuallyTranslateValue;};

/// A request to show a document. This request might open an
/// external program depending on the value of the URI to open.
/// For example a request to open `https://code.visualstudio.com/`
/// will very likely open the URI in a WEB browser.
const ShowDocumentRequest = struct {const HandlerSignature = RequestHandler;
const method = "window/showDocument";const @"type" = ManuallyTranslateValue;};

/// The show message notification is sent from a server to a client to ask
/// the client to display a particular message in the user interface.
const ShowMessageNotification = struct {const @"type" = ManuallyTranslateValue;};

/// The show message request is sent from the server to the client to show a message
/// and a set of options actions to the user.
const ShowMessageRequest = struct {const @"type" = ManuallyTranslateValue;};

/// A shutdown request is sent from the client to the server.
/// It is sent once when the client decides to shutdown the
/// server. The only notification that is sent after a shutdown request
/// is the exit event.
const ShutdownRequest = struct {const @"type" = ManuallyTranslateValue;};
const SignatureHelpRequest = struct {const method = "textDocument/signatureHelp";const @"type" = ManuallyTranslateValue;};

/// How a signature help was triggered.
const SignatureHelpTriggerKind = enum {ContentChange = 3,Invoked = 1,TriggerCharacter = 2,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// The telemetry event notification is sent from the server to the client to ask
/// the client to log telemetry data.
const TelemetryEventNotification = struct {const @"type" = ManuallyTranslateValue;};

/// Represents reasons why a text document is saved.
const TextDocumentSaveReason = enum {AfterDelay = 2,FocusOut = 3,Manual = 1,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// Defines how the host (editor) should sync
/// document changes to the language server.
const TextDocumentSyncKind = enum {Full = 1,Incremental = 2,None = 0,


        usingnamespace IntBackedEnumStringify(@This());
        };
const TokenFormat = struct {const Relative = "relative";};

/// A request to resolve the type definition locations of a symbol at a given text
/// document position. The request's parameter is of type [TextDocumentPositioParams]
/// (#TextDocumentPositionParams) the response is of type [Definition](#Definition) or a
/// Thenable that resolves to such.
const TypeDefinitionRequest = struct {const HandlerSignature = RequestHandler;
const method = "textDocument/typeDefinition";const @"type" = ManuallyTranslateValue;};

/// The `client/unregisterCapability` request is sent from the server to the client to unregister a previously registered capability
/// handler on the client side.
const UnregistrationRequest = struct {const @"type" = ManuallyTranslateValue;};
const WatchKind = enum {Change = 2,Create = 1,Delete = 4,


        usingnamespace IntBackedEnumStringify(@This());
        };

/// The will create files request is sent from the client to the server before files are actually
/// created as long as the creation is triggered from within the client.
const WillCreateFilesRequest = struct {const HandlerSignature = RequestHandler;
const method = "workspace/willCreateFiles";const @"type" = ManuallyTranslateValue;};

/// The did delete files notification is sent from the client to the server when
/// files were deleted from within the client.
const WillDeleteFilesRequest = struct {const HandlerSignature = RequestHandler;
const method = "workspace/willDeleteFiles";const @"type" = ManuallyTranslateValue;};

/// The will rename files request is sent from the client to the server before files are actually
/// renamed as long as the rename is triggered from within the client.
const WillRenameFilesRequest = struct {const HandlerSignature = RequestHandler;
const method = "workspace/willRenameFiles";const @"type" = ManuallyTranslateValue;};

/// A document will save notification is sent from the client to the server before
/// the document is actually saved.
const WillSaveTextDocumentNotification = struct {const method = "textDocument/willSave";const @"type" = ManuallyTranslateValue;};

/// A document will save request is sent from the client to the server before
/// the document is actually saved. The request can return an array of TextEdits
/// which will be applied to the text document before it is saved. Please note that
/// clients might drop results if computing the text edits took too long or if a
/// server constantly fails on this request. This is done to keep the save fast and
/// reliable.
const WillSaveTextDocumentWaitUntilRequest = struct {const method = "textDocument/willSaveWaitUntil";const @"type" = ManuallyTranslateValue;};

/// The `window/workDoneProgress/cancel` notification is sent from  the client to the server to cancel a progress
/// initiated on the server side.
const WorkDoneProgressCancelNotification = struct {const HandlerSignature = NotificationHandler;
const @"type" = ManuallyTranslateValue;};

/// The `window/workDoneProgress/create` request is sent from the server to the client to initiate progress
/// reporting from the server.
const WorkDoneProgressCreateRequest = struct {const HandlerSignature = RequestHandler;
const @"type" = ManuallyTranslateValue;};

/// The `workspace/workspaceFolders` is sent from the server to the client to fetch the open workspace folders.
const WorkspaceFoldersRequest = struct {const HandlerSignature = RequestHandler0;
const @"type" = ManuallyTranslateValue;};

/// A request to list project-wide symbols matching the query string given
/// by the [WorkspaceSymbolParams](#WorkspaceSymbolParams). The response is
/// of type [SymbolInformation[]](#SymbolInformation) or a Thenable that
/// resolves to such.
const WorkspaceSymbolRequest = struct {const method = "workspace/symbol";const @"type" = ManuallyTranslateValue;};

/// A request to resolve the range inside the workspace
/// symbol's location.
const WorkspaceSymbolResolveRequest = struct {const method = "workspaceSymbol/resolve";const @"type" = ManuallyTranslateValue;};

/// The moniker kind.
const MonikerKind = struct {const @"export" = "export";const @"import" = "import";const local = "local";};
/// Moniker uniqueness level to define scope of the moniker.
const UniquenessLevel = struct {const document = "document";const global = "global";const group = "group";const project = "project";const scheme = "scheme";};
/// The parameters passed via a apply workspace edit request.
const ApplyWorkspaceEditParams = struct {
/// The edits to apply.
edit: WorkspaceEdit,

/// An optional label of the workspace edit. This label is
/// presented in the user interface for example on an undo
/// stack to undo the workspace edit.
label: []const u8,
};

/// The result returned from the apply workspace edit request.
const ApplyWorkspaceEditResult = struct {
/// Indicates whether the edit was applied or not.
applied: bool,

/// Depending on the client's failure handling strategy `failedChange` might
/// contain the index of the change that failed. This property is only available
/// if the client signals a `failureHandlingStrategy` in its client capabilities.
failedChange: i64,

/// An optional textual description for why the edit was not applied.
/// This may be used by the server for diagnostic logging or to provide
/// a suitable error for a request that triggered the edit.
failureReason: []const u8,
};
const CallHierarchyClientCapabilities = struct {
/// Whether implementation supports dynamic registration. If this is set to `true`
/// the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
/// return value for the corresponding server capability as well.
dynamicRegistration: bool,
};

/// The parameter of a `callHierarchy/incomingCalls` request.
const CallHierarchyIncomingCallsParams = struct {item: CallHierarchyItem,

/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Call hierarchy options used during static registration.
const CallHierarchyOptions = struct {workDoneProgress: bool,
};

/// The parameter of a `callHierarchy/outgoingCalls` request.
const CallHierarchyOutgoingCallsParams = struct {item: CallHierarchyItem,

/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// The parameter of a `textDocument/prepareCallHierarchy` request.
const CallHierarchyPrepareParams = struct {
/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Call hierarchy options used during static or dynamic registration.
const CallHierarchyRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,
workDoneProgress: bool,
};

/// The Client Capabilities of a [CodeActionRequest](#CodeActionRequest).
const CodeActionClientCapabilities = struct {
/// Whether code action supports the `data` property which is
/// preserved between a `textDocument/codeAction` and a
/// `codeAction/resolve` request.
dataSupport: bool,

/// Whether code action supports the `disabled` property.
disabledSupport: bool,

/// Whether code action supports dynamic registration.
dynamicRegistration: bool,

/// Whether th client honors the change annotations in
/// text edits and resource operations returned via the
/// `CodeAction#edit` property by for example presenting
/// the workspace edit in the user interface and asking
/// for confirmation.
honorsChangeAnnotations: bool,

/// Whether code action supports the `isPreferred` property.
isPreferredSupport: bool,
};

/// Provider options for a [CodeActionRequest](#CodeActionRequest).
const CodeActionOptions = struct {
/// CodeActionKinds that this server may return.
codeActionKinds: [][]const u8,

/// The server provides support to resolve additional
/// information for a code action.
resolveProvider: bool,
workDoneProgress: bool,
};

/// The parameters of a [CodeActionRequest](#CodeActionRequest).
const CodeActionParams = struct {
/// Context carrying additional information.
context: CodeActionContext,

/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The range for which the command was invoked.
range: Range,

/// The document in which the command was invoked.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [CodeActionRequest](#CodeActionRequest).
const CodeActionRegistrationOptions = struct {
/// CodeActionKinds that this server may return.
codeActionKinds: [][]const u8,

/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The server provides support to resolve additional
/// information for a code action.
resolveProvider: bool,
workDoneProgress: bool,
};

/// The client capabilities  of a [CodeLensRequest](#CodeLensRequest).
const CodeLensClientCapabilities = struct {
/// Whether code lens supports dynamic registration.
dynamicRegistration: bool,
};

/// Code Lens provider options of a [CodeLensRequest](#CodeLensRequest).
const CodeLensOptions = struct {
/// Code lens has a resolve provider as well.
resolveProvider: bool,
workDoneProgress: bool,
};

/// The parameters of a [CodeLensRequest](#CodeLensRequest).
const CodeLensParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The document to request code lens for.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [CodeLensRequest](#CodeLensRequest).
const CodeLensRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// Code lens has a resolve provider as well.
resolveProvider: bool,
workDoneProgress: bool,
};
const CodeLensWorkspaceClientCapabilities = struct {
/// Whether the client implementation supports a refresh request sent from the
/// server to the client.
refreshSupport: bool,
};

/// Parameters for a [ColorPresentationRequest](#ColorPresentationRequest).
const ColorPresentationParams = struct {
/// The color to request presentations for.
color: Color,

/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The range where the color would be inserted. Serves as a context.
range: Range,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Completion client capabilities
const CompletionClientCapabilities = struct {
/// The client supports to send additional context information for a
/// `textDocument/completion` request.
contextSupport: bool,

/// Whether completion supports dynamic registration.
dynamicRegistration: bool,

/// Defines how the client handles whitespace and indentation
/// when accepting a completion item that uses multi line
/// text in either `insertText` or `textEdit`.
insertTextMode: InsertTextMode,
};

/// Contains additional information about the context in which a completion request is triggered.
const CompletionContext = struct {
/// The trigger character (a single character) that has trigger code complete.
/// Is undefined if `triggerKind !== CompletionTriggerKind.TriggerCharacter`
triggerCharacter: []const u8,

/// How the completion was triggered.
triggerKind: CompletionTriggerKind,
};

/// Completion options.
const CompletionOptions = struct {
/// The list of all possible characters that commit a completion. This field can be used
/// if clients don't support individual commit characters per completion item. See
/// `ClientCapabilities.textDocument.completion.completionItem.commitCharactersSupport`
allCommitCharacters: [][]const u8,

/// The server provides support to resolve additional
/// information for a completion item.
resolveProvider: bool,

/// Most tools trigger completion request automatically without explicitly requesting
/// it using a keyboard shortcut (e.g. Ctrl+Space). Typically they do so when the user
/// starts to type an identifier. For example if the user types `c` in a JavaScript file
/// code complete will automatically pop up present `console` besides others as a
/// completion item. Characters that make up identifiers don't need to be listed here.
triggerCharacters: [][]const u8,
workDoneProgress: bool,
};

/// Completion parameters
const CompletionParams = struct {
/// The completion context. This is only available it the client specifies
/// to send this using the client capability `textDocument.completion.contextSupport === true`
context: CompletionContext,

/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [CompletionRequest](#CompletionRequest).
const CompletionRegistrationOptions = struct {
/// The list of all possible characters that commit a completion. This field can be used
/// if clients don't support individual commit characters per completion item. See
/// `ClientCapabilities.textDocument.completion.completionItem.commitCharactersSupport`
allCommitCharacters: [][]const u8,

/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The server provides support to resolve additional
/// information for a completion item.
resolveProvider: bool,

/// Most tools trigger completion request automatically without explicitly requesting
/// it using a keyboard shortcut (e.g. Ctrl+Space). Typically they do so when the user
/// starts to type an identifier. For example if the user types `c` in a JavaScript file
/// code complete will automatically pop up present `console` besides others as a
/// completion item. Characters that make up identifiers don't need to be listed here.
triggerCharacters: [][]const u8,
workDoneProgress: bool,
};
const ConfigurationItem = struct {
/// The scope to get the configuration section for.
scopeUri: []const u8,

/// The configuration section asked for.
section: []const u8,
};

/// The parameters of a configuration request.
const ConfigurationParams = struct {items: []ConfigurationItem,
};

/// The parameters sent in file create requests/notifications.
const CreateFilesParams = struct {
/// An array of all files/folders created in this operation.
files: []FileCreate,
};
const DeclarationClientCapabilities = struct {
/// Whether declaration supports dynamic registration. If this is set to `true`
/// the client supports the new `DeclarationRegistrationOptions` return value
/// for the corresponding server capability as well.
dynamicRegistration: bool,

/// The client supports additional metadata in the form of declaration links.
linkSupport: bool,
};
const DeclarationOptions = struct {workDoneProgress: bool,
};
const DeclarationParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const DeclarationRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,
workDoneProgress: bool,
};

/// Client Capabilities for a [DefinitionRequest](#DefinitionRequest).
const DefinitionClientCapabilities = struct {
/// Whether definition supports dynamic registration.
dynamicRegistration: bool,

/// The client supports additional metadata in the form of definition links.
linkSupport: bool,
};

/// Server Capabilities for a [DefinitionRequest](#DefinitionRequest).
const DefinitionOptions = struct {workDoneProgress: bool,
};

/// Parameters for a [DefinitionRequest](#DefinitionRequest).
const DefinitionParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [DefinitionRequest](#DefinitionRequest).
const DefinitionRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,
workDoneProgress: bool,
};

/// The parameters sent in file delete requests/notifications.
const DeleteFilesParams = struct {
/// An array of all files/folders deleted in this operation.
files: []FileDelete,
};
const DidChangeConfigurationClientCapabilities = struct {
/// Did change configuration notification supports dynamic registration.
dynamicRegistration: bool,
};

/// The parameters of a change configuration notification.
const DidChangeConfigurationParams = struct {
/// The actual changed settings
settings: LSPAny,
};
const DidChangeConfigurationRegistrationOptions = struct {section: union(enum) {string: []const u8,
array: [][]const u8,
},
};

/// The change text document notification's parameters.
const DidChangeTextDocumentParams = struct {
/// The actual content changes. The content changes describe single state changes
/// to the document. So if there are two content changes c1 (at array index 0) and
/// c2 (at array index 1) for a document in state S then c1 moves the document from
/// S to S' and c2 from S' to S''. So c1 is computed on the state S and c2 is computed
/// on the state S'.
contentChanges: []TextDocumentContentChangeEvent,

/// The document that did change. The version number points
/// to the version after all provided content changes have
/// been applied.
textDocument: VersionedTextDocumentIdentifier,
};
const DidChangeWatchedFilesClientCapabilities = struct {
/// Did change watched files notification supports dynamic registration. Please note
/// that the current protocol doesn't support static configuration for file changes
/// from the server side.
dynamicRegistration: bool,
};

/// The watched files change notification's parameters.
const DidChangeWatchedFilesParams = struct {
/// The actual file events.
changes: []FileEvent,
};

/// Describe options to be used when registered for text document change events.
const DidChangeWatchedFilesRegistrationOptions = struct {
/// The watchers to register.
watchers: []FileSystemWatcher,
};

/// The parameters of a `workspace/didChangeWorkspaceFolders` notification.
const DidChangeWorkspaceFoldersParams = struct {
/// The actual workspace folder change event.
event: WorkspaceFoldersChangeEvent,
};

/// The parameters send in a close text document notification
const DidCloseTextDocumentParams = struct {
/// The document that was closed.
textDocument: TextDocumentIdentifier,
};

/// The parameters send in a open text document notification
const DidOpenTextDocumentParams = struct {
/// The document that was opened.
textDocument: TextDocumentItem,
};

/// The parameters send in a save text document notification
const DidSaveTextDocumentParams = struct {
/// Optional the content when saved. Depends on the includeText value
/// when the save notification was requested.
text: []const u8,

/// The document that was closed.
textDocument: TextDocumentIdentifier,
};
const DocumentColorOptions = struct {workDoneProgress: bool,
};

/// Parameters for a [DocumentColorRequest](#DocumentColorRequest).
const DocumentColorParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const DocumentColorRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,
workDoneProgress: bool,
};

/// Client capabilities of a [DocumentFormattingRequest](#DocumentFormattingRequest).
const DocumentFormattingClientCapabilities = struct {
/// Whether formatting supports dynamic registration.
dynamicRegistration: bool,
};

/// Provider options for a [DocumentFormattingRequest](#DocumentFormattingRequest).
const DocumentFormattingOptions = struct {workDoneProgress: bool,
};

/// The parameters of a [DocumentFormattingRequest](#DocumentFormattingRequest).
const DocumentFormattingParams = struct {
/// The format options
options: FormattingOptions,

/// The document to format.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [DocumentFormattingRequest](#DocumentFormattingRequest).
const DocumentFormattingRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,
workDoneProgress: bool,
};

/// Client Capabilities for a [DocumentHighlightRequest](#DocumentHighlightRequest).
const DocumentHighlightClientCapabilities = struct {
/// Whether document highlight supports dynamic registration.
dynamicRegistration: bool,
};

/// Provider options for a [DocumentHighlightRequest](#DocumentHighlightRequest).
const DocumentHighlightOptions = struct {workDoneProgress: bool,
};

/// Parameters for a [DocumentHighlightRequest](#DocumentHighlightRequest).
const DocumentHighlightParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [DocumentHighlightRequest](#DocumentHighlightRequest).
const DocumentHighlightRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,
workDoneProgress: bool,
};

/// The client capabilities of a [DocumentLinkRequest](#DocumentLinkRequest).
const DocumentLinkClientCapabilities = struct {
/// Whether document link supports dynamic registration.
dynamicRegistration: bool,

/// Whether the client support the `tooltip` property on `DocumentLink`.
tooltipSupport: bool,
};

/// Provider options for a [DocumentLinkRequest](#DocumentLinkRequest).
const DocumentLinkOptions = struct {
/// Document links have a resolve provider as well.
resolveProvider: bool,
workDoneProgress: bool,
};

/// The parameters of a [DocumentLinkRequest](#DocumentLinkRequest).
const DocumentLinkParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The document to provide document links for.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [DocumentLinkRequest](#DocumentLinkRequest).
const DocumentLinkRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// Document links have a resolve provider as well.
resolveProvider: bool,
workDoneProgress: bool,
};

/// Client capabilities of a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
const DocumentOnTypeFormattingClientCapabilities = struct {
/// Whether on type formatting supports dynamic registration.
dynamicRegistration: bool,
};

/// Provider options for a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
const DocumentOnTypeFormattingOptions = struct {
/// A character on which formatting should be triggered, like `}`.
firstTriggerCharacter: []const u8,

/// More trigger characters.
moreTriggerCharacter: [][]const u8,
};

/// The parameters of a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
const DocumentOnTypeFormattingParams = struct {
/// The character that has been typed.
ch: []const u8,

/// The format options.
options: FormattingOptions,

/// The position at which this request was send.
position: Position,

/// The document to format.
textDocument: TextDocumentIdentifier,
};

/// Registration options for a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
const DocumentOnTypeFormattingRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// A character on which formatting should be triggered, like `}`.
firstTriggerCharacter: []const u8,

/// More trigger characters.
moreTriggerCharacter: [][]const u8,
};

/// Client capabilities of a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
const DocumentRangeFormattingClientCapabilities = struct {
/// Whether range formatting supports dynamic registration.
dynamicRegistration: bool,
};

/// Provider options for a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
const DocumentRangeFormattingOptions = struct {workDoneProgress: bool,
};

/// The parameters of a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
const DocumentRangeFormattingParams = struct {
/// The format options
options: FormattingOptions,

/// The range to format
range: Range,

/// The document to format.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
const DocumentRangeFormattingRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,
workDoneProgress: bool,
};

/// Client Capabilities for a [DocumentSymbolRequest](#DocumentSymbolRequest).
const DocumentSymbolClientCapabilities = struct {
/// Whether document symbol supports dynamic registration.
dynamicRegistration: bool,

/// The client support hierarchical document symbols.
hierarchicalDocumentSymbolSupport: bool,

/// The client supports an additional label presented in the UI when
/// registering a document symbol provider.
labelSupport: bool,
};

/// Provider options for a [DocumentSymbolRequest](#DocumentSymbolRequest).
const DocumentSymbolOptions = struct {
/// A human-readable string that is shown when multiple outlines trees
/// are shown for the same document.
label: []const u8,
workDoneProgress: bool,
};

/// Parameters for a [DocumentSymbolRequest](#DocumentSymbolRequest).
const DocumentSymbolParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [DocumentSymbolRequest](#DocumentSymbolRequest).
const DocumentSymbolRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// A human-readable string that is shown when multiple outlines trees
/// are shown for the same document.
label: []const u8,
workDoneProgress: bool,
};

/// The client capabilities of a [ExecuteCommandRequest](#ExecuteCommandRequest).
const ExecuteCommandClientCapabilities = struct {
/// Execute command supports dynamic registration.
dynamicRegistration: bool,
};

/// The server capabilities of a [ExecuteCommandRequest](#ExecuteCommandRequest).
const ExecuteCommandOptions = struct {
/// The commands to be executed on the server
commands: [][]const u8,
workDoneProgress: bool,
};

/// The parameters of a [ExecuteCommandRequest](#ExecuteCommandRequest).
const ExecuteCommandParams = struct {
/// Arguments that the command should be invoked with.
arguments: []LSPAny,

/// The identifier of the actual command handler.
command: []const u8,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [ExecuteCommandRequest](#ExecuteCommandRequest).
const ExecuteCommandRegistrationOptions = struct {
/// The commands to be executed on the server
commands: [][]const u8,
workDoneProgress: bool,
};

/// Represents information on a file/folder create.
const FileCreate = struct {
/// A file:// URI for the location of the file/folder being created.
uri: []const u8,
};

/// Represents information on a file/folder delete.
const FileDelete = struct {
/// A file:// URI for the location of the file/folder being deleted.
uri: []const u8,
};

/// An event describing a file change.
const FileEvent = struct {
/// The change type.
@"type": FileChangeType,

/// The file's uri.
uri: []const u8,
};

/// Capabilities relating to events from file operations by the user in the client.
const FileOperationClientCapabilities = struct {
/// The client has support for sending didCreateFiles notifications.
didCreate: bool,

/// The client has support for sending didDeleteFiles notifications.
didDelete: bool,

/// The client has support for sending didRenameFiles notifications.
didRename: bool,

/// Whether the client supports dynamic registration for file requests/notifications.
dynamicRegistration: bool,

/// The client has support for willCreateFiles requests.
willCreate: bool,

/// The client has support for willDeleteFiles requests.
willDelete: bool,

/// The client has support for willRenameFiles requests.
willRename: bool,
};

/// Options for notifications/requests for user operations on files.
const FileOperationOptions = struct {
/// The server is interested in didCreateFiles notifications.
didCreate: FileOperationRegistrationOptions,

/// The server is interested in didDeleteFiles file notifications.
didDelete: FileOperationRegistrationOptions,

/// The server is interested in didRenameFiles notifications.
didRename: FileOperationRegistrationOptions,

/// The server is interested in willCreateFiles requests.
willCreate: FileOperationRegistrationOptions,

/// The server is interested in willDeleteFiles file requests.
willDelete: FileOperationRegistrationOptions,

/// The server is interested in willRenameFiles requests.
willRename: FileOperationRegistrationOptions,
};

/// Matching options for the file operation pattern.
const FileOperationPatternOptions = struct {
/// The pattern should be matched ignoring casing.
ignoreCase: bool,
};

/// The options to register for file operations.
const FileOperationRegistrationOptions = struct {
/// The actual filters.
filters: []FileOperationFilter,
};

/// Represents information on a file/folder rename.
const FileRename = struct {
/// A file:// URI for the new location of the file/folder being renamed.
newUri: []const u8,

/// A file:// URI for the original location of the file/folder being renamed.
oldUri: []const u8,
};
const FileSystemWatcher = struct {
/// The  glob pattern to watch. Glob patterns can have the following syntax:
/// - `*` to match one or more characters in a path segment
/// - `?` to match on one character in a path segment
/// - `**` to match any number of path segments, including none
/// - `{}` to group conditions (e.g. `**​/*.{ts,js}` matches all TypeScript and JavaScript files)
/// - `[]` to declare a range of characters to match in a path segment (e.g., `example.[0-9]` to match on `example.0`, `example.1`, …)
/// - `[!...]` to negate a range of characters to match in a path segment (e.g., `example.[!0-9]` to match on `example.a`, `example.b`, but not `example.0`)
globPattern: []const u8,

/// The kind of events of interest. If omitted it defaults
/// to WatchKind.Create | WatchKind.Change | WatchKind.Delete
/// which is 7.
kind: i64,
};
const FoldingRangeClientCapabilities = struct {
/// Whether implementation supports dynamic registration for folding range providers. If this is set to `true`
/// the client supports the new `FoldingRangeRegistrationOptions` return value for the corresponding server
/// capability as well.
dynamicRegistration: bool,

/// If set, the client signals that it only supports folding complete lines. If set, client will
/// ignore specified `startCharacter` and `endCharacter` properties in a FoldingRange.
lineFoldingOnly: bool,

/// The maximum number of folding ranges that the client prefers to receive per document. The value serves as a
/// hint, servers are free to follow the limit.
rangeLimit: i64,
};
const FoldingRangeOptions = struct {workDoneProgress: bool,
};

/// Parameters for a [FoldingRangeRequest](#FoldingRangeRequest).
const FoldingRangeParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const FoldingRangeRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,
workDoneProgress: bool,
};

/// General client capabilities.
const GeneralClientCapabilities = struct {
/// Client capabilities specific to the client's markdown parser.
markdown: MarkdownClientCapabilities,

/// Client capabilities specific to regular expressions.
regularExpressions: RegularExpressionsClientCapabilities,
};
const HoverClientCapabilities = struct {
/// Client supports the follow content formats for the content
/// property. The order describes the preferred format of the client.
contentFormat: []MarkupKind,

/// Whether hover supports dynamic registration.
dynamicRegistration: bool,
};

/// Hover options.
const HoverOptions = struct {workDoneProgress: bool,
};

/// Parameters for a [HoverRequest](#HoverRequest).
const HoverParams = struct {
/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [HoverRequest](#HoverRequest).
const HoverRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,
workDoneProgress: bool,
};
const ImplementationOptions = struct {workDoneProgress: bool,
};
const ImplementationParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const ImplementationRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,
workDoneProgress: bool,
};

/// The data type of the ResponseError if the
/// initialize request fails.
const InitializeError = struct {
/// Indicates whether the client execute the following retry logic:
/// (1) show the message provided by the ResponseError to the user
/// (2) user selects retry or cancel
/// (3) if user selected retry the initialize method is sent again.
retry: bool,
};

/// The result returned from an initialize request.
const InitializeResult = struct {
/// The capabilities the language server provides.
capabilities: ServerCapabilities,
};
const InitializedParams = struct {};

/// Client capabilities for the linked editing range request.
const LinkedEditingRangeClientCapabilities = struct {
/// Whether implementation supports dynamic registration. If this is set to `true`
/// the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
/// return value for the corresponding server capability as well.
dynamicRegistration: bool,
};
const LinkedEditingRangeOptions = struct {workDoneProgress: bool,
};
const LinkedEditingRangeParams = struct {
/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const LinkedEditingRangeRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,
workDoneProgress: bool,
};

/// The result of a linked editing range request.
const LinkedEditingRanges = struct {
/// A list of ranges that can be edited together. The ranges must have
/// identical length and contain identical text content. The ranges cannot overlap.
ranges: []Range,

/// An optional word pattern (regular expression) that describes valid contents for
/// the given ranges. If no pattern is provided, the client configuration's word
/// pattern will be used.
wordPattern: []const u8,
};

/// The log message parameters.
const LogMessageParams = struct {
/// The actual message
message: []const u8,

/// The message type. See {@link MessageType}
@"type": MessageType,
};

/// Client capabilities specific to the used markdown parser.
const MarkdownClientCapabilities = struct {
/// A list of HTML tags that the client allows / supports in
/// Markdown.
allowedTags: [][]const u8,

/// The name of the parser.
parser: []const u8,

/// The version of the parser.
version: []const u8,
};
const MessageActionItem = struct {
/// A short title like 'Retry', 'Open Log' etc.
title: []const u8,
};

/// Moniker definition to match LSIF 0.5 moniker definition.
const Moniker = struct {
/// The identifier of the moniker. The value is opaque in LSIF however
/// schema owners are allowed to define the structure if they want.
identifier: []const u8,

/// The moniker kind if known.
kind: MonikerKind,

/// The scheme of the moniker. For example tsc or .Net
scheme: []const u8,

/// The scope in which the moniker is unique
unique: UniquenessLevel,
};

/// Client capabilities specific to the moniker request.
const MonikerClientCapabilities = struct {
/// Whether moniker supports dynamic registration. If this is set to `true`
/// the client supports the new `MonikerRegistrationOptions` return value
/// for the corresponding server capability as well.
dynamicRegistration: bool,
};
const MonikerOptions = struct {workDoneProgress: bool,
};
const MonikerParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const MonikerRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,
workDoneProgress: bool,
};
const PartialResultParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,
};
const PrepareRenameParams = struct {
/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// The publish diagnostic client capabilities.
const PublishDiagnosticsClientCapabilities = struct {
/// Client supports a codeDescription property
codeDescriptionSupport: bool,

/// Whether code action supports the `data` property which is
/// preserved between a `textDocument/publishDiagnostics` and
/// `textDocument/codeAction` request.
dataSupport: bool,

/// Whether the clients accepts diagnostics with related information.
relatedInformation: bool,

/// Whether the client interprets the version property of the
/// `textDocument/publishDiagnostics` notification`s parameter.
versionSupport: bool,
};

/// The publish diagnostic notification's parameters.
const PublishDiagnosticsParams = struct {
/// An array of diagnostic information items.
diagnostics: []Diagnostic,

/// The URI for which diagnostic information is reported.
uri: []const u8,

/// Optional the version number of the document the diagnostics are published for.
version: i64,
};

/// Client Capabilities for a [ReferencesRequest](#ReferencesRequest).
const ReferenceClientCapabilities = struct {
/// Whether references supports dynamic registration.
dynamicRegistration: bool,
};

/// Reference options.
const ReferenceOptions = struct {workDoneProgress: bool,
};

/// Parameters for a [ReferencesRequest](#ReferencesRequest).
const ReferenceParams = struct {context: ReferenceContext,

/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [ReferencesRequest](#ReferencesRequest).
const ReferenceRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,
workDoneProgress: bool,
};

/// General parameters to to register for an notification or to register a provider.
const Registration = struct {
/// The id used to register the request. The id can be used to deregister
/// the request again.
id: []const u8,

/// The method to register for.
method: []const u8,

/// Options necessary for the registration.
registerOptions: LSPAny,
};
const RegistrationParams = struct {registrations: []Registration,
};

/// Client capabilities specific to regular expressions.
const RegularExpressionsClientCapabilities = struct {
/// The engine's name.
engine: []const u8,

/// The engine's version.
version: []const u8,
};
const RenameClientCapabilities = struct {
/// Whether rename supports dynamic registration.
dynamicRegistration: bool,

/// Whether th client honors the change annotations in
/// text edits and resource operations returned via the
/// rename request's workspace edit by for example presenting
/// the workspace edit in the user interface and asking
/// for confirmation.
honorsChangeAnnotations: bool,

/// Client supports testing for validity of rename operations
/// before execution.
prepareSupport: bool,

/// Client supports the default behavior result.
prepareSupportDefaultBehavior: 1,
};

/// The parameters sent in file rename requests/notifications.
const RenameFilesParams = struct {
/// An array of all files/folders renamed in this operation. When a folder is renamed, only
/// the folder will be included, and not its children.
files: []FileRename,
};

/// Provider options for a [RenameRequest](#RenameRequest).
const RenameOptions = struct {
/// Renames should be checked and tested before being executed.
prepareProvider: bool,
workDoneProgress: bool,
};

/// The parameters of a [RenameRequest](#RenameRequest).
const RenameParams = struct {
/// The new name of the symbol. If the given name is not valid the
/// request must return a [ResponseError](#ResponseError) with an
/// appropriate message set.
newName: []const u8,

/// The position at which this request was sent.
position: Position,

/// The document to rename.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [RenameRequest](#RenameRequest).
const RenameRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// Renames should be checked and tested before being executed.
prepareProvider: bool,
workDoneProgress: bool,
};

/// Save options.
const SaveOptions = struct {
/// The client is supposed to include the content on save.
includeText: bool,
};
const SelectionRangeClientCapabilities = struct {
/// Whether implementation supports dynamic registration for selection range providers. If this is set to `true`
/// the client supports the new `SelectionRangeRegistrationOptions` return value for the corresponding server
/// capability as well.
dynamicRegistration: bool,
};
const SelectionRangeOptions = struct {workDoneProgress: bool,
};

/// A parameter literal used in selection range requests.
const SelectionRangeParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The positions inside the text document.
positions: []Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const SelectionRangeRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,
workDoneProgress: bool,
};
const SemanticTokensClientCapabilities = struct {
/// Whether the client uses semantic tokens to augment existing
/// syntax tokens. If set to `true` client side created syntax
/// tokens and semantic tokens are both used for colorization. If
/// set to `false` the client only uses the returned semantic tokens
/// for colorization.
augmentsSyntaxTokens: bool,

/// Whether implementation supports dynamic registration. If this is set to `true`
/// the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
/// return value for the corresponding server capability as well.
dynamicRegistration: bool,

/// The token formats the clients supports.
formats: []relative,

/// Whether the client supports tokens that can span multiple lines.
multilineTokenSupport: bool,

/// Whether the client supports tokens that can overlap each other.
overlappingTokenSupport: bool,

/// Whether the client allows the server to actively cancel a
/// semantic token request, e.g. supports returning
/// LSPErrorCodes.ServerCancelled. If a server does the client
/// needs to retrigger the request.
serverCancelSupport: bool,

/// The token modifiers that the client supports.
tokenModifiers: [][]const u8,

/// The token types that the client supports.
tokenTypes: [][]const u8,
};
const SemanticTokensDeltaParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The result id of a previous response. The result Id can either point to a full response
/// or a delta response depending on what was received last.
previousResultId: []const u8,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const SemanticTokensDeltaPartialResult = struct {edits: []SemanticTokensEdit,
};
const SemanticTokensOptions = struct {
/// Server supports providing semantic tokens for a full document.
full: union(enum) {boolean: bool,
},

/// The legend used by the server
legend: SemanticTokensLegend,

/// Server supports providing semantic tokens for a specific range
/// of a document.
range: union(enum) {boolean: bool,
},
workDoneProgress: bool,
};
const SemanticTokensParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const SemanticTokensPartialResult = struct {data: []i64,
};
const SemanticTokensRangeParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The range the semantic tokens are requested for.
range: Range,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const SemanticTokensRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// Server supports providing semantic tokens for a full document.
full: union(enum) {boolean: bool,
},

/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,

/// The legend used by the server
legend: SemanticTokensLegend,

/// Server supports providing semantic tokens for a specific range
/// of a document.
range: union(enum) {boolean: bool,
},
workDoneProgress: bool,
};

/// Client capabilities for the show document request.
const ShowDocumentClientCapabilities = struct {
/// The client has support for the show document
/// request.
support: bool,
};

/// Params to show a document.
const ShowDocumentParams = struct {
/// Indicates to show the resource in an external program.
/// To show for example `https://code.visualstudio.com/`
/// in the default WEB browser set `external` to `true`.
external: bool,

/// An optional selection range if the document is a text
/// document. Clients might ignore the property if an
/// external program is started or the file is not a text
/// file.
selection: Range,

/// An optional property to indicate whether the editor
/// showing the document should take focus or not.
/// Clients might ignore this property if an external
/// program in started.
takeFocus: bool,

/// The document uri to show.
uri: []const u8,
};

/// The result of an show document request.
const ShowDocumentResult = struct {
/// A boolean indicating if the show was successful.
success: bool,
};

/// The parameters of a notification message.
const ShowMessageParams = struct {
/// The actual message
message: []const u8,

/// The message type. See {@link MessageType}
@"type": MessageType,
};

/// Show message request client capabilities
const ShowMessageRequestClientCapabilities = struct {};
const ShowMessageRequestParams = struct {
/// The message action items to present.
actions: []MessageActionItem,

/// The actual message
message: []const u8,

/// The message type. See {@link MessageType}
@"type": MessageType,
};

/// Client Capabilities for a [SignatureHelpRequest](#SignatureHelpRequest).
const SignatureHelpClientCapabilities = struct {
/// The client supports to send additional context information for a
/// `textDocument/signatureHelp` request. A client that opts into
/// contextSupport will also support the `retriggerCharacters` on
/// `SignatureHelpOptions`.
contextSupport: bool,

/// Whether signature help supports dynamic registration.
dynamicRegistration: bool,
};

/// Additional information about the context in which a signature help request was triggered.
const SignatureHelpContext = struct {
/// The currently active `SignatureHelp`.
activeSignatureHelp: SignatureHelp,

/// `true` if signature help was already showing when it was triggered.
isRetrigger: bool,

/// Character that caused signature help to be triggered.
triggerCharacter: []const u8,

/// Action that caused signature help to be triggered.
triggerKind: SignatureHelpTriggerKind,
};

/// Server Capabilities for a [SignatureHelpRequest](#SignatureHelpRequest).
const SignatureHelpOptions = struct {
/// List of characters that re-trigger signature help.
retriggerCharacters: [][]const u8,

/// List of characters that trigger signature help.
triggerCharacters: [][]const u8,
workDoneProgress: bool,
};

/// Parameters for a [SignatureHelpRequest](#SignatureHelpRequest).
const SignatureHelpParams = struct {
/// The signature help context. This is only available if the client specifies
/// to send this using the client capability `textDocument.signatureHelp.contextSupport === true`
context: SignatureHelpContext,

/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [SignatureHelpRequest](#SignatureHelpRequest).
const SignatureHelpRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// List of characters that re-trigger signature help.
retriggerCharacters: [][]const u8,

/// List of characters that trigger signature help.
triggerCharacters: [][]const u8,
workDoneProgress: bool,
};

/// Static registration options to be returned in the initialize
/// request.
const StaticRegistrationOptions = struct {
/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,
};

/// Describe options to be used when registered for text document change events.
const TextDocumentChangeRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// How documents are synced to the server.
syncKind: TextDocumentSyncKind,
};

/// Text document specific client capabilities.
const TextDocumentClientCapabilities = struct {
/// Capabilities specific to the various call hierarchy request.
callHierarchy: CallHierarchyClientCapabilities,

/// Capabilities specific to the `textDocument/codeAction`
codeAction: CodeActionClientCapabilities,

/// Capabilities specific to the `textDocument/codeLens`
codeLens: CodeLensClientCapabilities,

/// Capabilities specific to the `textDocument/documentColor`
colorProvider: DocumentColorClientCapabilities,

/// Capabilities specific to the `textDocument/completion`
completion: CompletionClientCapabilities,

/// Capabilities specific to the `textDocument/declaration`
declaration: DeclarationClientCapabilities,

/// Capabilities specific to the `textDocument/definition`
definition: DefinitionClientCapabilities,

/// Capabilities specific to the `textDocument/documentHighlight`
documentHighlight: DocumentHighlightClientCapabilities,

/// Capabilities specific to the `textDocument/documentLink`
documentLink: DocumentLinkClientCapabilities,

/// Capabilities specific to the `textDocument/documentSymbol`
documentSymbol: DocumentSymbolClientCapabilities,

/// Capabilities specific to `textDocument/foldingRange` request.
foldingRange: FoldingRangeClientCapabilities,

/// Capabilities specific to the `textDocument/formatting`
formatting: DocumentFormattingClientCapabilities,

/// Capabilities specific to the `textDocument/hover`
hover: HoverClientCapabilities,

/// Capabilities specific to the `textDocument/implementation`
implementation: ImplementationClientCapabilities,

/// Capabilities specific to the `textDocument/inlineValues` request.
inlineValues: InlineValuesClientCapabilities,

/// Capabilities specific to the linked editing range request.
linkedEditingRange: LinkedEditingRangeClientCapabilities,

/// Client capabilities specific to the moniker request.
moniker: MonikerClientCapabilities,

/// Capabilities specific to the `textDocument/onTypeFormatting`
onTypeFormatting: DocumentOnTypeFormattingClientCapabilities,

/// Capabilities specific to `textDocument/publishDiagnostics` notification.
publishDiagnostics: PublishDiagnosticsClientCapabilities,

/// Capabilities specific to the `textDocument/rangeFormatting`
rangeFormatting: DocumentRangeFormattingClientCapabilities,

/// Capabilities specific to the `textDocument/references`
references: ReferenceClientCapabilities,

/// Capabilities specific to the `textDocument/rename`
rename: RenameClientCapabilities,

/// Capabilities specific to `textDocument/selectionRange` request.
selectionRange: SelectionRangeClientCapabilities,

/// Capabilities specific to the various semantic token request.
semanticTokens: SemanticTokensClientCapabilities,

/// Capabilities specific to the `textDocument/signatureHelp`
signatureHelp: SignatureHelpClientCapabilities,

/// Defines which synchronization capabilities the client supports.
synchronization: TextDocumentSyncClientCapabilities,

/// Capabilities specific to the `textDocument/typeDefinition`
typeDefinition: TypeDefinitionClientCapabilities,

/// Capabilities specific to the various type hierarchy requests.
typeHierarchy: TypeHierarchyClientCapabilities,
};

/// A parameter literal used in requests to pass a text document and a position inside that
/// document.
const TextDocumentPositionParams = struct {
/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,
};

/// General text document registration options.
const TextDocumentRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,
};

/// Save registration options.
const TextDocumentSaveRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The client is supposed to include the content on save.
includeText: bool,
};
const TextDocumentSyncClientCapabilities = struct {
/// The client supports did save notifications.
didSave: bool,

/// Whether text document synchronization supports dynamic registration.
dynamicRegistration: bool,

/// The client supports sending will save notifications.
willSave: bool,

/// The client supports sending a will save request and
/// waits for a response providing text edits which will
/// be applied to the document before it is saved.
willSaveWaitUntil: bool,
};
const TextDocumentSyncOptions = struct {
/// Change notifications are sent to the server. See TextDocumentSyncKind.None, TextDocumentSyncKind.Full
/// and TextDocumentSyncKind.Incremental. If omitted it defaults to TextDocumentSyncKind.None.
change: TextDocumentSyncKind,

/// Open and close notifications are sent to the server. If omitted open close notification should not
/// be sent.
openClose: bool,

/// If present save notifications are sent to the server. If omitted the notification should not be
/// sent.
save: union(enum) {boolean: bool,
SaveOptions: SaveOptions,
},

/// If present will save notifications are sent to the server. If omitted the notification should not be
/// sent.
willSave: bool,

/// If present will save wait until requests are sent to the server. If omitted the request should not be
/// sent.
willSaveWaitUntil: bool,
};
const TypeDefinitionOptions = struct {workDoneProgress: bool,
};
const TypeDefinitionParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// The position inside the text document.
position: Position,

/// The text document.
textDocument: TextDocumentIdentifier,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const TypeDefinitionRegistrationOptions = struct {
/// A document selector to identify the scope of the registration. If set to null
/// the document selector provided on the client side will be used.
documentSelector: ?DocumentSelector,

/// The id used to register the request. The id can be used to deregister
/// the request again. See also Registration#id.
id: []const u8,
workDoneProgress: bool,
};

/// General parameters to unregister a request or notification.
const Unregistration = struct {
/// The id used to unregister the request or notification. Usually an id
/// provided during the register request.
id: []const u8,

/// The method to unregister for.
method: []const u8,
};
const UnregistrationParams = struct {unregisterations: []Unregistration,
};

/// The parameters send in a will save text document notification.
const WillSaveTextDocumentParams = struct {
/// The 'TextDocumentSaveReason'.
reason: TextDocumentSaveReason,

/// The document that will be saved.
textDocument: TextDocumentIdentifier,
};
const WindowClientCapabilities = struct {
/// Capabilities specific to the showDocument request.
showDocument: ShowDocumentClientCapabilities,

/// Capabilities specific to the showMessage request.
showMessage: ShowMessageRequestClientCapabilities,

/// Whether client supports handling progress notifications. If set
/// servers are allowed to report in `workDoneProgress` property in the
/// request specific server capabilities.
workDoneProgress: bool,
};
const WorkDoneProgressBegin = struct {
/// Controls if a cancel button should show to allow the user to cancel the
/// long running operation. Clients that don't support cancellation are allowed
/// to ignore the setting.
cancellable: bool,
kind: begin,

/// Optional, more detailed associated progress message. Contains
/// complementary information to the `title`.
message: []const u8,

/// Optional progress percentage to display (value 100 is considered 100%).
/// If not provided infinite progress is assumed and clients are allowed
/// to ignore the `percentage` value in subsequent in report notifications.
percentage: i64,

/// Mandatory title of the progress operation. Used to briefly inform about
/// the kind of operation being performed.
title: []const u8,
};
const WorkDoneProgressCancelParams = struct {
/// The token to be used to report progress.
token: ProgressToken,
};
const WorkDoneProgressCreateParams = struct {
/// The token to be used to report progress.
token: ProgressToken,
};
const WorkDoneProgressEnd = struct {kind: end,

/// Optional, a final message indicating to for example indicate the outcome
/// of the operation.
message: []const u8,
};
const WorkDoneProgressOptions = struct {workDoneProgress: bool,
};
const WorkDoneProgressParams = struct {
/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};
const WorkDoneProgressReport = struct {
/// Controls enablement state of a cancel button.
cancellable: bool,
kind: report,

/// Optional, more detailed associated progress message. Contains
/// complementary information to the `title`.
message: []const u8,

/// Optional progress percentage to display (value 100 is considered 100%).
/// If not provided infinite progress is assumed and clients are allowed
/// to ignore the `percentage` value in subsequent in report notifications.
percentage: i64,
};

/// Workspace specific client capabilities.
const WorkspaceClientCapabilities = struct {
/// The client supports applying batch edits
/// to the workspace by supporting the request
/// 'workspace/applyEdit'
applyEdit: bool,

/// Capabilities specific to the code lens requests scoped to the
/// workspace.
codeLens: CodeLensWorkspaceClientCapabilities,

/// Capabilities specific to the `workspace/didChangeConfiguration` notification.
didChangeConfiguration: DidChangeConfigurationClientCapabilities,

/// Capabilities specific to the `workspace/didChangeWatchedFiles` notification.
didChangeWatchedFiles: DidChangeWatchedFilesClientCapabilities,

/// Capabilities specific to the `workspace/executeCommand` request.
executeCommand: ExecuteCommandClientCapabilities,

/// The client has support for file notifications/requests for user operations on files.
fileOperations: FileOperationClientCapabilities,

/// Capabilities specific to the inline values requests scoped to the
/// workspace.
inlineValues: InlineValuesWorkspaceClientCapabilities,

/// Capabilities specific to the semantic token requests scoped to the
/// workspace.
semanticTokens: SemanticTokensWorkspaceClientCapabilities,

/// Capabilities specific to the `workspace/symbol` request.
symbol: WorkspaceSymbolClientCapabilities,

/// Capabilities specific to `WorkspaceEdit`s
workspaceEdit: WorkspaceEditClientCapabilities,
};
const WorkspaceEditClientCapabilities = struct {
/// The client supports versioned document changes in `WorkspaceEdit`s
documentChanges: bool,

/// The failure handling strategy of a client if applying the workspace edit
/// fails.
failureHandling: FailureHandlingKind,

/// Whether the client normalizes line endings to the client specific
/// setting.
/// If set to `true` the client will normalize line ending characters
/// in a workspace edit containing to the client specific new line
/// character.
normalizesLineEndings: bool,

/// The resource operations the client supports. Clients should at least
/// support 'create', 'rename' and 'delete' files and folders.
resourceOperations: []ResourceOperationKind,
};
const WorkspaceFolder = struct {
/// The name of the workspace folder. Used to refer to this
/// workspace folder in the user interface.
name: []const u8,

/// The associated URI for this workspace folder.
uri: []const u8,
};

/// The workspace folder change event.
const WorkspaceFoldersChangeEvent = struct {
/// The array of added workspace folders
added: []WorkspaceFolder,

/// The array of the removed workspace folders
removed: []WorkspaceFolder,
};

/// Client capabilities for a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
const WorkspaceSymbolClientCapabilities = struct {
/// Symbol request supports dynamic registration.
dynamicRegistration: bool,
};

/// Server capabilities for a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
const WorkspaceSymbolOptions = struct {
/// The server provides support to resolve additional
/// information for a workspace symbol.
resolveProvider: bool,
workDoneProgress: bool,
};

/// The parameters of a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
const WorkspaceSymbolParams = struct {
/// An optional token that a server can use to report partial results (e.g. streaming) to
/// the client.
partialResultToken: ProgressToken,

/// A query string to filter symbols by. Clients may send an empty
/// string here to request all symbols.
query: []const u8,

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Registration options for a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
const WorkspaceSymbolRegistrationOptions = struct {
/// The server provides support to resolve additional
/// information for a workspace symbol.
resolveProvider: bool,
workDoneProgress: bool,
};

/// Defines the capabilities provided by the client.
const _ClientCapabilities = struct {
/// Experimental client capabilities.
experimental: object,

/// General client capabilities.
general: GeneralClientCapabilities,

/// Text document specific client capabilities.
textDocument: TextDocumentClientCapabilities,

/// Window specific client capabilities.
window: WindowClientCapabilities,

/// Workspace specific client capabilities.
workspace: WorkspaceClientCapabilities,
};

/// The initialize parameters
const _InitializeParams = struct {
/// The capabilities provided by the client (editor or tool)
capabilities: ClientCapabilities,

/// User provided initialization options.
initializationOptions: LSPAny,

/// The locale the client is currently showing the user interface
/// in. This must not necessarily be the locale of the operating
/// system.
locale: []const u8,

/// The process Id of the parent process that started
/// the server.
processId: ?i64,

/// The rootPath of the workspace. Is null
/// if no folder is open.
rootPath: ?[]const u8,

/// The rootUri of the workspace. Is null if no
/// folder is open. If both `rootPath` and `rootUri` are set
/// `rootUri` wins.
rootUri: ?[]const u8,

/// The initial trace setting. If omitted trace is disabled ('off').
trace: enum {off,
messages,
compact,
verbose,



        usingnamespace IntBackedEnumStringify(@This());
        },

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,
};

/// Defines the capabilities provided by a language
/// server.
const _ServerCapabilities = struct {
/// The server provides call hierarchy support.
callHierarchyProvider: union(enum) {boolean: bool,
CallHierarchyOptions: CallHierarchyOptions,
CallHierarchyRegistrationOptions: CallHierarchyRegistrationOptions,
},

/// The server provides code actions. CodeActionOptions may only be
/// specified if the client states that it supports
/// `codeActionLiteralSupport` in its initial `initialize` request.
codeActionProvider: union(enum) {boolean: bool,
CodeActionOptions: CodeActionOptions,
},

/// The server provides code lens.
codeLensProvider: CodeLensOptions,

/// The server provides color provider support.
colorProvider: union(enum) {boolean: bool,
DocumentColorOptions: DocumentColorOptions,
DocumentColorRegistrationOptions: DocumentColorRegistrationOptions,
},

/// The server provides completion support.
completionProvider: CompletionOptions,

/// The server provides Goto Declaration support.
declarationProvider: union(enum) {boolean: bool,
DeclarationOptions: DeclarationOptions,
DeclarationRegistrationOptions: DeclarationRegistrationOptions,
},

/// The server provides goto definition support.
definitionProvider: union(enum) {boolean: bool,
DefinitionOptions: DefinitionOptions,
},

/// The server provides document formatting.
documentFormattingProvider: union(enum) {boolean: bool,
DocumentFormattingOptions: DocumentFormattingOptions,
},

/// The server provides document highlight support.
documentHighlightProvider: union(enum) {boolean: bool,
DocumentHighlightOptions: DocumentHighlightOptions,
},

/// The server provides document link support.
documentLinkProvider: DocumentLinkOptions,

/// The server provides document formatting on typing.
documentOnTypeFormattingProvider: DocumentOnTypeFormattingOptions,

/// The server provides document range formatting.
documentRangeFormattingProvider: union(enum) {boolean: bool,
DocumentRangeFormattingOptions: DocumentRangeFormattingOptions,
},

/// The server provides document symbol support.
documentSymbolProvider: union(enum) {boolean: bool,
DocumentSymbolOptions: DocumentSymbolOptions,
},

/// The server provides execute command support.
executeCommandProvider: ExecuteCommandOptions,

/// Experimental server capabilities.
experimental: T,

/// The server provides folding provider support.
foldingRangeProvider: union(enum) {boolean: bool,
FoldingRangeOptions: FoldingRangeOptions,
FoldingRangeRegistrationOptions: FoldingRangeRegistrationOptions,
},

/// The server provides hover support.
hoverProvider: union(enum) {boolean: bool,
HoverOptions: HoverOptions,
},

/// The server provides Goto Implementation support.
implementationProvider: union(enum) {boolean: bool,
ImplementationOptions: ImplementationOptions,
ImplementationRegistrationOptions: ImplementationRegistrationOptions,
},

/// The server provides inline values.
inlineValuesProvider: union(enum) {boolean: bool,
InlineValuesOptions: InlineValuesOptions,
InlineValuesRegistrationOptions: InlineValuesRegistrationOptions,
},

/// The server provides linked editing range support.
linkedEditingRangeProvider: union(enum) {boolean: bool,
LinkedEditingRangeOptions: LinkedEditingRangeOptions,
LinkedEditingRangeRegistrationOptions: LinkedEditingRangeRegistrationOptions,
},

/// The server provides moniker support.
monikerProvider: union(enum) {boolean: bool,
MonikerOptions: MonikerOptions,
MonikerRegistrationOptions: MonikerRegistrationOptions,
},

/// The server provides find references support.
referencesProvider: union(enum) {boolean: bool,
ReferenceOptions: ReferenceOptions,
},

/// The server provides rename support. RenameOptions may only be
/// specified if the client states that it supports
/// `prepareSupport` in its initial `initialize` request.
renameProvider: union(enum) {boolean: bool,
RenameOptions: RenameOptions,
},

/// The server provides selection range support.
selectionRangeProvider: union(enum) {boolean: bool,
SelectionRangeOptions: SelectionRangeOptions,
SelectionRangeRegistrationOptions: SelectionRangeRegistrationOptions,
},

/// The server provides semantic tokens support.
semanticTokensProvider: union(enum) {SemanticTokensOptions: SemanticTokensOptions,
SemanticTokensRegistrationOptions: SemanticTokensRegistrationOptions,
},

/// The server provides signature help support.
signatureHelpProvider: SignatureHelpOptions,

/// Defines how text documents are synced. Is either a detailed structure defining each notification or
/// for backwards compatibility the TextDocumentSyncKind number.
textDocumentSync: union(enum) {TextDocumentSyncOptions: TextDocumentSyncOptions,
TextDocumentSyncKind: TextDocumentSyncKind,
},

/// The server provides Goto Type Definition support.
typeDefinitionProvider: union(enum) {boolean: bool,
TypeDefinitionOptions: TypeDefinitionOptions,
TypeDefinitionRegistrationOptions: TypeDefinitionRegistrationOptions,
},

/// The server provides type hierarchy support.
typeHierarchyProvider: union(enum) {boolean: bool,
TypeHierarchyOptions: TypeHierarchyOptions,
TypeHierarchyRegistrationOptions: TypeHierarchyRegistrationOptions,
},

/// The server provides workspace symbol support.
workspaceSymbolProvider: union(enum) {boolean: bool,
WorkspaceSymbolOptions: WorkspaceSymbolOptions,
},
};
const ApplyWorkspaceEditResponse = ApplyWorkspaceEditResult;
const ClientCapabilities = struct {
/// Experimental client capabilities.
experimental: object,

/// General client capabilities.
general: GeneralClientCapabilities,

/// Text document specific client capabilities.
textDocument: TextDocumentClientCapabilities,

/// Window specific client capabilities.
window: WindowClientCapabilities,

/// Workspace specific client capabilities.
workspace: WorkspaceClientCapabilities,
};
const CompletionTriggerKind = enum {1,
2,
3,



        usingnamespace IntBackedEnumStringify(@This());
        };

/// A document filter denotes a document by different properties like
/// the [language](#TextDocument.languageId), the [scheme](#Uri.scheme) of
/// its resource, or a glob-pattern that is applied to the [path](#TextDocument.fileName).
const DocumentFilter = union(enum) {};

/// A document selector is the combination of one or many document filters.
const DocumentSelector = []union(enum) {string: []const u8,
DocumentFilter: DocumentFilter,
};
const FailureHandlingKind = enum {abort,
transactional,
undo,
textOnlyTransactional,



        usingnamespace IntBackedEnumStringify(@This());
        };
const FileChangeType = enum {1,
2,
3,



        usingnamespace IntBackedEnumStringify(@This());
        };
const FileOperationPatternKind = enum {file,
folder,



        usingnamespace IntBackedEnumStringify(@This());
        };
const InitializeParams = struct {
/// The capabilities provided by the client (editor or tool)
capabilities: ClientCapabilities,

/// User provided initialization options.
initializationOptions: LSPAny,

/// The locale the client is currently showing the user interface
/// in. This must not necessarily be the locale of the operating
/// system.
locale: []const u8,

/// The process Id of the parent process that started
/// the server.
processId: ?i64,

/// The rootPath of the workspace. Is null
/// if no folder is open.
rootPath: ?[]const u8,

/// The rootUri of the workspace. Is null if no
/// folder is open. If both `rootPath` and `rootUri` are set
/// `rootUri` wins.
rootUri: ?[]const u8,

/// The initial trace setting. If omitted trace is disabled ('off').
trace: enum {off,
messages,
compact,
verbose,



        usingnamespace IntBackedEnumStringify(@This());
        },

/// An optional token that a server can use to report work done progress.
workDoneToken: ProgressToken,

/// The actual configured workspace folders.
workspaceFolders: ?[]WorkspaceFolder,
};
const MessageType = enum {1,
2,
3,
4,



        usingnamespace IntBackedEnumStringify(@This());
        };
const PrepareSupportDefaultBehavior = 1;

/// The kind of resource operations supported by the client.
const ResourceOperationKind = enum {create,
rename,
delete,



        usingnamespace IntBackedEnumStringify(@This());
        };
const ServerCapabilities = struct {
/// The server provides call hierarchy support.
callHierarchyProvider: union(enum) {boolean: bool,
CallHierarchyOptions: CallHierarchyOptions,
CallHierarchyRegistrationOptions: CallHierarchyRegistrationOptions,
},

/// The server provides code actions. CodeActionOptions may only be
/// specified if the client states that it supports
/// `codeActionLiteralSupport` in its initial `initialize` request.
codeActionProvider: union(enum) {boolean: bool,
CodeActionOptions: CodeActionOptions,
},

/// The server provides code lens.
codeLensProvider: CodeLensOptions,

/// The server provides color provider support.
colorProvider: union(enum) {boolean: bool,
DocumentColorOptions: DocumentColorOptions,
DocumentColorRegistrationOptions: DocumentColorRegistrationOptions,
},

/// The server provides completion support.
completionProvider: CompletionOptions,

/// The server provides Goto Declaration support.
declarationProvider: union(enum) {boolean: bool,
DeclarationOptions: DeclarationOptions,
DeclarationRegistrationOptions: DeclarationRegistrationOptions,
},

/// The server provides goto definition support.
definitionProvider: union(enum) {boolean: bool,
DefinitionOptions: DefinitionOptions,
},

/// The server provides document formatting.
documentFormattingProvider: union(enum) {boolean: bool,
DocumentFormattingOptions: DocumentFormattingOptions,
},

/// The server provides document highlight support.
documentHighlightProvider: union(enum) {boolean: bool,
DocumentHighlightOptions: DocumentHighlightOptions,
},

/// The server provides document link support.
documentLinkProvider: DocumentLinkOptions,

/// The server provides document formatting on typing.
documentOnTypeFormattingProvider: DocumentOnTypeFormattingOptions,

/// The server provides document range formatting.
documentRangeFormattingProvider: union(enum) {boolean: bool,
DocumentRangeFormattingOptions: DocumentRangeFormattingOptions,
},

/// The server provides document symbol support.
documentSymbolProvider: union(enum) {boolean: bool,
DocumentSymbolOptions: DocumentSymbolOptions,
},

/// The server provides execute command support.
executeCommandProvider: ExecuteCommandOptions,

/// Experimental server capabilities.
experimental: T,

/// The server provides folding provider support.
foldingRangeProvider: union(enum) {boolean: bool,
FoldingRangeOptions: FoldingRangeOptions,
FoldingRangeRegistrationOptions: FoldingRangeRegistrationOptions,
},

/// The server provides hover support.
hoverProvider: union(enum) {boolean: bool,
HoverOptions: HoverOptions,
},

/// The server provides Goto Implementation support.
implementationProvider: union(enum) {boolean: bool,
ImplementationOptions: ImplementationOptions,
ImplementationRegistrationOptions: ImplementationRegistrationOptions,
},

/// The server provides inline values.
inlineValuesProvider: union(enum) {boolean: bool,
InlineValuesOptions: InlineValuesOptions,
InlineValuesRegistrationOptions: InlineValuesRegistrationOptions,
},

/// The server provides linked editing range support.
linkedEditingRangeProvider: union(enum) {boolean: bool,
LinkedEditingRangeOptions: LinkedEditingRangeOptions,
LinkedEditingRangeRegistrationOptions: LinkedEditingRangeRegistrationOptions,
},

/// The server provides moniker support.
monikerProvider: union(enum) {boolean: bool,
MonikerOptions: MonikerOptions,
MonikerRegistrationOptions: MonikerRegistrationOptions,
},

/// The server provides find references support.
referencesProvider: union(enum) {boolean: bool,
ReferenceOptions: ReferenceOptions,
},

/// The server provides rename support. RenameOptions may only be
/// specified if the client states that it supports
/// `prepareSupport` in its initial `initialize` request.
renameProvider: union(enum) {boolean: bool,
RenameOptions: RenameOptions,
},

/// The server provides selection range support.
selectionRangeProvider: union(enum) {boolean: bool,
SelectionRangeOptions: SelectionRangeOptions,
SelectionRangeRegistrationOptions: SelectionRangeRegistrationOptions,
},

/// The server provides semantic tokens support.
semanticTokensProvider: union(enum) {SemanticTokensOptions: SemanticTokensOptions,
SemanticTokensRegistrationOptions: SemanticTokensRegistrationOptions,
},

/// The server provides signature help support.
signatureHelpProvider: SignatureHelpOptions,

/// Defines how text documents are synced. Is either a detailed structure defining each notification or
/// for backwards compatibility the TextDocumentSyncKind number.
textDocumentSync: union(enum) {TextDocumentSyncOptions: TextDocumentSyncOptions,
TextDocumentSyncKind: TextDocumentSyncKind,
},

/// The server provides Goto Type Definition support.
typeDefinitionProvider: union(enum) {boolean: bool,
TypeDefinitionOptions: TypeDefinitionOptions,
TypeDefinitionRegistrationOptions: TypeDefinitionRegistrationOptions,
},

/// The server provides type hierarchy support.
typeHierarchyProvider: union(enum) {boolean: bool,
TypeHierarchyOptions: TypeHierarchyOptions,
TypeHierarchyRegistrationOptions: TypeHierarchyRegistrationOptions,
},

/// The server provides workspace symbol support.
workspaceSymbolProvider: union(enum) {boolean: bool,
WorkspaceSymbolOptions: WorkspaceSymbolOptions,
},
};
const SignatureHelpTriggerKind = enum {1,
2,
3,



        usingnamespace IntBackedEnumStringify(@This());
        };

/// An event describing a change to a text document. If range and rangeLength are omitted
/// the new text is considered to be the full content of the document.
const TextDocumentContentChangeEvent = union(enum) {};
const TextDocumentSaveReason = enum {1,
2,
3,



        usingnamespace IntBackedEnumStringify(@This());
        };
const TextDocumentSyncKind = enum {0,
1,
2,



        usingnamespace IntBackedEnumStringify(@This());
        };
const TokenFormat = relative;
