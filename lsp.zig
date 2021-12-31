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

pub fn StringBackedEnumStringify(comptime T: type) type {
    return struct {
        pub fn jsonStringify(value: T, options: json.StringifyOptions, out_stream: anytype) !void {
            inline for (std.meta.fields(T)) |field| {
                if (@enumToInt(value) == field.value) {
                    try json.stringify(field.name, options, out_stream);
                    return;
                }
            }

            unreachable;
        }
    };
}

test "string-backed enum stringify" {
    const MyEnum = enum {
        one,
        two,

        usingnamespace StringBackedEnumStringify(@This());
    };

    var buf: [10]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);

    try json.stringify(MyEnum.one, .{}, fbs.writer());
    try std.testing.expectEqualSlices(u8, "\"one\"", buf[0..5]);

    try json.stringify(MyEnum.two, .{}, fbs.writer());
    try std.testing.expectEqualSlices(u8, "\"two\"", buf[5..]);
}

/// The LSP any type
pub const LSPAny = json.Value;

// pub const ManuallyTranslateValue = @compileError("bruh 😭");

pub const RequestId = union(enum) {
    integer: i64,
    string: []const u8,
};

test {
    // Test for general correctness of structs
    std.testing.refAllDecls(@This());
}

/// A tagging type for string properties that are actually document URIs.
pub const DocumentUri = []const u8;

/// A tagging type for string properties that are actually URIs
pub const URI = []const u8;

/// Position in a text document expressed as zero-based line and character offset.
/// The offsets are based on a UTF-16 string representation. So a string of the form
/// `a𐐀b` the character offset of the character `a` is 0, the character offset of `𐐀`
/// is 1 and the character offset of b is 3 since `𐐀` is represented using two code
/// units in UTF-16.
pub const Position = struct {
    /// Line position in a document (zero-based).
    line: i64,

    /// Character offset on a line in a document (zero-based). Assuming that the line is
    /// represented as a string, the `character` value represents the gap between the
    /// `character` and `character + 1`.
    character: i64,
};

/// A range in a text document expressed as (zero-based) start and end positions.
pub const Range = struct {
    /// The range's start position
    start: Position,

    /// The range's end position.
    end: Position,
};

/// Represents a location inside a resource, such as a line
/// inside a text file.
pub const Location = struct {
    uri: []const u8,
    range: Range,
};

/// Represents the connection of two locations. Provides additional metadata over normal [locations](#Location),
/// including an origin range.
pub const LocationLink = struct {
    /// Span of the origin of this link.
    originSelectionRange: ?Range = null,

    /// The target resource identifier of this link.
    targetUri: []const u8,

    /// The full target range of this link. If the target for example is a symbol then target range is the
    /// range enclosing this symbol not including leading/trailing whitespace but everything else
    /// like comments. This information is typically used to highlight the range in the editor.
    targetRange: Range,

    /// The range that should be selected and revealed when this link is being followed, e.g the name of a function.
    /// Must be contained by the the `targetRange`. See also `DocumentSymbol#range`
    targetSelectionRange: Range,
};

/// Represents a color in RGBA space.
pub const Color = struct {
    /// The red component of this color in the range [0-1].
    red: i64,

    /// The green component of this color in the range [0-1].
    green: i64,

    /// The blue component of this color in the range [0-1].
    blue: i64,

    /// The alpha component of this color in the range [0-1].
    alpha: i64,
};

/// Represents a color range from a document.
pub const ColorInformation = struct {
    /// The range in the document where this color appears.
    range: Range,

    /// The actual color value for this color range.
    color: Color,
};
pub const ColorPresentation = struct {
    /// The label of this color presentation. It will be shown on the color
    /// picker header. By default this is also the text that is inserted when selecting
    /// this color presentation.
    label: []const u8,

    /// An [edit](#TextEdit) which is applied to a document when selecting
    /// this presentation for the color.  When `falsy` the [label](#ColorPresentation.label)
    /// is used.
    textEdit: ?TextEdit = null,

    /// An optional array of additional [text edits](#TextEdit) that are applied when
    /// selecting this color presentation. Edits must not overlap with the main [edit](#ColorPresentation.textEdit) nor with themselves.
    additionalTextEdits: ?[]TextEdit = null,
};

/// Enum of known range kinds
pub const FoldingRangeKind = struct {
    pub const Comment = "comment";
    pub const Imports = "imports";
    pub const Region = "region";
};
/// Represents a folding range. To be valid, start and end line must be bigger than zero and smaller
/// than the number of lines in the document. Clients are free to ignore invalid ranges.
pub const FoldingRange = struct {
    /// The zero-based start line of the range to fold. The folded area starts after the line's last character.
    /// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
    startLine: i64,

    /// The zero-based character offset from where the folded range starts. If not defined, defaults to the length of the start line.
    startCharacter: ?i64 = null,

    /// The zero-based end line of the range to fold. The folded area ends with the line's last character.
    /// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
    endLine: i64,

    /// The zero-based character offset before the folded range ends. If not defined, defaults to the length of the end line.
    endCharacter: ?i64 = null,

    /// Describes the kind of the folding range such as `comment' or 'region'. The kind
    /// is used to categorize folding ranges and used by commands like 'Fold all comments'. See
    /// [FoldingRangeKind](#FoldingRangeKind) for an enumeration of standardized kinds.
    kind: ?[]const u8 = null,
};

/// Represents a related message and source code location for a diagnostic. This should be
/// used to point to code locations that cause or related to a diagnostics, e.g when duplicating
/// a symbol in a scope.
pub const DiagnosticRelatedInformation = struct {
    /// The location of this related diagnostic information.
    location: Location,

    /// The message of this related diagnostic information.
    message: []const u8,
};

/// The diagnostic's severity.
pub const DiagnosticSeverity = enum(i64) {
    Error = 1,
    Warning = 2,
    Information = 3,
    Hint = 4,

    usingnamespace IntBackedEnumStringify(@This());
};

/// The diagnostic tags.
pub const DiagnosticTag = enum(i64) {
    Unnecessary = 1,
    Deprecated = 2,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Structure to capture a description for an error code.
pub const CodeDescription = struct {
    /// An URI to open with more information about the diagnostic error.
    href: []const u8,
};

/// Represents a diagnostic, such as a compiler error or warning. Diagnostic objects
/// are only valid in the scope of a resource.
pub const Diagnostic = struct {
    /// The range at which the message applies
    range: Range,

    /// The diagnostic's severity. Can be omitted. If omitted it is up to the
    /// client to interpret diagnostics as error, warning, info or hint.
    severity: ?DiagnosticSeverity = null,

    /// The diagnostic's code, which usually appear in the user interface.
    code: ?union(enum) {
        string: []const u8,
        number: i64,
    } = null,

    /// An optional property to describe the error code.
    codeDescription: ?CodeDescription = null,

    /// A human-readable string describing the source of this
    /// diagnostic, e.g. 'typescript' or 'super lint'. It usually
    /// appears in the user interface.
    source: ?[]const u8 = null,

    /// The diagnostic's message. It usually appears in the user interface
    message: []const u8,

    /// Additional metadata about the diagnostic.
    tags: ?[]DiagnosticTag = null,

    /// An array of related diagnostic information, e.g. when symbol-names within
    /// a scope collide all definitions can be marked via this property.
    relatedInformation: ?[]DiagnosticRelatedInformation = null,

    /// A data entry field that is preserved between a `textDocument/publishDiagnostics`
    /// notification and `textDocument/codeAction` request.
    data: ?json.Value = null,
};

/// Represents a reference to a command. Provides a title which
/// will be used to represent a command in the UI and, optionally,
/// an array of arguments which will be passed to the command handler
/// function when invoked.
pub const Command = struct {
    /// Title of the command, like `save`.
    title: []const u8,

    /// The identifier of the actual command handler.
    command: []const u8,

    /// Arguments that the command handler should be
    /// invoked with.
    arguments: ?[]json.Value = null,
};

/// A text edit applicable to a text document.
pub const TextEdit = struct {
    /// The range of the text document to be manipulated. To insert
    /// text into a document create a range where start === end.
    range: Range,

    /// The string to be inserted. For delete operations use an
    /// empty string.
    newText: []const u8,
};

/// Additional information that describes document changes.
pub const ChangeAnnotation = struct {
    /// A human-readable string describing the actual change. The string
    /// is rendered prominent in the user interface.
    label: []const u8,

    /// A flag which indicates that user confirmation is needed
    /// before applying the change.
    needsConfirmation: ?bool = null,

    /// A human-readable string which is rendered less prominent in
    /// the user interface.
    description: ?[]const u8 = null,
};

/// An identifier to refer to a change annotation stored with a workspace edit.
pub const ChangeAnnotationIdentifier = []const u8;

/// A special text edit with an additional change annotation.
pub const AnnotatedTextEdit = struct {
    /// The actual identifier of the change annotation
    annotationId: []const u8,

    /// The range of the text document to be manipulated. To insert
    /// text into a document create a range where start === end.
    range: Range,

    /// The string to be inserted. For delete operations use an
    /// empty string.
    newText: []const u8,
};

/// Describes textual changes on a text document. A TextDocumentEdit describes all changes
/// on a document version Si and after they are applied move the document to version Si+1.
/// So the creator of a TextDocumentEdit doesn't need to sort the array of edits or do any
/// kind of ordering. However the edits must be non overlapping.
pub const TextDocumentEdit = struct {
    /// The text document to change.
    textDocument: OptionalVersionedTextDocumentIdentifier,

    /// The edits to be applied.
    edits: []union(enum) {
        TextEdit: TextEdit,
        AnnotatedTextEdit: AnnotatedTextEdit,
    },
};

/// Options to create a file.
pub const CreateFileOptions = struct {
    /// Overwrite existing file. Overwrite wins over `ignoreIfExists`
    overwrite: ?bool = null,

    /// Ignore if exists.
    ignoreIfExists: ?bool = null,
};

/// Create file operation.
pub const CreateFile = struct {
    /// A create
    comptime kind: []const u8 = "create",

    /// The resource to create.
    uri: []const u8,

    /// Additional options
    options: ?CreateFileOptions = null,

    /// An optional annotation identifier describing the operation.
    annotationId: ?[]const u8 = null,
};

/// Rename file options
pub const RenameFileOptions = struct {
    /// Overwrite target if existing. Overwrite wins over `ignoreIfExists`
    overwrite: ?bool = null,

    /// Ignores if target exists.
    ignoreIfExists: ?bool = null,
};

/// Rename file operation
pub const RenameFile = struct {
    /// A rename
    comptime kind: []const u8 = "rename",

    /// The old (existing) location.
    oldUri: []const u8,

    /// The new location.
    newUri: []const u8,

    /// Rename options.
    options: ?RenameFileOptions = null,

    /// An optional annotation identifier describing the operation.
    annotationId: ?[]const u8 = null,
};

/// Delete file options
pub const DeleteFileOptions = struct {
    /// Delete the content recursively if a folder is denoted.
    recursive: ?bool = null,

    /// Ignore the operation if the file doesn't exist.
    ignoreIfNotExists: ?bool = null,
};

/// Delete file operation
pub const DeleteFile = struct {
    /// A delete
    comptime kind: []const u8 = "delete",

    /// The file to delete.
    uri: []const u8,

    /// Delete options.
    options: ?DeleteFileOptions = null,

    /// An optional annotation identifier describing the operation.
    annotationId: ?[]const u8 = null,
};

/// A workspace edit represents changes to many resources managed in the workspace. The edit
/// should either provide `changes` or `documentChanges`. If documentChanges are present
/// they are preferred over `changes` if the client can handle versioned document edits.
pub const WorkspaceEdit = struct {
    /// Holds changes to existing resources.
    /// Map of DocumentUri -> []TextEdit
    changes: ?json.ObjectMap = null,

    /// Depending on the client capability `workspace.workspaceEdit.resourceOperations` document changes
    /// are either an array of `TextDocumentEdit`s to express changes to n different text documents
    /// where each text document edit addresses a specific version of a text document. Or it can contain
    /// above `TextDocumentEdit`s mixed with create, rename and delete file / folder operations.
    documentChanges: ?[]union(enum) {
        TextDocumentEdit: TextDocumentEdit,
        CreateFile: CreateFile,
        RenameFile: RenameFile,
        DeleteFile: DeleteFile,
    } = null,

    /// A map of change annotations that can be referenced in `AnnotatedTextEdit`s or create, rename and
    /// delete file / folder operations.
    /// Map of ChangeAnnotationIdentifier -> ChangeAnnotation
    changeAnnotations: ?json.ObjectMap = null,
};

/// A change to capture text edits for existing resources.
pub const TextEditChange = struct {};

/// A literal to identify a text document in the client.
pub const TextDocumentIdentifier = struct {
    /// The text document's uri.
    uri: []const u8,
};

/// A text document identifier to denote a specific version of a text document.
pub const VersionedTextDocumentIdentifier = struct {
    /// The version number of this document.
    version: i64,

    /// The text document's uri.
    uri: []const u8,
};

/// A text document identifier to optionally denote a specific version of a text document.
pub const OptionalVersionedTextDocumentIdentifier = struct {
    /// The version number of this document. If a versioned text document identifier
    /// is sent from the server to the client and the file is not open in the editor
    /// (the server has not received an open notification before) the server can send
    /// `null` to indicate that the version is unknown and the content on disk is the
    /// truth (as specified with document content ownership).
    version: ?i64,

    /// The text document's uri.
    uri: []const u8,
};

/// An item to transfer a text document from the client to the
/// server.
pub const TextDocumentItem = struct {
    /// The text document's uri.
    uri: []const u8,

    /// The text document's language identifier
    languageId: []const u8,

    /// The version number of this document (it will increase after each
    /// change, including undo/redo).
    version: i64,

    /// The content of the opened text document.
    text: []const u8,
};
pub const MarkupKind = enum {
    plaintext,
    markdown,

    usingnamespace StringBackedEnumStringify(@This());
};

/// A `MarkupContent` literal represents a string value which content is interpreted base on its
/// kind flag. Currently the protocol supports `plaintext` and `markdown` as markup kinds.
pub const MarkupContent = struct {
    /// The type of the Markup
    kind: MarkupKind,

    /// The content itself
    value: []const u8,
};

/// The kind of a completion entry.
pub const CompletionItemKind = enum(i64) {
    Text = 1,
    Method = 2,
    Function = 3,
    Constructor = 4,
    Field = 5,
    Variable = 6,
    Class = 7,
    Interface = 8,
    Module = 9,
    Property = 10,
    Unit = 11,
    Value = 12,
    Enum = 13,
    Keyword = 14,
    Snippet = 15,
    Color = 16,
    File = 17,
    Reference = 18,
    Folder = 19,
    EnumMember = 20,
    Constant = 21,
    Struct = 22,
    Event = 23,
    Operator = 24,
    TypeParameter = 25,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Defines whether the insert text in a completion item should be interpreted as
/// plain text or a snippet.
pub const InsertTextFormat = enum(i64) {
    PlainText = 1,
    Snippet = 2,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Completion item tags are extra annotations that tweak the rendering of a completion
/// item.
pub const CompletionItemTag = enum(i64) {
    Deprecated = 1,

    usingnamespace IntBackedEnumStringify(@This());
};

/// A special text edit to provide an insert and a replace operation.
pub const InsertReplaceEdit = struct {
    /// The string to be inserted.
    newText: []const u8,

    /// The range if the insert is requested
    insert: Range,

    /// The range if the replace is requested.
    replace: Range,
};

/// How whitespace and indentation is handled during completion
/// item insertion.
pub const InsertTextMode = enum(i64) {
    asIs = 1,
    adjustIndentation = 2,

    usingnamespace IntBackedEnumStringify(@This());
};

/// A completion item represents a text snippet that is
/// proposed to complete text that is being typed.
pub const CompletionItem = struct {
    /// The label of this completion item. By default
    /// also the text that is inserted when selecting
    /// this completion.
    label: []const u8,

    /// The kind of this completion item. Based of the kind
    /// an icon is chosen by the editor.
    kind: ?CompletionItemKind = null,

    /// Tags for this completion item.
    tags: ?[]CompletionItemTag = null,

    /// A human-readable string with additional information
    /// about this item, like type or symbol information.
    detail: ?[]const u8 = null,

    /// A human-readable string that represents a doc-comment.
    documentation: ?union(enum) {
        string: []const u8,
        MarkupContent: MarkupContent,
    } = null,

    /// Indicates if this item is deprecated.
    deprecated: ?bool = null,

    /// Select this item when showing.
    preselect: ?bool = null,

    /// A string that should be used when comparing this item
    /// with other items. When `falsy` the [label](#CompletionItem.label)
    /// is used.
    sortText: ?[]const u8 = null,

    /// A string that should be used when filtering a set of
    /// completion items. When `falsy` the [label](#CompletionItem.label)
    /// is used.
    filterText: ?[]const u8 = null,

    /// A string that should be inserted into a document when selecting
    /// this completion. When `falsy` the [label](#CompletionItem.label)
    /// is used.
    insertText: ?[]const u8 = null,

    /// The format of the insert text. The format applies to both the `insertText` property
    /// and the `newText` property of a provided `textEdit`. If omitted defaults to
    /// `InsertTextFormat.PlainText`.
    insertTextFormat: ?InsertTextFormat = null,

    /// How whitespace and indentation is handled during completion
    /// item insertion. If ignored the clients default value depends on
    /// the `textDocument.completion.insertTextMode` client capability.
    insertTextMode: ?InsertTextMode = null,

    /// An [edit](#TextEdit) which is applied to a document when selecting
    /// this completion. When an edit is provided the value of
    /// [insertText](#CompletionItem.insertText) is ignored.
    textEdit: ?union(enum) {
        TextEdit: TextEdit,
        InsertReplaceEdit: InsertReplaceEdit,
    } = null,

    /// An optional array of additional [text edits](#TextEdit) that are applied when
    /// selecting this completion. Edits must not overlap (including the same insert position)
    /// with the main [edit](#CompletionItem.textEdit) nor with themselves.
    additionalTextEdits: ?[]TextEdit = null,

    /// An optional set of characters that when pressed while this completion is active will accept it first and
    /// then type that character. *Note* that all commit characters should have `length=1` and that superfluous
    /// characters will be ignored.
    commitCharacters: ?[][]const u8 = null,

    /// An optional [command](#Command) that is executed *after* inserting this completion. *Note* that
    /// additional modifications to the current document should be described with the
    /// [additionalTextEdits](#CompletionItem.additionalTextEdits)-property.
    command: ?Command = null,

    /// A data entry field that is preserved on a completion item between
    /// a [CompletionRequest](#CompletionRequest) and a [CompletionResolveRequest]
    /// (#CompletionResolveRequest)
    data: ?json.Value = null,
};

/// Represents a collection of [completion items](#CompletionItem) to be presented
/// in the editor.
pub const CompletionList = struct {
    /// This list it not complete. Further typing results in recomputing this list.
    isIncomplete: bool,

    /// The completion items.
    items: []CompletionItem,
};

/// MarkedString can be used to render human readable text. It is either a markdown string
/// or a code-block that provides a language and a code snippet. The language identifier
/// is semantically equal to the optional language identifier in fenced code blocks in GitHub
/// issues. See https://help.github.com/articles/creating-and-highlighting-code-blocks/#syntax-highlighting
pub const MarkedString = union(enum) {
    string: []const u8,
    reflection: struct {
        language: []const u8,
        value: []const u8,
    },
};

/// The result of a hover request.
pub const Hover = struct {
    /// The hover's content
    contents: union(enum) {
        MarkupContent: MarkupContent,
        MarkedString: MarkedString,
        array: []MarkedString,
    },

    /// An optional range
    range: ?Range = null,
};

/// Represents a parameter of a callable-signature. A parameter can
/// have a label and a doc-comment.
pub const ParameterInformation = struct {
    /// The label of this parameter information.
    label: union(enum) {
        string: []const u8,
        tuple: Tuple(&[_]type{
            i64,
            i64,
        }),
    },

    /// The human-readable doc-comment of this signature. Will be shown
    /// in the UI but can be omitted.
    documentation: ?union(enum) {
        string: []const u8,
        MarkupContent: MarkupContent,
    } = null,
};

/// Represents the signature of something callable. A signature
/// can have a label, like a function-name, a doc-comment, and
/// a set of parameters.
pub const SignatureInformation = struct {
    /// The label of this signature. Will be shown in
    /// the UI.
    label: []const u8,

    /// The human-readable doc-comment of this signature. Will be shown
    /// in the UI but can be omitted.
    documentation: ?union(enum) {
        string: []const u8,
        MarkupContent: MarkupContent,
    } = null,

    /// The parameters of this signature.
    parameters: ?[]ParameterInformation = null,

    /// The index of the active parameter.
    activeParameter: ?i64 = null,
};

/// Signature help represents the signature of something
/// callable. There can be multiple signature but only one
/// active and only one active parameter.
pub const SignatureHelp = struct {
    /// One or more signatures.
    signatures: []SignatureInformation,

    /// The active signature. Set to `null` if no
    /// signatures exist.
    activeSignature: ?i64,

    /// The active parameter of the active signature. Set to `null`
    /// if the active signature has no parameters.
    activeParameter: ?i64,
};

/// The definition of a symbol represented as one or many [locations](#Location).
/// For most programming languages there is only one location at which a symbol is
/// defined.
pub const Definition = union(enum) {
    Location: Location,
    array: []Location,
};

/// Information about where a symbol is defined.
pub const DefinitionLink = LocationLink;

/// The declaration of a symbol representation as one or many [locations](#Location).
pub const Declaration = union(enum) {
    Location: Location,
    array: []Location,
};

/// Information about where a symbol is declared.
pub const DeclarationLink = LocationLink;

/// Value-object that contains additional information when
/// requesting references.
pub const ReferenceContext = struct {
    /// Include the declaration of the current symbol.
    includeDeclaration: bool,
};

/// A document highlight kind.
pub const DocumentHighlightKind = enum(i64) {
    Text = 1,
    Read = 2,
    Write = 3,

    usingnamespace IntBackedEnumStringify(@This());
};

/// A document highlight is a range inside a text document which deserves
/// special attention. Usually a document highlight is visualized by changing
/// the background color of its range.
pub const DocumentHighlight = struct {
    /// The range this highlight applies to.
    range: Range,

    /// The highlight kind, default is [text](#DocumentHighlightKind.Text).
    kind: ?DocumentHighlightKind = null,
};

/// A symbol kind.
pub const SymbolKind = enum(i64) {
    File = 1,
    Module = 2,
    Namespace = 3,
    Package = 4,
    Class = 5,
    Method = 6,
    Property = 7,
    Field = 8,
    Constructor = 9,
    Enum = 10,
    Interface = 11,
    Function = 12,
    Variable = 13,
    Constant = 14,
    String = 15,
    Number = 16,
    Boolean = 17,
    Array = 18,
    Object = 19,
    Key = 20,
    Null = 21,
    EnumMember = 22,
    Struct = 23,
    Event = 24,
    Operator = 25,
    TypeParameter = 26,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Symbol tags are extra annotations that tweak the rendering of a symbol.
pub const SymbolTag = enum(i64) {
    Deprecated = 1,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Represents information about programming constructs like variables, classes,
/// interfaces etc.
pub const SymbolInformation = struct {
    /// The name of this symbol.
    name: []const u8,

    /// The kind of this symbol.
    kind: SymbolKind,

    /// Tags for this completion item.
    tags: ?[]CompletionItemTag = null,

    /// Indicates if this symbol is deprecated.
    deprecated: ?bool = null,

    /// The location of this symbol. The location's range is used by a tool
    /// to reveal the location in the editor. If the symbol is selected in the
    /// tool the range's start information is used to position the cursor. So
    /// the range usually spans more than the actual symbol's name and does
    /// normally include thinks like visibility modifiers.
    location: Location,

    /// The name of the symbol containing this symbol. This information is for
    /// user interface purposes (e.g. to render a qualifier in the user interface
    /// if necessary). It can't be used to re-infer a hierarchy for the document
    /// symbols.
    containerName: ?[]const u8 = null,
};

/// Represents programming constructs like variables, classes, interfaces etc.
/// that appear in a document. Document symbols can be hierarchical and they
/// have two ranges: one that encloses its definition and one that points to
/// its most interesting range, e.g. the range of an identifier.
pub const DocumentSymbol = struct {
    /// The name of this symbol. Will be displayed in the user interface and therefore must not be
    /// an empty string or a string only consisting of white spaces.
    name: []const u8,

    /// More detail for this symbol, e.g the signature of a function.
    detail: ?[]const u8 = null,

    /// The kind of this symbol.
    kind: SymbolKind,

    /// Tags for this completion item.
    tags: ?[]CompletionItemTag = null,

    /// Indicates if this symbol is deprecated.
    deprecated: ?bool = null,

    /// The range enclosing this symbol not including leading/trailing whitespace but everything else
    /// like comments. This information is typically used to determine if the the clients cursor is
    /// inside the symbol to reveal in the symbol in the UI.
    range: Range,

    /// The range that should be selected and revealed when this symbol is being picked, e.g the name of a function.
    /// Must be contained by the the `range`.
    selectionRange: Range,

    /// Children of this symbol, e.g. properties of a class.
    children: ?[]DocumentSymbol = null,
};

/// A set of predefined code action kinds
pub const CodeActionKind = struct {
    /// Empty kind.
    pub const Empty = CodeActionKind;
    /// Base kind for quickfix actions: 'quickfix'
    pub const QuickFix = CodeActionKind;
    /// Base kind for refactoring actions: 'refactor'
    pub const Refactor = CodeActionKind;
    /// Base kind for refactoring extraction actions: 'refactor.extract'
    pub const RefactorExtract = CodeActionKind;
    /// Base kind for refactoring inline actions: 'refactor.inline'
    pub const RefactorInline = CodeActionKind;
    /// Base kind for refactoring rewrite actions: 'refactor.rewrite'
    pub const RefactorRewrite = CodeActionKind;
    /// Base kind for source actions: `source`
    pub const Source = CodeActionKind;
    /// Base kind for an organize imports source action: `source.organizeImports`
    pub const SourceOrganizeImports = CodeActionKind;
    /// Base kind for auto-fix source actions: `source.fixAll`.
    pub const SourceFixAll = CodeActionKind;
};

/// Contains additional diagnostic information about the context in which
/// a [code action](#CodeActionProvider.provideCodeActions) is run.
pub const CodeActionContext = struct {
    /// An array of diagnostics known on the client side overlapping the range provided to the
    /// `textDocument/codeAction` request. They are provided so that the server knows which
    /// errors are currently presented to the user for the given range. There is no guarantee
    /// that these accurately reflect the error state of the resource. The primary parameter
    /// to compute code actions is the provided range.
    diagnostics: []Diagnostic,

    /// Requested kind of actions to return.
    only: ?[][]const u8 = null,
};

/// A code action represents a change that can be performed in code, e.g. to fix a problem or
/// to refactor code.
pub const CodeAction = struct {
    /// A short, human-readable, title for this code action.
    title: []const u8,

    /// The kind of the code action.
    kind: ?[]const u8 = null,

    /// The diagnostics that this code action resolves.
    diagnostics: ?[]Diagnostic = null,

    /// Marks this as a preferred action. Preferred actions are used by the `auto fix` command and can be targeted
    /// by keybindings.
    isPreferred: ?bool = null,

    /// Marks that the code action cannot currently be applied.
    disabled: ?struct {
        /// Human readable description of why the code action is currently disabled.
        reason: []const u8,
    } = null,

    /// The workspace edit this code action performs.
    edit: ?WorkspaceEdit = null,

    /// A command this code action executes. If a code action
    /// provides a edit and a command, first the edit is
    /// executed and then the command.
    command: ?Command = null,

    /// A data entry field that is preserved on a code action between
    /// a `textDocument/codeAction` and a `codeAction/resolve` request.
    data: ?json.Value = null,
};

/// A code lens represents a [command](#Command) that should be shown along with
/// source text, like the number of references, a way to run tests, etc.
pub const CodeLens = struct {
    /// The range in which this code lens is valid. Should only span a single line.
    range: Range,

    /// The command this code lens represents.
    command: ?Command = null,

    /// A data entry field that is preserved on a code lens item between
    /// a [CodeLensRequest](#CodeLensRequest) and a [CodeLensResolveRequest]
    /// (#CodeLensResolveRequest)
    data: ?json.Value = null,
};

/// Value-object describing what options formatting should use.
pub const FormattingOptions = struct {
    /// Size of a tab in spaces.
    tabSize: i64,

    /// Prefer spaces over tabs.
    insertSpaces: bool,

    /// Trim trailing whitespaces on a line.
    trimTrailingWhitespace: ?bool = null,

    /// Insert a newline character at the end of the file if one does not exist.
    insertFinalNewline: ?bool = null,

    /// Trim all newlines after the final newline at the end of the file.
    trimFinalNewlines: ?bool = null,
};

/// A document link is a range in a text document that links to an internal or external resource, like another
/// text document or a web site.
pub const DocumentLink = struct {
    /// The range this link applies to.
    range: Range,

    /// The uri this link points to.
    target: ?[]const u8 = null,

    /// The tooltip text when you hover over this link.
    tooltip: ?[]const u8 = null,

    /// A data entry field that is preserved on a document link between a
    /// DocumentLinkRequest and a DocumentLinkResolveRequest.
    data: ?json.Value = null,
};

/// A selection range represents a part of a selection hierarchy. A selection range
/// may have a parent selection range that contains it.
pub const SelectionRange = struct {
    /// The [range](#Range) of this selection range.
    range: Range,

    /// The parent selection range containing this range. Therefore `parent.range` must contain `this.range`.
    parent: ?*SelectionRange = null,
};

/// Represents programming constructs like functions or constructors in the context
/// of call hierarchy.
pub const CallHierarchyItem = struct {
    /// The name of this item.
    name: []const u8,

    /// The kind of this item.
    kind: SymbolKind,

    /// Tags for this item.
    tags: ?[]SymbolTag = null,

    /// More detail for this item, e.g. the signature of a function.
    detail: ?[]const u8 = null,

    /// The resource identifier of this item.
    uri: []const u8,

    /// The range enclosing this symbol not including leading/trailing whitespace but everything else, e.g. comments and code.
    range: Range,

    /// The range that should be selected and revealed when this symbol is being picked, e.g. the name of a function.
    /// Must be contained by the [`range`](#CallHierarchyItem.range).
    selectionRange: Range,

    /// A data entry field that is preserved between a call hierarchy prepare and
    /// incoming calls or outgoing calls requests.
    data: ?json.Value = null,
};

/// Represents an incoming call, e.g. a caller of a method or constructor.
pub const CallHierarchyIncomingCall = struct {
    /// The item that makes the call.
    from: CallHierarchyItem,

    /// The ranges at which the calls appear. This is relative to the caller
    /// denoted by [`this.from`](#CallHierarchyIncomingCall.from).
    fromRanges: []Range,
};

/// Represents an outgoing call, e.g. calling a getter from a method or a method from a constructor etc.
pub const CallHierarchyOutgoingCall = struct {
    /// The item that is called.
    to: CallHierarchyItem,

    /// The range at which this item is called. This is the range relative to the caller, e.g the item
    /// passed to [`provideCallHierarchyOutgoingCalls`](#CallHierarchyItemProvider.provideCallHierarchyOutgoingCalls)
    /// and not [`this.to`](#CallHierarchyOutgoingCall.to).
    fromRanges: []Range,
};
pub const EOL = [][]const u8;
/// A simple text document. Not to be implemented. The document keeps the content
/// as string.
pub const TextDocument = struct {
    /// The associated URI for this document. Most documents have the __file__-scheme, indicating that they
    /// represent files on disk. However, some documents may have other schemes indicating that they are not
    /// available on disk.
    uri: []const u8,

    /// The identifier of the language associated with this document.
    languageId: []const u8,

    /// The version number of this document (it will increase after each
    /// change, including undo/redo).
    version: i64,

    /// The number of lines in this document.
    lineCount: i64,
};
pub const WorkspaceFoldersClientCapabilities = struct {
    /// The workspace client capabilities
    workspace: ?struct {
        /// The client has support for workspace folders
        workspaceFolders: ?bool = null,
    } = null,
};
pub const ConfigurationClientCapabilities = struct {
    /// The workspace client capabilities
    workspace: ?struct {
        /// The client supports `workspace/configuration` requests.
        configuration: ?bool = null,
    } = null,
};
pub const WorkDoneProgressClientCapabilities = struct {
    /// Window specific client capabilities.
    window: ?struct {
        /// Whether client supports server initiated progress using the
        /// `window/workDoneProgress/create` request.
        workDoneProgress: ?bool = null,
    } = null,
};
pub const WorkspaceFoldersServerCapabilities = struct {
    /// The workspace server capabilities
    workspace: ?struct {
        workspaceFolders: ?struct {
            /// Whether the server wants to receive workspace folder
            /// change notifications.
            changeNotifications: ?union(enum) {
                string: []const u8,
                boolean: bool,
            } = null,

            /// The Server has support for workspace folders
            supported: ?bool = null,
        } = null,
    } = null,
};
pub const WorkspaceFoldersInitializeParams = struct {
    /// The actual configured workspace folders.
    workspaceFolders: ?[]WorkspaceFolder,
};
pub const ProgressToken = union(enum) {
    number: i64,
    string: []const u8,
};
pub const SemanticTokensWorkspaceClientCapabilities = struct {
    /// Whether the client implementation supports a refresh request sent from
    /// the server to the client.
    refreshSupport: ?bool = null,
};

/// Since 3.6.0
pub const TypeDefinitionClientCapabilities = struct {
    /// Whether implementation supports dynamic registration. If this is set to `true`
    /// the client supports the new `TypeDefinitionRegistrationOptions` return value
    /// for the corresponding server capability as well.
    dynamicRegistration: ?bool = null,

    /// The client supports additional metadata in the form of definition links.
    linkSupport: ?bool = null,
};
pub const ImplementationClientCapabilities = struct {
    /// Whether implementation supports dynamic registration. If this is set to `true`
    /// the client supports the new `ImplementationRegistrationOptions` return value
    /// for the corresponding server capability as well.
    dynamicRegistration: ?bool = null,

    /// The client supports additional metadata in the form of definition links.
    linkSupport: ?bool = null,
};
pub const DocumentColorClientCapabilities = struct {
    /// Whether implementation supports dynamic registration. If this is set to `true`
    /// the client supports the new `DocumentColorRegistrationOptions` return value
    /// for the corresponding server capability as well.
    dynamicRegistration: ?bool = null,
};

/// A filter to describe in which file operation requests or notifications
/// the server is interested in.
pub const FileOperationFilter = struct {
    /// A Uri like `file` or `untitled`.
    scheme: ?[]const u8 = null,

    /// The actual file operation pattern.
    pattern: FileOperationPattern,
};

/// Defines a CancellationToken. This interface is not
/// intended to be implemented. A CancellationToken must
/// be created via a CancellationTokenSource.
pub const CancellationToken = struct {
    /// Is `true` when the token has been cancelled, `false` otherwise.
    isCancellationRequested: bool,

    // An [event](#Event) which fires upon cancellation.
    // TODO: sugondese
    // onCancellationRequested: Event(
    //     json.Value,
    // ),
};

/// A pattern to describe in which file operation requests or notifications
/// the server is interested in.
pub const FileOperationPattern = struct {
    /// The glob pattern to match. Glob patterns can have the following syntax:
    /// - `*` to match one or more characters in a path segment
    /// - `?` to match on one character in a path segment
    /// - `**` to match any number of path segments, including none
    /// - `{}` to group conditions (e.g. `**​/*.{ts,js}` matches all TypeScript and JavaScript files)
    /// - `[]` to declare a range of characters to match in a path segment (e.g., `example.[0-9]` to match on `example.0`, `example.1`, …)
    /// - `[!...]` to negate a range of characters to match in a path segment (e.g., `example.[!0-9]` to match on `example.a`, `example.b`, but not `example.0`)
    glob: []const u8,

    /// Whether to match files or folders with this pattern.
    matches: ?FileOperationPatternKind = null,

    /// Additional options used during matching.
    options: ?FileOperationPatternOptions = null,
};

/// A generic resource operation.
pub const ResourceOperation = struct {
    /// The resource operation kind.
    kind: []const u8,

    /// An optional annotation identifier describing the operation.
    annotationId: ?[]const u8 = null,
};

/// A document filter denotes a document by different properties like
/// the [language](#TextDocument.languageId), the [scheme](#Uri.scheme) of
/// its resource, or a glob-pattern that is applied to the [path](#TextDocument.fileName).
pub const DocumentFilter = struct {
    /// A language id, like `typescript`.
    language: ?[]const u8 = null,

    /// A glob pattern, like `*.{ts,js}`.
    pattern: ?[]const u8 = null,

    /// A Uri [scheme](#Uri.scheme), like `file` or `untitled`.
    scheme: ?[]const u8 = null,
};

/// A document selector is the combination of one or many document filters.
pub const DocumentSelector = []union(enum) {
    string: []const u8,
    DocumentFilter: DocumentFilter,
};

/// General parameters to to register for an notification or to register a provider.
pub const Registration = struct {
    /// The id used to register the request. The id can be used to deregister
    /// the request again.
    id: []const u8,

    /// The method to register for.
    method: []const u8,

    /// Options necessary for the registration.
    registerOptions: ?json.Value = null,
};
pub const RegistrationParams = struct {
    registrations: []Registration,
};

/// The `client/registerCapability` request is sent from the server to the client to register a new capability
/// handler on the client side.
pub const RegistrationRequest = struct {
    comptime method: []const u8 = "client/registerCapability",
    id: RequestId,
    params: RegistrationParams,
};

/// General parameters to unregister a request or notification.
pub const Unregistration = struct {
    /// The id used to unregister the request or notification. Usually an id
    /// provided during the register request.
    id: []const u8,

    /// The method to unregister for.
    method: []const u8,
};
pub const UnregistrationParams = struct {
    unregisterations: []Unregistration,
};

/// The `client/unregisterCapability` request is sent from the server to the client to unregister a previously registered capability
/// handler on the client side.
pub const UnregistrationRequest = struct {
    comptime method: []const u8 = "client/unregisterCapability",
    id: RequestId,
    params: UnregistrationParams,
};
pub const WorkDoneProgressParams = struct {
    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};
pub const PartialResultParams = struct {
    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// A parameter literal used in requests to pass a text document and a position inside that
/// document.
pub const TextDocumentPositionParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,
};
pub const ResourceOperationKind = struct {
    /// Supports creating new files and folders.
    pub const Create = ResourceOperationKind;
    /// Supports renaming existing files and folders.
    pub const Rename = ResourceOperationKind;
    /// Supports deleting existing files and folders.
    pub const Delete = ResourceOperationKind;
};
pub const FailureHandlingKind = struct {
    /// Applying the workspace change is simply aborted if one of the changes provided
    /// fails. All operations executed before the failing operation stay executed.
    pub const Abort = FailureHandlingKind;
    /// All operations are executed transactional. That means they either all
    /// succeed or no changes at all are applied to the workspace.
    pub const Transactional = FailureHandlingKind;
    /// If the workspace edit contains only textual file changes they are executed transactional.
    /// If resource changes (create, rename or delete file) are part of the change the failure
    /// handling strategy is abort.
    pub const TextOnlyTransactional = FailureHandlingKind;
    /// The client tries to undo the operations already executed. But there is no
    /// guarantee that this is succeeding.
    pub const Undo = FailureHandlingKind;
};

/// Workspace specific client capabilities.
pub const WorkspaceClientCapabilities = struct {
    /// The client supports applying batch edits
    /// to the workspace by supporting the request
    /// 'workspace/applyEdit'
    applyEdit: ?bool = null,

    /// The client supports `workspace/configuration` requests.
    configuration: ?bool = null,

    /// The client has support for workspace folders
    workspaceFolders: ?bool = null,

    /// Capabilities specific to `WorkspaceEdit`s
    workspaceEdit: ?WorkspaceEditClientCapabilities = null,

    /// Capabilities specific to the `workspace/didChangeConfiguration` notification.
    didChangeConfiguration: ?DidChangeConfigurationClientCapabilities = null,

    /// Capabilities specific to the `workspace/didChangeWatchedFiles` notification.
    didChangeWatchedFiles: ?DidChangeWatchedFilesClientCapabilities = null,

    /// Capabilities specific to the `workspace/symbol` request.
    symbol: ?WorkspaceSymbolClientCapabilities = null,

    /// Capabilities specific to the `workspace/executeCommand` request.
    executeCommand: ?ExecuteCommandClientCapabilities = null,

    /// Capabilities specific to the semantic token requests scoped to the
    /// workspace.
    semanticTokens: ?SemanticTokensWorkspaceClientCapabilities = null,

    /// Capabilities specific to the code lens requests scoped to the
    /// workspace.
    codeLens: ?CodeLensWorkspaceClientCapabilities = null,

    /// The client has support for file notifications/requests for user operations on files.
    fileOperations: ?FileOperationClientCapabilities = null,
};

/// Text document specific client capabilities.
pub const TextDocumentClientCapabilities = struct {
    /// Defines which synchronization capabilities the client supports.
    synchronization: ?TextDocumentSyncClientCapabilities = null,

    /// Capabilities specific to the `textDocument/completion`
    completion: ?CompletionClientCapabilities = null,

    /// Capabilities specific to the `textDocument/hover`
    hover: ?HoverClientCapabilities = null,

    /// Capabilities specific to the `textDocument/signatureHelp`
    signatureHelp: ?SignatureHelpClientCapabilities = null,

    /// Capabilities specific to the `textDocument/declaration`
    declaration: ?DeclarationClientCapabilities = null,

    /// Capabilities specific to the `textDocument/definition`
    definition: ?DefinitionClientCapabilities = null,

    /// Capabilities specific to the `textDocument/typeDefinition`
    typeDefinition: ?TypeDefinitionClientCapabilities = null,

    /// Capabilities specific to the `textDocument/implementation`
    implementation: ?ImplementationClientCapabilities = null,

    /// Capabilities specific to the `textDocument/references`
    references: ?ReferenceClientCapabilities = null,

    /// Capabilities specific to the `textDocument/documentHighlight`
    documentHighlight: ?DocumentHighlightClientCapabilities = null,

    /// Capabilities specific to the `textDocument/documentSymbol`
    documentSymbol: ?DocumentSymbolClientCapabilities = null,

    /// Capabilities specific to the `textDocument/codeAction`
    codeAction: ?CodeActionClientCapabilities = null,

    /// Capabilities specific to the `textDocument/codeLens`
    codeLens: ?CodeLensClientCapabilities = null,

    /// Capabilities specific to the `textDocument/documentLink`
    documentLink: ?DocumentLinkClientCapabilities = null,

    /// Capabilities specific to the `textDocument/documentColor`
    colorProvider: ?DocumentColorClientCapabilities = null,

    /// Capabilities specific to the `textDocument/formatting`
    formatting: ?DocumentFormattingClientCapabilities = null,

    /// Capabilities specific to the `textDocument/rangeFormatting`
    rangeFormatting: ?DocumentRangeFormattingClientCapabilities = null,

    /// Capabilities specific to the `textDocument/onTypeFormatting`
    onTypeFormatting: ?DocumentOnTypeFormattingClientCapabilities = null,

    /// Capabilities specific to the `textDocument/rename`
    rename: ?RenameClientCapabilities = null,

    /// Capabilities specific to `textDocument/foldingRange` request.
    foldingRange: ?FoldingRangeClientCapabilities = null,

    /// Capabilities specific to `textDocument/selectionRange` request.
    selectionRange: ?SelectionRangeClientCapabilities = null,

    /// Capabilities specific to `textDocument/publishDiagnostics` notification.
    publishDiagnostics: ?PublishDiagnosticsClientCapabilities = null,

    /// Capabilities specific to the various call hierarchy request.
    callHierarchy: ?CallHierarchyClientCapabilities = null,

    /// Capabilities specific to the various semantic token request.
    semanticTokens: ?SemanticTokensClientCapabilities = null,

    /// Capabilities specific to the linked editing range request.
    linkedEditingRange: ?LinkedEditingRangeClientCapabilities = null,

    /// Client capabilities specific to the moniker request.
    moniker: MonikerClientCapabilities,
};
pub const WindowClientCapabilities = struct {
    /// Whether client supports handling progress notifications. If set
    /// servers are allowed to report in `workDoneProgress` property in the
    /// request specific server capabilities.
    workDoneProgress: ?bool = null,

    /// Capabilities specific to the showMessage request.
    showMessage: ?ShowMessageRequestClientCapabilities = null,

    /// Capabilities specific to the showDocument request.
    showDocument: ?ShowDocumentClientCapabilities = null,
};

/// Client capabilities specific to regular expressions.
pub const RegularExpressionsClientCapabilities = struct {
    /// The engine's name.
    engine: []const u8,

    /// The engine's version.
    version: ?[]const u8 = null,
};

/// Client capabilities specific to the used markdown parser.
pub const MarkdownClientCapabilities = struct {
    /// The name of the parser.
    parser: []const u8,

    /// The version of the parser.
    version: ?[]const u8 = null,
};

/// General client capabilities.
pub const GeneralClientCapabilities = struct {
    /// Client capabilities specific to regular expressions.
    regularExpressions: ?RegularExpressionsClientCapabilities = null,

    /// Client capabilities specific to the client's markdown parser.
    markdown: ?MarkdownClientCapabilities = null,
};
pub const ClientCapabilities = struct {
    /// Workspace specific client capabilities.
    workspace: ?WorkspaceClientCapabilities = null,

    /// Text document specific client capabilities.
    textDocument: ?TextDocumentClientCapabilities = null,

    /// Window specific client capabilities.
    window: ?WindowClientCapabilities = null,

    /// General client capabilities.
    general: ?GeneralClientCapabilities = null,

    /// Experimental client capabilities.
    experimental: ?json.ObjectMap = null,
};

/// Static registration options to be returned in the initialize
/// request.
pub const StaticRegistrationOptions = struct {
    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
};

/// General text document registration options.
pub const TextDocumentRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
};

/// Save options.
pub const SaveOptions = struct {
    /// The client is supposed to include the content on save.
    includeText: ?bool = null,
};
pub const WorkDoneProgressOptions = struct {
    workDoneProgress: ?bool = null,
};
pub const ServerCapabilities = struct {
    /// Defines how text documents are synced. Is either a detailed structure defining each notification or
    /// for backwards compatibility the TextDocumentSyncKind number.
    textDocumentSync: ?union(enum) {
        TextDocumentSyncOptions: TextDocumentSyncOptions,
        TextDocumentSyncKind: TextDocumentSyncKind,
    } = null,

    /// The server provides completion support.
    completionProvider: ?CompletionOptions = null,

    /// The server provides hover support.
    hoverProvider: ?union(enum) {
        boolean: bool,
        HoverOptions: HoverOptions,
    } = null,

    /// The server provides signature help support.
    signatureHelpProvider: ?SignatureHelpOptions = null,

    /// The server provides Goto Declaration support.
    declarationProvider: ?union(enum) {
        boolean: bool,
        DeclarationOptions: DeclarationOptions,
        DeclarationRegistrationOptions: DeclarationRegistrationOptions,
    } = null,

    /// The server provides goto definition support.
    definitionProvider: ?union(enum) {
        boolean: bool,
        DefinitionOptions: DefinitionOptions,
    } = null,

    /// The server provides Goto Type Definition support.
    typeDefinitionProvider: ?union(enum) {
        boolean: bool,
        TypeDefinitionOptions: TypeDefinitionOptions,
        TypeDefinitionRegistrationOptions: TypeDefinitionRegistrationOptions,
    } = null,

    /// The server provides Goto Implementation support.
    implementationProvider: ?union(enum) {
        boolean: bool,
        ImplementationOptions: ImplementationOptions,
        ImplementationRegistrationOptions: ImplementationRegistrationOptions,
    } = null,

    /// The server provides find references support.
    referencesProvider: ?union(enum) {
        boolean: bool,
        ReferenceOptions: ReferenceOptions,
    } = null,

    /// The server provides document highlight support.
    documentHighlightProvider: ?union(enum) {
        boolean: bool,
        DocumentHighlightOptions: DocumentHighlightOptions,
    } = null,

    /// The server provides document symbol support.
    documentSymbolProvider: ?union(enum) {
        boolean: bool,
        DocumentSymbolOptions: DocumentSymbolOptions,
    } = null,

    /// The server provides code actions. CodeActionOptions may only be
    /// specified if the client states that it supports
    /// `codeActionLiteralSupport` in its initial `initialize` request.
    codeActionProvider: ?union(enum) {
        boolean: bool,
        CodeActionOptions: CodeActionOptions,
    } = null,

    /// The server provides code lens.
    codeLensProvider: ?CodeLensOptions = null,

    /// The server provides document link support.
    documentLinkProvider: ?DocumentLinkOptions = null,

    /// The server provides color provider support.
    colorProvider: ?union(enum) {
        boolean: bool,
        DocumentColorOptions: DocumentColorOptions,
        DocumentColorRegistrationOptions: DocumentColorRegistrationOptions,
    } = null,

    /// The server provides workspace symbol support.
    workspaceSymbolProvider: ?union(enum) {
        boolean: bool,
        WorkspaceSymbolOptions: WorkspaceSymbolOptions,
    } = null,

    /// The server provides document formatting.
    documentFormattingProvider: ?union(enum) {
        boolean: bool,
        DocumentFormattingOptions: DocumentFormattingOptions,
    } = null,

    /// The server provides document range formatting.
    documentRangeFormattingProvider: ?union(enum) {
        boolean: bool,
        DocumentRangeFormattingOptions: DocumentRangeFormattingOptions,
    } = null,

    /// The server provides document formatting on typing.
    documentOnTypeFormattingProvider: ?DocumentOnTypeFormattingOptions = null,

    /// The server provides rename support. RenameOptions may only be
    /// specified if the client states that it supports
    /// `prepareSupport` in its initial `initialize` request.
    renameProvider: ?union(enum) {
        boolean: bool,
        RenameOptions: RenameOptions,
    } = null,

    /// The server provides folding provider support.
    foldingRangeProvider: ?union(enum) {
        boolean: bool,
        FoldingRangeOptions: FoldingRangeOptions,
        FoldingRangeRegistrationOptions: FoldingRangeRegistrationOptions,
    } = null,

    /// The server provides selection range support.
    selectionRangeProvider: ?union(enum) {
        boolean: bool,
        SelectionRangeOptions: SelectionRangeOptions,
        SelectionRangeRegistrationOptions: SelectionRangeRegistrationOptions,
    } = null,

    /// The server provides execute command support.
    executeCommandProvider: ?ExecuteCommandOptions = null,

    /// The server provides call hierarchy support.
    callHierarchyProvider: ?union(enum) {
        boolean: bool,
        CallHierarchyOptions: CallHierarchyOptions,
        CallHierarchyRegistrationOptions: CallHierarchyRegistrationOptions,
    } = null,

    /// The server provides linked editing range support.
    linkedEditingRangeProvider: ?union(enum) {
        boolean: bool,
        LinkedEditingRangeOptions: LinkedEditingRangeOptions,
        LinkedEditingRangeRegistrationOptions: LinkedEditingRangeRegistrationOptions,
    } = null,

    /// The server provides semantic tokens support.
    semanticTokensProvider: ?union(enum) {
        SemanticTokensOptions: SemanticTokensOptions,
        SemanticTokensRegistrationOptions: SemanticTokensRegistrationOptions,
    } = null,

    /// The server provides moniker support.
    monikerProvider: ?union(enum) {
        boolean: bool,
        MonikerOptions: MonikerOptions,
        MonikerRegistrationOptions: MonikerRegistrationOptions,
    } = null,

    /// The workspace server capabilities
    workspace: ?struct {
        workspaceFolders: ?struct {
            /// Whether the server wants to receive workspace folder
            /// change notifications.
            changeNotifications: ?union(enum) {
                string: []const u8,
                boolean: bool,
            } = null,

            /// The Server has support for workspace folders
            supported: ?bool = null,
        } = null,

        /// The server is interested in notifications/requests for operations on files.
        fileOperations: ?FileOperationOptions = null,
    } = null,
};

/// The initialize request is sent from the client to the server.
/// It is sent once as the request after starting up the server.
/// The requests parameter is of type [InitializeParams](#InitializeParams)
/// the response if of type [InitializeResult](#InitializeResult) of a Thenable that
/// resolves to such.
pub const InitializeRequest = struct {
    comptime method: []const u8 = "initialize",
    id: RequestId,
    params: InitializeParams,
};
pub const InitializeParams = struct {
    /// The process Id of the parent process that started
    /// the server.
    processId: ?i64,

    /// Information about the client
    clientInfo: ?struct {
        /// The name of the client as defined by the client.
        name: []const u8,

        /// The client's version as defined by the client.
        version: ?[]const u8 = null,
    } = null,

    /// The locale the client is currently showing the user interface
    /// in. This must not necessarily be the locale of the operating
    /// system.
    locale: ?[]const u8 = null,

    /// The rootPath of the workspace. Is null
    /// if no folder is open.
    rootPath: ?[]const u8 = null,

    /// The rootUri of the workspace. Is null if no
    /// folder is open. If both `rootPath` and `rootUri` are set
    /// `rootUri` wins.
    rootUri: ?[]const u8,

    /// The capabilities provided by the client (editor or tool)
    capabilities: ClientCapabilities,

    /// User provided initialization options.
    initializationOptions: ?json.Value = null,

    /// The initial trace setting. If omitted trace is disabled ('off').
    trace: ?enum {
        off,
        messages,
        verbose,

        usingnamespace StringBackedEnumStringify(@This());
    } = null,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// The actual configured workspace folders.
    workspaceFolders: ?[]WorkspaceFolder,
};

/// The result returned from an initialize request.
pub const InitializeResult = struct {
    /// The capabilities the language server provides.
    capabilities: ServerCapabilities,

    /// Information about the server.
    serverInfo: ?struct {
        /// The name of the server as defined by the server.
        name: []const u8,

        /// The server's version as defined by the server.
        version: ?[]const u8 = null,
    } = null,
};

/// The data type of the ResponseError if the
/// initialize request fails.
pub const InitializeError = struct {
    /// Indicates whether the client execute the following retry logic:
    /// (1) show the message provided by the ResponseError to the user
    /// (2) user selects retry or cancel
    /// (3) if user selected retry the initialize method is sent again.
    retry: bool,
};

/// Known error codes for an `InitializeError`;
pub const InitializeErrorCode = enum(i64) {
    unknownProtocolVersion = 1,

    usingnamespace IntBackedEnumStringify(@This());
};
pub const InitializedParams = struct {};

/// The initialized notification is sent from the client to the
/// server after the client is fully initialized and the server
/// is allowed to send requests from the server to the client.
pub const InitializedNotification = struct {
    comptime method: []const u8 = "initialized",
    id: RequestId,
    params: InitializedParams,
};

/// A shutdown request is sent from the client to the server.
/// It is sent once when the client decides to shutdown the
/// server. The only notification that is sent after a shutdown request
/// is the exit event.
pub const ShutdownRequest = struct {
    comptime method: []const u8 = "shutdown",
    id: RequestId,
};

/// The exit event is sent from the client to the server to
/// ask the server to exit its process.
pub const ExitNotification = struct {
    comptime method: []const u8 = "exit",
    id: RequestId,
};
pub const DidChangeConfigurationClientCapabilities = struct {
    /// Did change configuration notification supports dynamic registration.
    dynamicRegistration: ?bool = null,
};

/// The configuration change notification is sent from the client to the server
/// when the client's configuration has changed. The notification contains
/// the changed configuration as defined by the language client.
pub const DidChangeConfigurationNotification = struct {
    comptime method: []const u8 = "workspace/didChangeConfiguration",
    id: RequestId,
    params: DidChangeConfigurationParams,
};
pub const DidChangeConfigurationRegistrationOptions = struct {
    section: ?union(enum) {
        string: []const u8,
        array: [][]const u8,
    } = null,
};

/// The parameters of a change configuration notification.
pub const DidChangeConfigurationParams = struct {
    /// The actual changed settings
    settings: json.Value,
};

/// The message type
pub const MessageType = enum(i64) {
    Error = 1,
    Warning = 2,
    Info = 3,
    Log = 4,

    usingnamespace IntBackedEnumStringify(@This());
};

/// The parameters of a notification message.
pub const ShowMessageParams = struct {
    /// The message type. See {@link MessageType}
    @"type": MessageType,

    /// The actual message
    message: []const u8,
};

/// The show message notification is sent from a server to a client to ask
/// the client to display a particular message in the user interface.
pub const ShowMessageNotification = struct {
    comptime method: []const u8 = "window/showMessage",
    id: RequestId,
    params: ShowMessageParams,
};

/// Show message request client capabilities
pub const ShowMessageRequestClientCapabilities = struct {
    /// Capabilities specific to the `MessageActionItem` type.
    messageActionItem: ?struct {
        /// Whether the client supports additional attributes which
        /// are preserved and send back to the server in the
        /// request's response.
        additionalPropertiesSupport: ?bool = null,
    } = null,
};
pub const MessageActionItem = struct {
    /// A short title like 'Retry', 'Open Log' etc.
    title: []const u8,
};
pub const ShowMessageRequestParams = struct {
    /// The message type. See {@link MessageType}
    @"type": MessageType,

    /// The actual message
    message: []const u8,

    /// The message action items to present.
    actions: ?[]MessageActionItem = null,
};

/// The show message request is sent from the server to the client to show a message
/// and a set of options actions to the user.
pub const ShowMessageRequest = struct {
    comptime method: []const u8 = "window/showMessageRequest",
    id: RequestId,
    params: ShowMessageRequestParams,
};

/// The log message notification is sent from the server to the client to ask
/// the client to log a particular message.
pub const LogMessageNotification = struct {
    comptime method: []const u8 = "window/logMessage",
    id: RequestId,
    params: LogMessageParams,
};

/// The log message parameters.
pub const LogMessageParams = struct {
    /// The message type. See {@link MessageType}
    @"type": MessageType,

    /// The actual message
    message: []const u8,
};

/// The telemetry event notification is sent from the server to the client to ask
/// the client to log telemetry data.
pub const TelemetryEventNotification = struct {
    comptime method: []const u8 = "telemetry/event",
    id: RequestId,
    params: LSPAny,
};
pub const TextDocumentSyncClientCapabilities = struct {
    /// Whether text document synchronization supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// The client supports sending will save notifications.
    willSave: ?bool = null,

    /// The client supports sending a will save request and
    /// waits for a response providing text edits which will
    /// be applied to the document before it is saved.
    willSaveWaitUntil: ?bool = null,

    /// The client supports did save notifications.
    didSave: ?bool = null,
};

/// Defines how the host (editor) should sync
/// document changes to the language server.
pub const TextDocumentSyncKind = enum(i64) {
    None = 0,
    Full = 1,
    Incremental = 2,

    usingnamespace IntBackedEnumStringify(@This());
};
pub const TextDocumentSyncOptions = struct {
    /// Open and close notifications are sent to the server. If omitted open close notification should not
    /// be sent.
    openClose: ?bool = null,

    /// Change notifications are sent to the server. See TextDocumentSyncKind.None, TextDocumentSyncKind.Full
    /// and TextDocumentSyncKind.Incremental. If omitted it defaults to TextDocumentSyncKind.None.
    change: ?TextDocumentSyncKind = null,

    /// If present will save notifications are sent to the server. If omitted the notification should not be
    /// sent.
    willSave: ?bool = null,

    /// If present will save wait until requests are sent to the server. If omitted the request should not be
    /// sent.
    willSaveWaitUntil: ?bool = null,

    /// If present save notifications are sent to the server. If omitted the notification should not be
    /// sent.
    save: ?union(enum) {
        boolean: bool,
        SaveOptions: SaveOptions,
    } = null,
};

/// The parameters send in a open text document notification
pub const DidOpenTextDocumentParams = struct {
    /// The document that was opened.
    textDocument: TextDocumentItem,
};

/// The document open notification is sent from the client to the server to signal
/// newly opened text documents. The document's truth is now managed by the client
/// and the server must not try to read the document's truth using the document's
/// uri. Open in this sense means it is managed by the client. It doesn't necessarily
/// mean that its content is presented in an editor. An open notification must not
/// be sent more than once without a corresponding close notification send before.
/// This means open and close notification must be balanced and the max open count
/// is one.
pub const DidOpenTextDocumentNotification = struct {
    comptime method: []const u8 = "textDocument/didOpen",
    id: RequestId,
    params: DidOpenTextDocumentParams,
};

/// An event describing a change to a text document. If range and rangeLength are omitted
/// the new text is considered to be the full content of the document.
pub const TextDocumentContentChangeEvent = union(enum) {
    partial: struct {
        /// The range of the document that changed.
        range: Range,

        /// The optional length of the range that got replaced.
        rangeLength: ?i64 = null,

        /// The new text for the provided range.
        text: []const u8,
    },
    full: struct {
        /// The new text of the whole document.
        text: []const u8,
    },
};

/// The change text document notification's parameters.
pub const DidChangeTextDocumentParams = struct {
    /// The document that did change. The version number points
    /// to the version after all provided content changes have
    /// been applied.
    textDocument: VersionedTextDocumentIdentifier,

    /// The actual content changes. The content changes describe single state changes
    /// to the document. So if there are two content changes c1 (at array index 0) and
    /// c2 (at array index 1) for a document in state S then c1 moves the document from
    /// S to S' and c2 from S' to S''. So c1 is computed on the state S and c2 is computed
    /// on the state S'.
    contentChanges: []TextDocumentContentChangeEvent,
};

/// Describe options to be used when registered for text document change events.
pub const TextDocumentChangeRegistrationOptions = struct {
    /// How documents are synced to the server.
    syncKind: TextDocumentSyncKind,

    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
};

/// The document change notification is sent from the client to the server to signal
/// changes to a text document.
pub const DidChangeTextDocumentNotification = struct {
    comptime method: []const u8 = "textDocument/didChange",
    id: RequestId,
    params: DidChangeTextDocumentParams,
};

/// The parameters send in a close text document notification
pub const DidCloseTextDocumentParams = struct {
    /// The document that was closed.
    textDocument: TextDocumentIdentifier,
};

/// The document close notification is sent from the client to the server when
/// the document got closed in the client. The document's truth now exists where
/// the document's uri points to (e.g. if the document's uri is a file uri the
/// truth now exists on disk). As with the open notification the close notification
/// is about managing the document's content. Receiving a close notification
/// doesn't mean that the document was open in an editor before. A close
/// notification requires a previous open notification to be sent.
pub const DidCloseTextDocumentNotification = struct {
    comptime method: []const u8 = "textDocument/didClose",
    id: RequestId,
    params: DidCloseTextDocumentParams,
};

/// The parameters send in a save text document notification
pub const DidSaveTextDocumentParams = struct {
    /// The document that was closed.
    textDocument: TextDocumentIdentifier,

    /// Optional the content when saved. Depends on the includeText value
    /// when the save notification was requested.
    text: ?[]const u8 = null,
};

/// Save registration options.
pub const TextDocumentSaveRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// The client is supposed to include the content on save.
    includeText: ?bool = null,
};

/// The document save notification is sent from the client to the server when
/// the document got saved in the client.
pub const DidSaveTextDocumentNotification = struct {
    comptime method: []const u8 = "textDocument/didSave",
    id: RequestId,
    params: DidSaveTextDocumentParams,
};

/// Represents reasons why a text document is saved.
pub const TextDocumentSaveReason = enum(i64) {
    Manual = 1,
    AfterDelay = 2,
    FocusOut = 3,

    usingnamespace IntBackedEnumStringify(@This());
};

/// The parameters send in a will save text document notification.
pub const WillSaveTextDocumentParams = struct {
    /// The document that will be saved.
    textDocument: TextDocumentIdentifier,

    /// The 'TextDocumentSaveReason'.
    reason: TextDocumentSaveReason,
};

/// A document will save notification is sent from the client to the server before
/// the document is actually saved.
pub const WillSaveTextDocumentNotification = struct {
    comptime method: []const u8 = "textDocument/willSave",
    id: RequestId,
    params: WillSaveTextDocumentParams,
};

/// A document will save request is sent from the client to the server before
/// the document is actually saved. The request can return an array of TextEdits
/// which will be applied to the text document before it is saved. Please note that
/// clients might drop results if computing the text edits took too long or if a
/// server constantly fails on this request. This is done to keep the save fast and
/// reliable.
pub const WillSaveTextDocumentWaitUntilRequest = struct {
    comptime method: []const u8 = "textDocument/willSaveWaitUntil",
    id: RequestId,
    params: WillSaveTextDocumentParams,
};
pub const DidChangeWatchedFilesClientCapabilities = struct {
    /// Did change watched files notification supports dynamic registration. Please note
    /// that the current protocol doesn't support static configuration for file changes
    /// from the server side.
    dynamicRegistration: ?bool = null,
};

/// The watched files notification is sent from the client to the server when
/// the client detects changes to file watched by the language client.
pub const DidChangeWatchedFilesNotification = struct {
    comptime method: []const u8 = "workspace/didChangeWatchedFiles",
    id: RequestId,
    params: DidChangeWatchedFilesParams,
};

/// The watched files change notification's parameters.
pub const DidChangeWatchedFilesParams = struct {
    /// The actual file events.
    changes: []FileEvent,
};

/// The file event type
pub const FileChangeType = enum(i64) {
    Created = 1,
    Changed = 2,
    Deleted = 3,

    usingnamespace IntBackedEnumStringify(@This());
};

/// An event describing a file change.
pub const FileEvent = struct {
    /// The file's uri.
    uri: []const u8,

    /// The change type.
    @"type": FileChangeType,
};

/// Describe options to be used when registered for text document change events.
pub const DidChangeWatchedFilesRegistrationOptions = struct {
    /// The watchers to register.
    watchers: []FileSystemWatcher,
};
pub const FileSystemWatcher = struct {
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
    kind: ?i64 = null,
};
pub const WatchKind = enum(i64) {
    Create = 1,
    Change = 2,
    Delete = 4,

    usingnamespace IntBackedEnumStringify(@This());
};

/// The publish diagnostic client capabilities.
pub const PublishDiagnosticsClientCapabilities = struct {
    /// Whether the clients accepts diagnostics with related information.
    relatedInformation: ?bool = null,

    /// Client supports the tag property to provide meta data about a diagnostic.
    /// Clients supporting tags have to handle unknown tags gracefully.
    tagSupport: ?struct {
        /// The tags supported by the client.
        valueSet: []DiagnosticTag,
    } = null,

    /// Whether the client interprets the version property of the
    /// `textDocument/publishDiagnostics` notification`s parameter.
    versionSupport: ?bool = null,

    /// Client supports a codeDescription property
    codeDescriptionSupport: ?bool = null,

    /// Whether code action supports the `data` property which is
    /// preserved between a `textDocument/publishDiagnostics` and
    /// `textDocument/codeAction` request.
    dataSupport: ?bool = null,
};

/// The publish diagnostic notification's parameters.
pub const PublishDiagnosticsParams = struct {
    /// The URI for which diagnostic information is reported.
    uri: []const u8,

    /// Optional the version number of the document the diagnostics are published for.
    version: ?i64 = null,

    /// An array of diagnostic information items.
    diagnostics: []Diagnostic,
};

/// Diagnostics notification are sent from the server to the client to signal
/// results of validation runs.
pub const PublishDiagnosticsNotification = struct {
    comptime method: []const u8 = "textDocument/publishDiagnostics",
    id: RequestId,
    params: PublishDiagnosticsParams,
};

/// Completion client capabilities
pub const CompletionClientCapabilities = struct {
    /// Whether completion supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// The client supports the following `CompletionItem` specific
    /// capabilities.
    completionItem: ?struct {
        /// Client supports commit characters on a completion item.
        commitCharactersSupport: ?bool = null,

        /// Client supports the deprecated property on a completion item.
        deprecatedSupport: ?bool = null,

        /// Client supports the follow content formats for the documentation
        /// property. The order describes the preferred format of the client.
        documentationFormat: ?[]MarkupKind = null,

        /// Client support insert replace edit to control different behavior if a
        /// completion item is inserted in the text or should replace text.
        insertReplaceSupport: ?bool = null,

        /// The client supports the `insertTextMode` property on
        /// a completion item to override the whitespace handling mode
        /// as defined by the client (see `insertTextMode`).
        insertTextModeSupport: ?struct {
            valueSet: []InsertTextMode,
        } = null,

        /// Client supports the preselect property on a completion item.
        preselectSupport: ?bool = null,

        /// Indicates which properties a client can resolve lazily on a completion
        /// item. Before version 3.16.0 only the predefined properties `documentation`
        /// and `details` could be resolved lazily.
        resolveSupport: ?struct {
            /// The properties that a client can resolve lazily.
            properties: [][]const u8,
        } = null,

        /// Client supports snippets as insert text.
        snippetSupport: ?bool = null,

        /// Client supports the tag property on a completion item. Clients supporting
        /// tags have to handle unknown tags gracefully. Clients especially need to
        /// preserve unknown tags when sending a completion item back to the server in
        /// a resolve call.
        tagSupport: ?struct {
            /// The tags supported by the client.
            valueSet: []CompletionItemTag,
        } = null,
    } = null,
    completionItemKind: ?struct {
        /// The completion item kind values the client supports. When this
        /// property exists the client also guarantees that it will
        /// handle values outside its set gracefully and falls back
        /// to a default value when unknown.
        valueSet: ?[]CompletionItemKind = null,
    } = null,

    /// Defines how the client handles whitespace and indentation
    /// when accepting a completion item that uses multi line
    /// text in either `insertText` or `textEdit`.
    insertTextMode: ?InsertTextMode = null,

    /// The client supports to send additional context information for a
    /// `textDocument/completion` request.
    contextSupport: ?bool = null,
};

/// How a completion was triggered
pub const CompletionTriggerKind = enum(i64) {
    Invoked = 1,
    TriggerCharacter = 2,
    TriggerForIncompleteCompletions = 3,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Contains additional information about the context in which a completion request is triggered.
pub const CompletionContext = struct {
    /// How the completion was triggered.
    triggerKind: CompletionTriggerKind,

    /// The trigger character (a single character) that has trigger code complete.
    /// Is undefined if `triggerKind !== CompletionTriggerKind.TriggerCharacter`
    triggerCharacter: ?[]const u8 = null,
};

/// Completion parameters
pub const CompletionParams = struct {
    /// The completion context. This is only available it the client specifies
    /// to send this using the client capability `textDocument.completion.contextSupport === true`
    context: ?CompletionContext = null,

    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Completion options.
pub const CompletionOptions = struct {
    /// Most tools trigger completion request automatically without explicitly requesting
    /// it using a keyboard shortcut (e.g. Ctrl+Space). Typically they do so when the user
    /// starts to type an identifier. For example if the user types `c` in a JavaScript file
    /// code complete will automatically pop up present `console` besides others as a
    /// completion item. Characters that make up identifiers don't need to be listed here.
    triggerCharacters: ?[][]const u8 = null,

    /// The list of all possible characters that commit a completion. This field can be used
    /// if clients don't support individual commit characters per completion item. See
    /// `ClientCapabilities.textDocument.completion.completionItem.commitCharactersSupport`
    allCommitCharacters: ?[][]const u8 = null,

    /// The server provides support to resolve additional
    /// information for a completion item.
    resolveProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// Registration options for a [CompletionRequest](#CompletionRequest).
pub const CompletionRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// Most tools trigger completion request automatically without explicitly requesting
    /// it using a keyboard shortcut (e.g. Ctrl+Space). Typically they do so when the user
    /// starts to type an identifier. For example if the user types `c` in a JavaScript file
    /// code complete will automatically pop up present `console` besides others as a
    /// completion item. Characters that make up identifiers don't need to be listed here.
    triggerCharacters: ?[][]const u8 = null,

    /// The list of all possible characters that commit a completion. This field can be used
    /// if clients don't support individual commit characters per completion item. See
    /// `ClientCapabilities.textDocument.completion.completionItem.commitCharactersSupport`
    allCommitCharacters: ?[][]const u8 = null,

    /// The server provides support to resolve additional
    /// information for a completion item.
    resolveProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// Request to request completion at a given text document position. The request's
/// parameter is of type [TextDocumentPosition](#TextDocumentPosition) the response
/// is of type [CompletionItem[]](#CompletionItem) or [CompletionList](#CompletionList)
/// or a Thenable that resolves to such.
pub const CompletionRequest = struct {
    comptime method: []const u8 = "textDocument/completion",
    id: RequestId,
    params: CompletionParams,
};

/// Request to resolve additional information for a given completion item.The request's
/// parameter is of type [CompletionItem](#CompletionItem) the response
/// is of type [CompletionItem](#CompletionItem) or a Thenable that resolves to such.
pub const CompletionResolveRequest = struct {
    comptime method: []const u8 = "completionItem/resolve",
    id: RequestId,
    params: CompletionItem,
};
pub const HoverClientCapabilities = struct {
    /// Whether hover supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// Client supports the follow content formats for the content
    /// property. The order describes the preferred format of the client.
    contentFormat: ?[]MarkupKind = null,
};

/// Hover options.
pub const HoverOptions = struct {
    workDoneProgress: ?bool = null,
};

/// Parameters for a [HoverRequest](#HoverRequest).
pub const HoverParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};

/// Registration options for a [HoverRequest](#HoverRequest).
pub const HoverRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,
};

/// Request to request hover information at a given text document position. The request's
/// parameter is of type [TextDocumentPosition](#TextDocumentPosition) the response is of
/// type [Hover](#Hover) or a Thenable that resolves to such.
pub const HoverRequest = struct {
    comptime method: []const u8 = "textDocument/hover",
    id: RequestId,
    params: HoverParams,
};

/// Client Capabilities for a [SignatureHelpRequest](#SignatureHelpRequest).
pub const SignatureHelpClientCapabilities = struct {
    /// Whether signature help supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// The client supports the following `SignatureInformation`
    /// specific properties.
    signatureInformation: ?struct {
        /// The client support the `activeParameter` property on `SignatureInformation`
        /// literal.
        activeParameterSupport: ?bool = null,

        /// Client supports the follow content formats for the documentation
        /// property. The order describes the preferred format of the client.
        documentationFormat: ?[]MarkupKind = null,

        /// Client capabilities specific to parameter information.
        parameterInformation: ?struct {
            /// The client supports processing label offsets instead of a
            /// simple label string.
            labelOffsetSupport: ?bool = null,
        } = null,
    } = null,

    /// The client supports to send additional context information for a
    /// `textDocument/signatureHelp` request. A client that opts into
    /// contextSupport will also support the `retriggerCharacters` on
    /// `SignatureHelpOptions`.
    contextSupport: ?bool = null,
};

/// Server Capabilities for a [SignatureHelpRequest](#SignatureHelpRequest).
pub const SignatureHelpOptions = struct {
    /// List of characters that trigger signature help.
    triggerCharacters: ?[][]const u8 = null,

    /// List of characters that re-trigger signature help.
    retriggerCharacters: ?[][]const u8 = null,
    workDoneProgress: ?bool = null,
};

/// How a signature help was triggered.
pub const SignatureHelpTriggerKind = enum(i64) {
    Invoked = 1,
    TriggerCharacter = 2,
    ContentChange = 3,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Additional information about the context in which a signature help request was triggered.
pub const SignatureHelpContext = struct {
    /// Action that caused signature help to be triggered.
    triggerKind: SignatureHelpTriggerKind,

    /// Character that caused signature help to be triggered.
    triggerCharacter: ?[]const u8 = null,

    /// `true` if signature help was already showing when it was triggered.
    isRetrigger: bool,

    /// The currently active `SignatureHelp`.
    activeSignatureHelp: ?SignatureHelp = null,
};

/// Parameters for a [SignatureHelpRequest](#SignatureHelpRequest).
pub const SignatureHelpParams = struct {
    /// The signature help context. This is only available if the client specifies
    /// to send this using the client capability `textDocument.signatureHelp.contextSupport === true`
    context: ?SignatureHelpContext = null,

    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};

/// Registration options for a [SignatureHelpRequest](#SignatureHelpRequest).
pub const SignatureHelpRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// List of characters that trigger signature help.
    triggerCharacters: ?[][]const u8 = null,

    /// List of characters that re-trigger signature help.
    retriggerCharacters: ?[][]const u8 = null,
    workDoneProgress: ?bool = null,
};
pub const SignatureHelpRequest = struct {
    comptime method: []const u8 = "textDocument/signatureHelp",
    id: RequestId,
    params: SignatureHelpParams,
};

/// Client Capabilities for a [DefinitionRequest](#DefinitionRequest).
pub const DefinitionClientCapabilities = struct {
    /// Whether definition supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// The client supports additional metadata in the form of definition links.
    linkSupport: ?bool = null,
};

/// Server Capabilities for a [DefinitionRequest](#DefinitionRequest).
pub const DefinitionOptions = struct {
    workDoneProgress: ?bool = null,
};

/// Parameters for a [DefinitionRequest](#DefinitionRequest).
pub const DefinitionParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Registration options for a [DefinitionRequest](#DefinitionRequest).
pub const DefinitionRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,
};

/// A request to resolve the definition location of a symbol at a given text
/// document position. The request's parameter is of type [TextDocumentPosition]
/// (#TextDocumentPosition) the response is of either type [Definition](#Definition)
/// or a typed array of [DefinitionLink](#DefinitionLink) or a Thenable that resolves
/// to such.
pub const DefinitionRequest = struct {
    comptime method: []const u8 = "textDocument/definition",
    id: RequestId,
    params: DefinitionParams,
};

/// Client Capabilities for a [ReferencesRequest](#ReferencesRequest).
pub const ReferenceClientCapabilities = struct {
    /// Whether references supports dynamic registration.
    dynamicRegistration: ?bool = null,
};

/// Parameters for a [ReferencesRequest](#ReferencesRequest).
pub const ReferenceParams = struct {
    context: ReferenceContext,

    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Reference options.
pub const ReferenceOptions = struct {
    workDoneProgress: ?bool = null,
};

/// Registration options for a [ReferencesRequest](#ReferencesRequest).
pub const ReferenceRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,
};

/// A request to resolve project-wide references for the symbol denoted
/// by the given text document position. The request's parameter is of
/// type [ReferenceParams](#ReferenceParams) the response is of type
/// [Location[]](#Location) or a Thenable that resolves to such.
pub const ReferencesRequest = struct {
    comptime method: []const u8 = "textDocument/references",
    id: RequestId,
    params: ReferenceParams,
};

/// Client Capabilities for a [DocumentHighlightRequest](#DocumentHighlightRequest).
pub const DocumentHighlightClientCapabilities = struct {
    /// Whether document highlight supports dynamic registration.
    dynamicRegistration: ?bool = null,
};

/// Parameters for a [DocumentHighlightRequest](#DocumentHighlightRequest).
pub const DocumentHighlightParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Provider options for a [DocumentHighlightRequest](#DocumentHighlightRequest).
pub const DocumentHighlightOptions = struct {
    workDoneProgress: ?bool = null,
};

/// Registration options for a [DocumentHighlightRequest](#DocumentHighlightRequest).
pub const DocumentHighlightRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,
};

/// Request to resolve a [DocumentHighlight](#DocumentHighlight) for a given
/// text document position. The request's parameter is of type [TextDocumentPosition]
/// (#TextDocumentPosition) the request response is of type [DocumentHighlight[]]
/// (#DocumentHighlight) or a Thenable that resolves to such.
pub const DocumentHighlightRequest = struct {
    comptime method: []const u8 = "textDocument/documentHighlight",
    id: RequestId,
    params: DocumentHighlightParams,
};

/// Client Capabilities for a [DocumentSymbolRequest](#DocumentSymbolRequest).
pub const DocumentSymbolClientCapabilities = struct {
    /// Whether document symbol supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// Specific capabilities for the `SymbolKind`.
    symbolKind: ?struct {
        /// The symbol kind values the client supports. When this
        /// property exists the client also guarantees that it will
        /// handle values outside its set gracefully and falls back
        /// to a default value when unknown.
        valueSet: ?[]SymbolKind = null,
    } = null,

    /// The client support hierarchical document symbols.
    hierarchicalDocumentSymbolSupport: ?bool = null,

    /// The client supports tags on `SymbolInformation`. Tags are supported on
    /// `DocumentSymbol` if `hierarchicalDocumentSymbolSupport` is set to true.
    /// Clients supporting tags have to handle unknown tags gracefully.
    tagSupport: ?struct {
        /// The tags supported by the client.
        valueSet: []SymbolTag,
    } = null,

    /// The client supports an additional label presented in the UI when
    /// registering a document symbol provider.
    labelSupport: ?bool = null,
};

/// Parameters for a [DocumentSymbolRequest](#DocumentSymbolRequest).
pub const DocumentSymbolParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Provider options for a [DocumentSymbolRequest](#DocumentSymbolRequest).
pub const DocumentSymbolOptions = struct {
    /// A human-readable string that is shown when multiple outlines trees
    /// are shown for the same document.
    label: ?[]const u8 = null,
    workDoneProgress: ?bool = null,
};

/// Registration options for a [DocumentSymbolRequest](#DocumentSymbolRequest).
pub const DocumentSymbolRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// A human-readable string that is shown when multiple outlines trees
    /// are shown for the same document.
    label: ?[]const u8 = null,
    workDoneProgress: ?bool = null,
};

/// A request to list all symbols found in a given text document. The request's
/// parameter is of type [TextDocumentIdentifier](#TextDocumentIdentifier) the
/// response is of type [SymbolInformation[]](#SymbolInformation) or a Thenable
/// that resolves to such.
pub const DocumentSymbolRequest = struct {
    comptime method: []const u8 = "textDocument/documentSymbol",
    id: RequestId,
    params: DocumentSymbolParams,
};

/// The Client Capabilities of a [CodeActionRequest](#CodeActionRequest).
pub const CodeActionClientCapabilities = struct {
    /// Whether code action supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// The client support code action literals of type `CodeAction` as a valid
    /// response of the `textDocument/codeAction` request. If the property is not
    /// set the request can only return `Command` literals.
    codeActionLiteralSupport: ?struct {
        /// The code action kind is support with the following value
        /// set.
        codeActionKind: struct {
            /// The code action kind values the client supports. When this
            /// property exists the client also guarantees that it will
            /// handle values outside its set gracefully and falls back
            /// to a default value when unknown.
            valueSet: [][]const u8,
        },
    } = null,

    /// Whether code action supports the `isPreferred` property.
    isPreferredSupport: ?bool = null,

    /// Whether code action supports the `disabled` property.
    disabledSupport: ?bool = null,

    /// Whether code action supports the `data` property which is
    /// preserved between a `textDocument/codeAction` and a
    /// `codeAction/resolve` request.
    dataSupport: ?bool = null,

    /// Whether the client support resolving additional code action
    /// properties via a separate `codeAction/resolve` request.
    resolveSupport: ?struct {
        /// The properties that a client can resolve lazily.
        properties: [][]const u8,
    } = null,

    /// Whether th client honors the change annotations in
    /// text edits and resource operations returned via the
    /// `CodeAction#edit` property by for example presenting
    /// the workspace edit in the user interface and asking
    /// for confirmation.
    honorsChangeAnnotations: ?bool = null,
};

/// The parameters of a [CodeActionRequest](#CodeActionRequest).
pub const CodeActionParams = struct {
    /// The document in which the command was invoked.
    textDocument: TextDocumentIdentifier,

    /// The range for which the command was invoked.
    range: Range,

    /// Context carrying additional information.
    context: CodeActionContext,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Provider options for a [CodeActionRequest](#CodeActionRequest).
pub const CodeActionOptions = struct {
    /// CodeActionKinds that this server may return.
    codeActionKinds: ?[][]const u8 = null,

    /// The server provides support to resolve additional
    /// information for a code action.
    resolveProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// Registration options for a [CodeActionRequest](#CodeActionRequest).
pub const CodeActionRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// CodeActionKinds that this server may return.
    codeActionKinds: ?[][]const u8 = null,

    /// The server provides support to resolve additional
    /// information for a code action.
    resolveProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// A request to provide commands for the given text document and range.
pub const CodeActionRequest = struct {
    comptime method: []const u8 = "textDocument/codeAction",
    id: RequestId,
    params: CodeActionParams,
};

/// Request to resolve additional information for a given code action.The request's
/// parameter is of type [CodeAction](#CodeAction) the response
/// is of type [CodeAction](#CodeAction) or a Thenable that resolves to such.
pub const CodeActionResolveRequest = struct {
    comptime method: []const u8 = "codeAction/resolve",
    id: RequestId,
    params: CodeAction,
};

/// Client capabilities for a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
pub const WorkspaceSymbolClientCapabilities = struct {
    /// Symbol request supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// Specific capabilities for the `SymbolKind` in the `workspace/symbol` request.
    symbolKind: ?struct {
        /// The symbol kind values the client supports. When this
        /// property exists the client also guarantees that it will
        /// handle values outside its set gracefully and falls back
        /// to a default value when unknown.
        valueSet: ?[]SymbolKind = null,
    } = null,

    /// The client supports tags on `SymbolInformation`.
    /// Clients supporting tags have to handle unknown tags gracefully.
    tagSupport: ?struct {
        /// The tags supported by the client.
        valueSet: []SymbolTag,
    } = null,
};

/// The parameters of a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
pub const WorkspaceSymbolParams = struct {
    /// A query string to filter symbols by. Clients may send an empty
    /// string here to request all symbols.
    query: []const u8,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Server capabilities for a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
pub const WorkspaceSymbolOptions = struct {
    workDoneProgress: ?bool = null,
};

/// Registration options for a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
pub const WorkspaceSymbolRegistrationOptions = struct {
    workDoneProgress: ?bool = null,
};

/// A request to list project-wide symbols matching the query string given
/// by the [WorkspaceSymbolParams](#WorkspaceSymbolParams). The response is
/// of type [SymbolInformation[]](#SymbolInformation) or a Thenable that
/// resolves to such.
pub const WorkspaceSymbolRequest = struct {
    comptime method: []const u8 = "workspace/symbol",
    id: RequestId,
    params: WorkspaceSymbolParams,
};

/// The client capabilities  of a [CodeLensRequest](#CodeLensRequest).
pub const CodeLensClientCapabilities = struct {
    /// Whether code lens supports dynamic registration.
    dynamicRegistration: ?bool = null,
};
pub const CodeLensWorkspaceClientCapabilities = struct {
    /// Whether the client implementation supports a refresh request sent from the
    /// server to the client.
    refreshSupport: ?bool = null,
};

/// The parameters of a [CodeLensRequest](#CodeLensRequest).
pub const CodeLensParams = struct {
    /// The document to request code lens for.
    textDocument: TextDocumentIdentifier,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Code Lens provider options of a [CodeLensRequest](#CodeLensRequest).
pub const CodeLensOptions = struct {
    /// Code lens has a resolve provider as well.
    resolveProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// Registration options for a [CodeLensRequest](#CodeLensRequest).
pub const CodeLensRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// Code lens has a resolve provider as well.
    resolveProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// A request to provide code lens for the given text document.
pub const CodeLensRequest = struct {
    comptime method: []const u8 = "textDocument/codeLens",
    id: RequestId,
    params: CodeLensParams,
};

/// A request to resolve a command for a given code lens.
pub const CodeLensResolveRequest = struct {
    comptime method: []const u8 = "codeLens/resolve",
    id: RequestId,
    params: CodeLens,
};

/// A request to refresh all code actions
pub const CodeLensRefreshRequest = struct {
    comptime method: []const u8 = "workspace/codeLens/refresh",
    id: RequestId,
};

/// The client capabilities of a [DocumentLinkRequest](#DocumentLinkRequest).
pub const DocumentLinkClientCapabilities = struct {
    /// Whether document link supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// Whether the client support the `tooltip` property on `DocumentLink`.
    tooltipSupport: ?bool = null,
};

/// The parameters of a [DocumentLinkRequest](#DocumentLinkRequest).
pub const DocumentLinkParams = struct {
    /// The document to provide document links for.
    textDocument: TextDocumentIdentifier,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Provider options for a [DocumentLinkRequest](#DocumentLinkRequest).
pub const DocumentLinkOptions = struct {
    /// Document links have a resolve provider as well.
    resolveProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// Registration options for a [DocumentLinkRequest](#DocumentLinkRequest).
pub const DocumentLinkRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// Document links have a resolve provider as well.
    resolveProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// A request to provide document links
pub const DocumentLinkRequest = struct {
    comptime method: []const u8 = "textDocument/documentLink",
    id: RequestId,
    params: DocumentLinkParams,
};

/// Request to resolve additional information for a given document link. The request's
/// parameter is of type [DocumentLink](#DocumentLink) the response
/// is of type [DocumentLink](#DocumentLink) or a Thenable that resolves to such.
pub const DocumentLinkResolveRequest = struct {
    comptime method: []const u8 = "documentLink/resolve",
    id: RequestId,
    params: DocumentLink,
};

/// Client capabilities of a [DocumentFormattingRequest](#DocumentFormattingRequest).
pub const DocumentFormattingClientCapabilities = struct {
    /// Whether formatting supports dynamic registration.
    dynamicRegistration: ?bool = null,
};

/// The parameters of a [DocumentFormattingRequest](#DocumentFormattingRequest).
pub const DocumentFormattingParams = struct {
    /// The document to format.
    textDocument: TextDocumentIdentifier,

    /// The format options
    options: FormattingOptions,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};

/// Provider options for a [DocumentFormattingRequest](#DocumentFormattingRequest).
pub const DocumentFormattingOptions = struct {
    workDoneProgress: ?bool = null,
};

/// Registration options for a [DocumentFormattingRequest](#DocumentFormattingRequest).
pub const DocumentFormattingRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,
};

/// A request to to format a whole document.
pub const DocumentFormattingRequest = struct {
    comptime method: []const u8 = "textDocument/formatting",
    id: RequestId,
    params: DocumentFormattingParams,
};

/// Client capabilities of a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
pub const DocumentRangeFormattingClientCapabilities = struct {
    /// Whether range formatting supports dynamic registration.
    dynamicRegistration: ?bool = null,
};

/// The parameters of a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
pub const DocumentRangeFormattingParams = struct {
    /// The document to format.
    textDocument: TextDocumentIdentifier,

    /// The range to format
    range: Range,

    /// The format options
    options: FormattingOptions,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};

/// Provider options for a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
pub const DocumentRangeFormattingOptions = struct {
    workDoneProgress: ?bool = null,
};

/// Registration options for a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
pub const DocumentRangeFormattingRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,
};

/// A request to to format a range in a document.
pub const DocumentRangeFormattingRequest = struct {
    comptime method: []const u8 = "textDocument/rangeFormatting",
    id: RequestId,
    params: DocumentRangeFormattingParams,
};

/// Client capabilities of a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
pub const DocumentOnTypeFormattingClientCapabilities = struct {
    /// Whether on type formatting supports dynamic registration.
    dynamicRegistration: ?bool = null,
};

/// The parameters of a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
pub const DocumentOnTypeFormattingParams = struct {
    /// The document to format.
    textDocument: TextDocumentIdentifier,

    /// The position at which this request was send.
    position: Position,

    /// The character that has been typed.
    ch: []const u8,

    /// The format options.
    options: FormattingOptions,
};

/// Provider options for a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
pub const DocumentOnTypeFormattingOptions = struct {
    /// A character on which formatting should be triggered, like `}`.
    firstTriggerCharacter: []const u8,

    /// More trigger characters.
    moreTriggerCharacter: ?[][]const u8 = null,
};

/// Registration options for a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
pub const DocumentOnTypeFormattingRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// A character on which formatting should be triggered, like `}`.
    firstTriggerCharacter: []const u8,

    /// More trigger characters.
    moreTriggerCharacter: ?[][]const u8 = null,
};

/// A request to format a document on type.
pub const DocumentOnTypeFormattingRequest = struct {
    comptime method: []const u8 = "textDocument/onTypeFormatting",
    id: RequestId,
    params: DocumentOnTypeFormattingParams,
};
pub const PrepareSupportDefaultBehavior = enum(i64) {
    Identifier = 1,

    usingnamespace IntBackedEnumStringify(@This());
};
pub const RenameClientCapabilities = struct {
    /// Whether rename supports dynamic registration.
    dynamicRegistration: ?bool = null,

    /// Client supports testing for validity of rename operations
    /// before execution.
    prepareSupport: ?bool = null,

    /// Client supports the default behavior result.
    comptime prepareSupportDefaultBehavior: i64 = 1,

    /// Whether th client honors the change annotations in
    /// text edits and resource operations returned via the
    /// rename request's workspace edit by for example presenting
    /// the workspace edit in the user interface and asking
    /// for confirmation.
    honorsChangeAnnotations: ?bool = null,
};

/// The parameters of a [RenameRequest](#RenameRequest).
pub const RenameParams = struct {
    /// The document to rename.
    textDocument: TextDocumentIdentifier,

    /// The position at which this request was sent.
    position: Position,

    /// The new name of the symbol. If the given name is not valid the
    /// request must return a [ResponseError](#ResponseError) with an
    /// appropriate message set.
    newName: []const u8,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};

/// Provider options for a [RenameRequest](#RenameRequest).
pub const RenameOptions = struct {
    /// Renames should be checked and tested before being executed.
    prepareProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// Registration options for a [RenameRequest](#RenameRequest).
pub const RenameRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// Renames should be checked and tested before being executed.
    prepareProvider: ?bool = null,
    workDoneProgress: ?bool = null,
};

/// A request to rename a symbol.
pub const RenameRequest = struct {
    comptime method: []const u8 = "textDocument/rename",
    id: RequestId,
    params: RenameParams,
};
pub const PrepareRenameParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};

/// A request to test and perform the setup necessary for a rename.
pub const PrepareRenameRequest = struct {
    comptime method: []const u8 = "textDocument/prepareRename",
    id: RequestId,
    params: PrepareRenameParams,
};

/// The client capabilities of a [ExecuteCommandRequest](#ExecuteCommandRequest).
pub const ExecuteCommandClientCapabilities = struct {
    /// Execute command supports dynamic registration.
    dynamicRegistration: ?bool = null,
};

/// The parameters of a [ExecuteCommandRequest](#ExecuteCommandRequest).
pub const ExecuteCommandParams = struct {
    /// The identifier of the actual command handler.
    command: []const u8,

    /// Arguments that the command should be invoked with.
    arguments: ?[]json.Value = null,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};

/// The server capabilities of a [ExecuteCommandRequest](#ExecuteCommandRequest).
pub const ExecuteCommandOptions = struct {
    /// The commands to be executed on the server
    commands: [][]const u8,
    workDoneProgress: ?bool = null,
};

/// Registration options for a [ExecuteCommandRequest](#ExecuteCommandRequest).
pub const ExecuteCommandRegistrationOptions = struct {
    /// The commands to be executed on the server
    commands: [][]const u8,
    workDoneProgress: ?bool = null,
};

/// A request send from the client to the server to execute a command. The request might return
/// a workspace edit which the client will apply to the workspace.
pub const ExecuteCommandRequest = struct {
    comptime method: []const u8 = "workspace/executeCommand",
    id: RequestId,
    params: ExecuteCommandParams,
};
pub const WorkspaceEditClientCapabilities = struct {
    /// The client supports versioned document changes in `WorkspaceEdit`s
    documentChanges: ?bool = null,

    /// The resource operations the client supports. Clients should at least
    /// support 'create', 'rename' and 'delete' files and folders.
    resourceOperations: ?[]ResourceOperationKind = null,

    /// The failure handling strategy of a client if applying the workspace edit
    /// fails.
    failureHandling: ?FailureHandlingKind = null,

    /// Whether the client normalizes line endings to the client specific
    /// setting.
    /// If set to `true` the client will normalize line ending characters
    /// in a workspace edit containing to the client specific new line
    /// character.
    normalizesLineEndings: ?bool = null,

    /// Whether the client in general supports change annotations on text edits,
    /// create file, rename file and delete file changes.
    changeAnnotationSupport: ?struct {
        /// Whether the client groups edits with equal labels into tree nodes,
        /// for instance all edits labelled with "Changes in Strings" would
        /// be a tree node.
        groupsOnLabel: ?bool = null,
    } = null,
};

/// The parameters passed via a apply workspace edit request.
pub const ApplyWorkspaceEditParams = struct {
    /// An optional label of the workspace edit. This label is
    /// presented in the user interface for example on an undo
    /// stack to undo the workspace edit.
    label: ?[]const u8 = null,

    /// The edits to apply.
    edit: WorkspaceEdit,
};

/// A response returned from the apply workspace edit request.
pub const ApplyWorkspaceEditResponse = struct {
    /// Indicates whether the edit was applied or not.
    applied: bool,

    /// An optional textual description for why the edit was not applied.
    /// This may be used by the server for diagnostic logging or to provide
    /// a suitable error for a request that triggered the edit.
    failureReason: ?[]const u8 = null,

    /// Depending on the client's failure handling strategy `failedChange` might
    /// contain the index of the change that failed. This property is only available
    /// if the client signals a `failureHandlingStrategy` in its client capabilities.
    failedChange: ?i64 = null,
};

/// A request sent from the server to the client to modified certain resources.
pub const ApplyWorkspaceEditRequest = struct {
    comptime method: []const u8 = "workspace/applyEdit",
    id: RequestId,
    params: ApplyWorkspaceEditParams,
};

/// A request to resolve the implementation locations of a symbol at a given text
/// document position. The request's parameter is of type [TextDocumentPositioParams]
/// (#TextDocumentPositionParams) the response is of type [Definition](#Definition) or a
/// Thenable that resolves to such.
pub const ImplementationRequest = struct {
    comptime method: []const u8 = "textDocument/implementation",
    id: RequestId,
    params: ImplementationParams,
};
pub const ImplementationParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};
pub const ImplementationRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,

    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
};
pub const ImplementationOptions = struct {
    workDoneProgress: ?bool = null,
};

/// A request to resolve the type definition locations of a symbol at a given text
/// document position. The request's parameter is of type [TextDocumentPositioParams]
/// (#TextDocumentPositionParams) the response is of type [Definition](#Definition) or a
/// Thenable that resolves to such.
pub const TypeDefinitionRequest = struct {
    comptime method: []const u8 = "textDocument/typeDefinition",
    id: RequestId,
    params: TypeDefinitionParams,
};
pub const TypeDefinitionParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};
pub const TypeDefinitionRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,

    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
};
pub const TypeDefinitionOptions = struct {
    workDoneProgress: ?bool = null,
};

/// The `workspace/workspaceFolders` is sent from the server to the client to fetch the open workspace folders.
pub const WorkspaceFoldersRequest = struct {
    comptime method: []const u8 = "workspace/workspaceFolders",
    id: RequestId,
};

/// The `workspace/didChangeWorkspaceFolders` notification is sent from the client to the server when the workspace
/// folder configuration changes.
pub const DidChangeWorkspaceFoldersNotification = struct {
    comptime method: []const u8 = "workspace/didChangeWorkspaceFolders",
    id: RequestId,
    params: DidChangeWorkspaceFoldersParams,
};

/// The parameters of a `workspace/didChangeWorkspaceFolders` notification.
pub const DidChangeWorkspaceFoldersParams = struct {
    /// The actual workspace folder change event.
    event: WorkspaceFoldersChangeEvent,
};
pub const WorkspaceFolder = struct {
    /// The associated URI for this workspace folder.
    uri: []const u8,

    /// The name of the workspace folder. Used to refer to this
    /// workspace folder in the user interface.
    name: []const u8,
};

/// The workspace folder change event.
pub const WorkspaceFoldersChangeEvent = struct {
    /// The array of added workspace folders
    added: []WorkspaceFolder,

    /// The array of the removed workspace folders
    removed: []WorkspaceFolder,
};

/// The 'workspace/configuration' request is sent from the server to the client to fetch a certain
/// configuration setting.
pub const ConfigurationRequest = struct {
    comptime method: []const u8 = "workspace/configuration",
    id: RequestId,
    params: ConfigurationParams,
};

/// The parameters of a configuration request.
pub const ConfigurationParams = struct {
    items: []ConfigurationItem,
};
pub const ConfigurationItem = struct {
    /// The scope to get the configuration section for.
    scopeUri: ?[]const u8 = null,

    /// The configuration section asked for.
    section: ?[]const u8 = null,
};

/// A request to list all color symbols found in a given text document. The request's
/// parameter is of type [DocumentColorParams](#DocumentColorParams) the
/// response is of type [ColorInformation[]](#ColorInformation) or a Thenable
/// that resolves to such.
pub const DocumentColorRequest = struct {
    comptime method: []const u8 = "textDocument/documentColor",
    id: RequestId,
    params: DocumentColorParams,
};

/// A request to list all presentation for a color. The request's
/// parameter is of type [ColorPresentationParams](#ColorPresentationParams) the
/// response is of type [ColorInformation[]](#ColorInformation) or a Thenable
/// that resolves to such.
pub const ColorPresentationRequest = struct {
    comptime method: []const u8 = "textDocument/colorPresentation",
    id: RequestId,
    params: ColorPresentationParams,
};
pub const DocumentColorOptions = struct {
    workDoneProgress: ?bool = null,
};

/// Parameters for a [DocumentColorRequest](#DocumentColorRequest).
pub const DocumentColorParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// Parameters for a [ColorPresentationRequest](#ColorPresentationRequest).
pub const ColorPresentationParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The color to request presentations for.
    color: Color,

    /// The range where the color would be inserted. Serves as a context.
    range: Range,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};
pub const DocumentColorRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
    workDoneProgress: ?bool = null,
};
pub const FoldingRangeClientCapabilities = struct {
    /// Whether implementation supports dynamic registration for folding range providers. If this is set to `true`
    /// the client supports the new `FoldingRangeRegistrationOptions` return value for the corresponding server
    /// capability as well.
    dynamicRegistration: ?bool = null,

    /// The maximum number of folding ranges that the client prefers to receive per document. The value serves as a
    /// hint, servers are free to follow the limit.
    rangeLimit: ?i64 = null,

    /// If set, the client signals that it only supports folding complete lines. If set, client will
    /// ignore specified `startCharacter` and `endCharacter` properties in a FoldingRange.
    lineFoldingOnly: ?bool = null,
};
pub const FoldingRangeOptions = struct {
    workDoneProgress: ?bool = null,
};

/// A request to provide folding ranges in a document. The request's
/// parameter is of type [FoldingRangeParams](#FoldingRangeParams), the
/// response is of type [FoldingRangeList](#FoldingRangeList) or a Thenable
/// that resolves to such.
pub const FoldingRangeRequest = struct {
    comptime method: []const u8 = "textDocument/foldingRange",
    id: RequestId,
    params: FoldingRangeParams,
};

/// Parameters for a [FoldingRangeRequest](#FoldingRangeRequest).
pub const FoldingRangeParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};
pub const FoldingRangeRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,

    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
};
pub const DeclarationClientCapabilities = struct {
    /// Whether declaration supports dynamic registration. If this is set to `true`
    /// the client supports the new `DeclarationRegistrationOptions` return value
    /// for the corresponding server capability as well.
    dynamicRegistration: ?bool = null,

    /// The client supports additional metadata in the form of declaration links.
    linkSupport: ?bool = null,
};

/// A request to resolve the type definition locations of a symbol at a given text
/// document position. The request's parameter is of type [TextDocumentPositioParams]
/// (#TextDocumentPositionParams) the response is of type [Declaration](#Declaration)
/// or a typed array of [DeclarationLink](#DeclarationLink) or a Thenable that resolves
/// to such.
pub const DeclarationRequest = struct {
    comptime method: []const u8 = "textDocument/declaration",
    id: RequestId,
    params: DeclarationParams,
};
pub const DeclarationParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};
pub const DeclarationRegistrationOptions = struct {
    workDoneProgress: ?bool = null,

    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
};
pub const DeclarationOptions = struct {
    workDoneProgress: ?bool = null,
};
pub const SelectionRangeClientCapabilities = struct {
    /// Whether implementation supports dynamic registration for selection range providers. If this is set to `true`
    /// the client supports the new `SelectionRangeRegistrationOptions` return value for the corresponding server
    /// capability as well.
    dynamicRegistration: ?bool = null,
};
pub const SelectionRangeOptions = struct {
    workDoneProgress: ?bool = null,
};

/// A parameter literal used in selection range requests.
pub const SelectionRangeParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The positions inside the text document.
    positions: []Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// A request to provide selection ranges in a document. The request's
/// parameter is of type [SelectionRangeParams](#SelectionRangeParams), the
/// response is of type [SelectionRange[]](#SelectionRange[]) or a Thenable
/// that resolves to such.
pub const SelectionRangeRequest = struct {
    comptime method: []const u8 = "textDocument/selectionRange",
    id: RequestId,
    params: SelectionRangeParams,
};
pub const SelectionRangeRegistrationOptions = struct {
    workDoneProgress: ?bool = null,

    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
};
pub const WorkDoneProgressBegin = struct {
    comptime kind: []const u8 = "begin",

    /// Mandatory title of the progress operation. Used to briefly inform about
    /// the kind of operation being performed.
    title: []const u8,

    /// Controls if a cancel button should show to allow the user to cancel the
    /// long running operation. Clients that don't support cancellation are allowed
    /// to ignore the setting.
    cancellable: ?bool = null,

    /// Optional, more detailed associated progress message. Contains
    /// complementary information to the `title`.
    message: ?[]const u8 = null,

    /// Optional progress percentage to display (value 100 is considered 100%).
    /// If not provided infinite progress is assumed and clients are allowed
    /// to ignore the `percentage` value in subsequent in report notifications.
    percentage: ?i64 = null,
};
pub const WorkDoneProgressReport = struct {
    comptime kind: []const u8 = "report",

    /// Controls enablement state of a cancel button.
    cancellable: ?bool = null,

    /// Optional, more detailed associated progress message. Contains
    /// complementary information to the `title`.
    message: ?[]const u8 = null,

    /// Optional progress percentage to display (value 100 is considered 100%).
    /// If not provided infinite progress is assumed and clients are allowed
    /// to ignore the `percentage` value in subsequent in report notifications.
    percentage: ?i64 = null,
};
pub const WorkDoneProgressEnd = struct {
    comptime kind: []const u8 = "end",

    /// Optional, a final message indicating to for example indicate the outcome
    /// of the operation.
    message: ?[]const u8 = null,
};
pub const WorkDoneProgressCreateParams = struct {
    /// The token to be used to report progress.
    token: ProgressToken,
};

/// The `window/workDoneProgress/create` request is sent from the server to the client to initiate progress
/// reporting from the server.
pub const WorkDoneProgressCreateRequest = struct {
    comptime method: []const u8 = "window/workDoneProgress/create",
    id: RequestId,
    params: WorkDoneProgressCreateParams,
};
pub const WorkDoneProgressCancelParams = struct {
    /// The token to be used to report progress.
    token: ProgressToken,
};

/// The `window/workDoneProgress/cancel` notification is sent from  the client to the server to cancel a progress
/// initiated on the server side.
pub const WorkDoneProgressCancelNotification = struct {
    comptime method: []const u8 = "window/workDoneProgress/cancel",
    id: RequestId,
    params: WorkDoneProgressCancelParams,
};
pub const CallHierarchyClientCapabilities = struct {
    /// Whether implementation supports dynamic registration. If this is set to `true`
    /// the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
    /// return value for the corresponding server capability as well.
    dynamicRegistration: ?bool = null,
};

/// Call hierarchy options used during static registration.
pub const CallHierarchyOptions = struct {
    workDoneProgress: ?bool = null,
};

/// Call hierarchy options used during static or dynamic registration.
pub const CallHierarchyRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,

    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
};

/// The parameter of a `callHierarchy/incomingCalls` request.
pub const CallHierarchyIncomingCallsParams = struct {
    item: CallHierarchyItem,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// A request to resolve the incoming calls for a given `CallHierarchyItem`.
pub const CallHierarchyIncomingCallsRequest = struct {
    comptime method: []const u8 = "callHierarchy/incomingCalls",
    id: RequestId,
    params: CallHierarchyIncomingCallsParams,
};

/// The parameter of a `callHierarchy/outgoingCalls` request.
pub const CallHierarchyOutgoingCallsParams = struct {
    item: CallHierarchyItem,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// A request to resolve the outgoing calls for a given `CallHierarchyItem`.
pub const CallHierarchyOutgoingCallsRequest = struct {
    comptime method: []const u8 = "callHierarchy/outgoingCalls",
    id: RequestId,
    params: CallHierarchyOutgoingCallsParams,
};

/// The parameter of a `textDocument/prepareCallHierarchy` request.
pub const CallHierarchyPrepareParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};

/// A request to result a `CallHierarchyItem` in a document at a given position.
/// Can be used as an input to a incoming or outgoing call hierarchy.
pub const CallHierarchyPrepareRequest = struct {
    comptime method: []const u8 = "textDocument/prepareCallHierarchy",
    id: RequestId,
    params: CallHierarchyPrepareParams,
};

/// A set of predefined token types. This set is not fixed
/// an clients can specify additional token types via the
/// corresponding client capabilities.
pub const SemanticTokenTypes = struct {
    pub const class = "class";
    pub const comment = "comment";
    pub const @"enum" = "enum";
    pub const enumMember = "enumMember";
    pub const event = "event";
    pub const function = "function";
    pub const interface = "interface";
    pub const keyword = "keyword";
    pub const macro = "macro";
    pub const method = "method";
    pub const modifier = "modifier";
    pub const namespace = "namespace";
    pub const number = "number";
    pub const operator = "operator";
    pub const parameter = "parameter";
    pub const property = "property";
    pub const regexp = "regexp";
    pub const string = "string";
    pub const @"struct" = "struct";
    pub const @"type" = "type";
    pub const typeParameter = "typeParameter";
    pub const variable = "variable";
};
/// A set of predefined token modifiers. This set is not fixed
/// an clients can specify additional token types via the
/// corresponding client capabilities.
pub const SemanticTokenModifiers = struct {
    pub const abstract = "abstract";
    pub const @"async" = "async";
    pub const declaration = "declaration";
    pub const defaultLibrary = "defaultLibrary";
    pub const definition = "definition";
    pub const deprecated = "deprecated";
    pub const documentation = "documentation";
    pub const modification = "modification";
    pub const readonly = "readonly";
    pub const static = "static";
};
pub const SemanticTokensLegend = struct {
    /// The token types a server uses.
    tokenTypes: [][]const u8,

    /// The token modifiers a server uses.
    tokenModifiers: [][]const u8,
};
pub const SemanticTokens = struct {
    /// An optional result id. If provided and clients support delta updating
    /// the client will include the result id in the next semantic token request.
    /// A server can then instead of computing all semantic tokens again simply
    /// send a delta.
    resultId: ?[]const u8 = null,

    /// The actual tokens.
    data: []i64,
};
pub const SemanticTokensPartialResult = struct {
    data: []i64,
};
pub const SemanticTokensEdit = struct {
    /// The start offset of the edit.
    start: i64,

    /// The count of elements to remove.
    deleteCount: i64,

    /// The elements to insert.
    data: ?[]i64 = null,
};
pub const SemanticTokensDelta = struct {
    resultId: ?[]const u8 = null,

    /// The semantic token edits to transform a previous result into a new result.
    edits: []SemanticTokensEdit,
};
pub const SemanticTokensDeltaPartialResult = struct {
    edits: []SemanticTokensEdit,
};
pub const TokenFormat = struct {
    pub const Relative = "relative";
};
pub const SemanticTokensClientCapabilities = struct {
    /// Whether implementation supports dynamic registration. If this is set to `true`
    /// the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
    /// return value for the corresponding server capability as well.
    dynamicRegistration: ?bool = null,

    /// Which requests the client supports and might send to the server
    /// depending on the server's capability. Please note that clients might not
    /// show semantic tokens or degrade some of the user experience if a range
    /// or full request is advertised by the client but not provided by the
    /// server. If for example the client capability `requests.full` and
    /// `request.range` are both set to true but the server only provides a
    /// range provider the client might not render a minimap correctly or might
    /// even decide to not show any semantic tokens at all.
    requests: struct {
        /// The client will send the `textDocument/semanticTokens/full` request if
        /// the server provides a corresponding handler.
        full: ?union(enum) {
            boolean: bool,
            reflection: struct {
                /// The client will send the `textDocument/semanticTokens/full/delta` request if
                /// the server provides a corresponding handler.
                delta: ?bool = null,
            },
        } = null,

        /// The client will send the `textDocument/semanticTokens/range` request if
        /// the server provides a corresponding handler.
        range: ?union(enum) {
            boolean: bool,
            object: json.ObjectMap,
        } = null,
    },

    /// The token types that the client supports.
    tokenTypes: [][]const u8,

    /// The token modifiers that the client supports.
    tokenModifiers: [][]const u8,

    /// The token formats the clients supports.
    formats: []TokenFormat,

    /// Whether the client supports tokens that can overlap each other.
    overlappingTokenSupport: ?bool = null,

    /// Whether the client supports tokens that can span multiple lines.
    multilineTokenSupport: ?bool = null,
};
pub const SemanticTokensOptions = struct {
    /// The legend used by the server
    legend: SemanticTokensLegend,

    /// Server supports providing semantic tokens for a specific range
    /// of a document.
    range: ?union(enum) {
        boolean: bool,
        object: json.ObjectMap,
    } = null,

    /// Server supports providing semantic tokens for a full document.
    full: ?union(enum) {
        boolean: bool,
        reflection: struct {
            /// The server supports deltas for full documents.
            delta: ?bool = null,
        },
    } = null,
    workDoneProgress: ?bool = null,
};
pub const SemanticTokensRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,

    /// The legend used by the server
    legend: SemanticTokensLegend,

    /// Server supports providing semantic tokens for a specific range
    /// of a document.
    range: ?union(enum) {
        boolean: bool,
        object: json.ObjectMap,
    } = null,

    /// Server supports providing semantic tokens for a full document.
    full: ?union(enum) {
        boolean: bool,
        reflection: struct {
            /// The server supports deltas for full documents.
            delta: ?bool = null,
        },
    } = null,
    workDoneProgress: ?bool = null,

    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
};
pub const SemanticTokensParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};
pub const SemanticTokensRequest = struct {
    comptime method: []const u8 = "textDocument/semanticTokens/full",
    id: RequestId,
    params: SemanticTokensParams,
};
pub const SemanticTokensDeltaParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The result id of a previous response. The result Id can either point to a full response
    /// or a delta response depending on what was received last.
    previousResultId: []const u8,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};
pub const SemanticTokensDeltaRequest = struct {
    comptime method: []const u8 = "textDocument/semanticTokens/full/delta",
    id: RequestId,
    params: SemanticTokensDeltaParams,
};
pub const SemanticTokensRangeParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The range the semantic tokens are requested for.
    range: Range,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};
pub const SemanticTokensRangeRequest = struct {
    comptime method: []const u8 = "textDocument/semanticTokens/range",
    id: RequestId,
    params: SemanticTokensRangeParams,
};
pub const SemanticTokensRefreshRequest = struct {
    comptime method: []const u8 = "workspace/semanticTokens/refresh",
    id: RequestId,
};

/// Params to show a document.
pub const ShowDocumentParams = struct {
    /// The document uri to show.
    uri: []const u8,

    /// Indicates to show the resource in an external program.
    /// To show for example `https://code.visualstudio.com/`
    /// in the default WEB browser set `external` to `true`.
    external: ?bool = null,

    /// An optional property to indicate whether the editor
    /// showing the document should take focus or not.
    /// Clients might ignore this property if an external
    /// program in started.
    takeFocus: ?bool = null,

    /// An optional selection range if the document is a text
    /// document. Clients might ignore the property if an
    /// external program is started or the file is not a text
    /// file.
    selection: ?Range = null,
};

/// A request to show a document. This request might open an
/// external program depending on the value of the URI to open.
/// For example a request to open `https://code.visualstudio.com/`
/// will very likely open the URI in a WEB browser.
pub const ShowDocumentRequest = struct {
    comptime method: []const u8 = "window/showDocument",
    id: RequestId,
    params: ShowDocumentParams,
};

/// The result of an show document request.
pub const ShowDocumentResult = struct {
    /// A boolean indicating if the show was successful.
    success: bool,
};

/// Client capabilities for the show document request.
pub const ShowDocumentClientCapabilities = struct {
    /// The client has support for the show document
    /// request.
    support: bool,
};

/// Client capabilities for the linked editing range request.
pub const LinkedEditingRangeClientCapabilities = struct {
    /// Whether implementation supports dynamic registration. If this is set to `true`
    /// the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
    /// return value for the corresponding server capability as well.
    dynamicRegistration: ?bool = null,
};

/// The result of a linked editing range request.
pub const LinkedEditingRanges = struct {
    /// A list of ranges that can be edited together. The ranges must have
    /// identical length and contain identical text content. The ranges cannot overlap.
    ranges: []Range,

    /// An optional word pattern (regular expression) that describes valid contents for
    /// the given ranges. If no pattern is provided, the client configuration's word
    /// pattern will be used.
    wordPattern: ?[]const u8 = null,
};
pub const LinkedEditingRangeOptions = struct {
    workDoneProgress: ?bool = null,
};
pub const LinkedEditingRangeParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,
};
pub const LinkedEditingRangeRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,

    /// The id used to register the request. The id can be used to deregister
    /// the request again. See also Registration#id.
    id: ?[]const u8 = null,
};

/// A request to provide ranges that can be edited together.
pub const LinkedEditingRangeRequest = struct {
    comptime method: []const u8 = "textDocument/linkedEditingRange",
    id: RequestId,
    params: LinkedEditingRangeParams,
};

/// Options for notifications/requests for user operations on files.
pub const FileOperationOptions = struct {
    /// The server is interested in didCreateFiles notifications.
    didCreate: ?FileOperationRegistrationOptions = null,

    /// The server is interested in willCreateFiles requests.
    willCreate: ?FileOperationRegistrationOptions = null,

    /// The server is interested in didRenameFiles notifications.
    didRename: ?FileOperationRegistrationOptions = null,

    /// The server is interested in willRenameFiles requests.
    willRename: ?FileOperationRegistrationOptions = null,

    /// The server is interested in didDeleteFiles file notifications.
    didDelete: ?FileOperationRegistrationOptions = null,

    /// The server is interested in willDeleteFiles file requests.
    willDelete: ?FileOperationRegistrationOptions = null,
};

/// Capabilities relating to events from file operations by the user in the client.
pub const FileOperationClientCapabilities = struct {
    /// Whether the client supports dynamic registration for file requests/notifications.
    dynamicRegistration: ?bool = null,

    /// The client has support for sending didCreateFiles notifications.
    didCreate: ?bool = null,

    /// The client has support for willCreateFiles requests.
    willCreate: ?bool = null,

    /// The client has support for sending didRenameFiles notifications.
    didRename: ?bool = null,

    /// The client has support for willRenameFiles requests.
    willRename: ?bool = null,

    /// The client has support for sending didDeleteFiles notifications.
    didDelete: ?bool = null,

    /// The client has support for willDeleteFiles requests.
    willDelete: ?bool = null,
};

/// The options to register for file operations.
pub const FileOperationRegistrationOptions = struct {
    /// The actual filters.
    filters: []FileOperationFilter,
};

/// Matching options for the file operation pattern.
pub const FileOperationPatternOptions = struct {
    /// The pattern should be matched ignoring casing.
    ignoreCase: ?bool = null,
};

/// A pattern kind describing if a glob pattern matches a file a folder or
/// both.
pub const FileOperationPatternKind = struct {
    /// The pattern matches a file only.
    pub const file = "file";
    /// The pattern matches a folder only.
    pub const folder = "folder";
};

/// The did create files notification is sent from the client to the server when
/// files were created from within the client.
pub const DidCreateFilesNotification = struct {
    comptime method: []const u8 = "workspace/didCreateFiles",
    id: RequestId,
    params: CreateFilesParams,
};

/// The parameters sent in file create requests/notifications.
pub const CreateFilesParams = struct {
    /// An array of all files/folders created in this operation.
    files: []FileCreate,
};

/// Represents information on a file/folder create.
pub const FileCreate = struct {
    /// A file:// URI for the location of the file/folder being created.
    uri: []const u8,
};

/// The will create files request is sent from the client to the server before files are actually
/// created as long as the creation is triggered from within the client.
pub const WillCreateFilesRequest = struct {
    comptime method: []const u8 = "workspace/willCreateFiles",
    id: RequestId,
    params: CreateFilesParams,
};

/// The did rename files notification is sent from the client to the server when
/// files were renamed from within the client.
pub const DidRenameFilesNotification = struct {
    comptime method: []const u8 = "workspace/didRenameFiles",
    id: RequestId,
    params: RenameFilesParams,
};

/// The parameters sent in file rename requests/notifications.
pub const RenameFilesParams = struct {
    /// An array of all files/folders renamed in this operation. When a folder is renamed, only
    /// the folder will be included, and not its children.
    files: []FileRename,
};

/// Represents information on a file/folder rename.
pub const FileRename = struct {
    /// A file:// URI for the original location of the file/folder being renamed.
    oldUri: []const u8,

    /// A file:// URI for the new location of the file/folder being renamed.
    newUri: []const u8,
};

/// The will rename files request is sent from the client to the server before files are actually
/// renamed as long as the rename is triggered from within the client.
pub const WillRenameFilesRequest = struct {
    comptime method: []const u8 = "workspace/willRenameFiles",
    id: RequestId,
    params: RenameFilesParams,
};

/// The will delete files request is sent from the client to the server before files are actually
/// deleted as long as the deletion is triggered from within the client.
pub const DidDeleteFilesNotification = struct {
    comptime method: []const u8 = "workspace/didDeleteFiles",
    id: RequestId,
    params: DeleteFilesParams,
};

/// The parameters sent in file delete requests/notifications.
pub const DeleteFilesParams = struct {
    /// An array of all files/folders deleted in this operation.
    files: []FileDelete,
};

/// Represents information on a file/folder delete.
pub const FileDelete = struct {
    /// A file:// URI for the location of the file/folder being deleted.
    uri: []const u8,
};

/// The did delete files notification is sent from the client to the server when
/// files were deleted from within the client.
pub const WillDeleteFilesRequest = struct {
    comptime method: []const u8 = "workspace/willDeleteFiles",
    id: RequestId,
    params: DeleteFilesParams,
};

/// Moniker uniqueness level to define scope of the moniker.
pub const UniquenessLevel = struct {
    pub const document = "document";
    pub const global = "global";
    pub const group = "group";
    pub const project = "project";
    pub const scheme = "scheme";
};
/// The moniker kind.
pub const MonikerKind = struct {
    pub const @"export" = "export";
    pub const @"import" = "import";
    pub const local = "local";
};
/// Moniker definition to match LSIF 0.5 moniker definition.
pub const Moniker = struct {
    /// The scheme of the moniker. For example tsc or .Net
    scheme: []const u8,

    /// The identifier of the moniker. The value is opaque in LSIF however
    /// schema owners are allowed to define the structure if they want.
    identifier: []const u8,

    /// The scope in which the moniker is unique
    unique: UniquenessLevel,

    /// The moniker kind if known.
    kind: ?MonikerKind = null,
};

/// Client capabilities specific to the moniker request.
pub const MonikerClientCapabilities = struct {
    /// Whether moniker supports dynamic registration. If this is set to `true`
    /// the client supports the new `MonikerRegistrationOptions` return value
    /// for the corresponding server capability as well.
    dynamicRegistration: ?bool = null,
};
pub const MonikerOptions = struct {
    workDoneProgress: ?bool = null,
};
pub const MonikerRegistrationOptions = struct {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    documentSelector: ?DocumentSelector,
    workDoneProgress: ?bool = null,
};
pub const MonikerParams = struct {
    /// The text document.
    textDocument: TextDocumentIdentifier,

    /// The position inside the text document.
    position: Position,

    /// An optional token that a server can use to report work done progress.
    workDoneToken: ?ProgressToken = null,

    /// An optional token that a server can use to report partial results (e.g. streaming) to
    /// the client.
    partialResultToken: ?ProgressToken = null,
};

/// A request to get the moniker of a symbol at a given text document position.
/// The request parameter is of type [TextDocumentPositionParams](#TextDocumentPositionParams).
/// The response is of type [Moniker[]](#Moniker[]) or `null`.
pub const MonikerRequest = struct {
    comptime method: []const u8 = "textDocument/moniker",
    id: RequestId,
    params: MonikerParams,
};
pub const ColorProviderOptions = DocumentColorOptions;
pub const ColorOptions = DocumentColorOptions;
pub const FoldingRangeProviderOptions = FoldingRangeOptions;
pub const SelectionRangeProviderOptions = SelectionRangeOptions;
pub const ColorRegistrationOptions = DocumentColorRegistrationOptions;

pub const Request = union(enum) {
    ApplyWorkspaceEditRequest: ApplyWorkspaceEditRequest,
    CallHierarchyIncomingCallsRequest: CallHierarchyIncomingCallsRequest,
    CallHierarchyOutgoingCallsRequest: CallHierarchyOutgoingCallsRequest,
    CallHierarchyPrepareRequest: CallHierarchyPrepareRequest,
    CodeActionRequest: CodeActionRequest,
    CodeActionResolveRequest: CodeActionResolveRequest,
    CodeLensRefreshRequest: CodeLensRefreshRequest,
    CodeLensRequest: CodeLensRequest,
    CodeLensResolveRequest: CodeLensResolveRequest,
    ColorPresentationRequest: ColorPresentationRequest,
    CompletionRequest: CompletionRequest,
    CompletionResolveRequest: CompletionResolveRequest,
    ConfigurationRequest: ConfigurationRequest,
    DeclarationRequest: DeclarationRequest,
    DefinitionRequest: DefinitionRequest,
    DocumentColorRequest: DocumentColorRequest,
    DocumentFormattingRequest: DocumentFormattingRequest,
    DocumentHighlightRequest: DocumentHighlightRequest,
    DocumentLinkRequest: DocumentLinkRequest,
    DocumentLinkResolveRequest: DocumentLinkResolveRequest,
    DocumentOnTypeFormattingRequest: DocumentOnTypeFormattingRequest,
    DocumentRangeFormattingRequest: DocumentRangeFormattingRequest,
    DocumentSymbolRequest: DocumentSymbolRequest,
    ExecuteCommandRequest: ExecuteCommandRequest,
    FoldingRangeRequest: FoldingRangeRequest,
    HoverRequest: HoverRequest,
    ImplementationRequest: ImplementationRequest,
    InitializeRequest: InitializeRequest,
    LinkedEditingRangeRequest: LinkedEditingRangeRequest,
    MonikerRequest: MonikerRequest,
    PrepareRenameRequest: PrepareRenameRequest,
    ReferencesRequest: ReferencesRequest,
    RegistrationRequest: RegistrationRequest,
    RenameRequest: RenameRequest,
    SelectionRangeRequest: SelectionRangeRequest,
    SemanticTokensDeltaRequest: SemanticTokensDeltaRequest,
    SemanticTokensRangeRequest: SemanticTokensRangeRequest,
    SemanticTokensRefreshRequest: SemanticTokensRefreshRequest,
    SemanticTokensRequest: SemanticTokensRequest,
    ShowDocumentRequest: ShowDocumentRequest,
    ShowMessageRequest: ShowMessageRequest,
    ShutdownRequest: ShutdownRequest,
    SignatureHelpRequest: SignatureHelpRequest,
    TypeDefinitionRequest: TypeDefinitionRequest,
    UnregistrationRequest: UnregistrationRequest,
    WillCreateFilesRequest: WillCreateFilesRequest,
    WillDeleteFilesRequest: WillDeleteFilesRequest,
    WillRenameFilesRequest: WillRenameFilesRequest,
    WillSaveTextDocumentWaitUntilRequest: WillSaveTextDocumentWaitUntilRequest,
    WorkDoneProgressCreateRequest: WorkDoneProgressCreateRequest,
    WorkspaceFoldersRequest: WorkspaceFoldersRequest,
    WorkspaceSymbolRequest: WorkspaceSymbolRequest,
};
pub const Notification = union(enum) {
    DidChangeConfigurationNotification: DidChangeConfigurationNotification,
    DidChangeTextDocumentNotification: DidChangeTextDocumentNotification,
    DidChangeWatchedFilesNotification: DidChangeWatchedFilesNotification,
    DidChangeWorkspaceFoldersNotification: DidChangeWorkspaceFoldersNotification,
    DidCloseTextDocumentNotification: DidCloseTextDocumentNotification,
    DidCreateFilesNotification: DidCreateFilesNotification,
    DidDeleteFilesNotification: DidDeleteFilesNotification,
    DidOpenTextDocumentNotification: DidOpenTextDocumentNotification,
    DidRenameFilesNotification: DidRenameFilesNotification,
    DidSaveTextDocumentNotification: DidSaveTextDocumentNotification,
    ExitNotification: ExitNotification,
    InitializedNotification: InitializedNotification,
    LogMessageNotification: LogMessageNotification,
    PublishDiagnosticsNotification: PublishDiagnosticsNotification,
    ShowMessageNotification: ShowMessageNotification,
    TelemetryEventNotification: TelemetryEventNotification,
    WillSaveTextDocumentNotification: WillSaveTextDocumentNotification,
    WorkDoneProgressCancelNotification: WorkDoneProgressCancelNotification,
};
