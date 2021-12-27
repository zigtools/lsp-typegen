const std = @import("std");
const json = std.json;

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

/// MIN_VALUE = -2147483648
/// MAX_VALUE = 2147483647
const integer = i32;
/// MIN_VALUE = 0
/// MAX_VALUE = 2147483647
const uinteger = u32;
/// Defines a decimal number. Since decimal numbers are very
/// rare in the language server specification we denote the
/// exact range with every decimal using the mathematics
/// interval notations (e.g. [0, 1] denotes all decimals d with
/// 0 <= d <= 1.
const decimal = f32;

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
    const SourceOrganizeImports = "source.organizeImports";
};

/// The reason why code actions were requested.
const CodeActionTriggerKind = enum {
    Automatic = 2,
    Invoked = 1,

    usingnamespace IntBackedEnumStringify(@This());
};

/// The kind of a completion entry.
const CompletionItemKind = enum {
    Class = 7,
    Color = 16,
    Constant = 21,
    Constructor = 4,
    Enum = 13,
    EnumMember = 20,
    Event = 23,
    Field = 5,
    File = 17,
    Folder = 19,
    Function = 3,
    Interface = 8,
    Keyword = 14,
    Method = 2,
    Module = 9,
    Operator = 24,
    Property = 10,
    Reference = 18,
    Snippet = 15,
    Struct = 22,
    Text = 1,
    TypeParameter = 25,
    Unit = 11,
    Value = 12,
    Variable = 6,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Completion item tags are extra annotations that tweak the rendering of a completion
/// item.
const CompletionItemTag = enum {
    Deprecated = 1,

    usingnamespace IntBackedEnumStringify(@This());
};

/// The diagnostic's severity.
const DiagnosticSeverity = enum {
    Error = 1,
    Hint = 4,
    Information = 3,
    Warning = 2,

    usingnamespace IntBackedEnumStringify(@This());
};

/// The diagnostic tags.
const DiagnosticTag = enum {
    Deprecated = 2,
    Unnecessary = 1,

    usingnamespace IntBackedEnumStringify(@This());
};

/// A document highlight kind.
const DocumentHighlightKind = enum {
    Read = 2,
    Text = 1,
    Write = 3,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Defines whether the insert text in a completion item should be interpreted as
/// plain text or a snippet.
const InsertTextFormat = enum {
    PlainText = 1,
    Snippet = 2,

    usingnamespace IntBackedEnumStringify(@This());
};

/// How whitespace and indentation is handled during completion
/// item insertion.
const InsertTextMode = enum {
    adjustIndentation = 2,
    asIs = 1,

    usingnamespace IntBackedEnumStringify(@This());
};

/// A symbol kind.
const SymbolKind = enum {
    Array = 18,
    Boolean = 17,
    Class = 5,
    Constant = 14,
    Constructor = 9,
    Enum = 10,
    EnumMember = 22,
    Event = 24,
    Field = 8,
    File = 1,
    Function = 12,
    Interface = 11,
    Key = 20,
    Method = 6,
    Module = 2,
    Namespace = 3,
    Null = 21,
    Number = 16,
    Object = 19,
    Operator = 25,
    Package = 4,
    Property = 7,
    String = 15,
    Struct = 23,
    TypeParameter = 26,
    Variable = 13,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Symbol tags are extra annotations that tweak the rendering of a symbol.
const SymbolTag = enum {
    Deprecated = 1,

    usingnamespace IntBackedEnumStringify(@This());
};

/// Enum of known range kinds
const FoldingRangeKind = struct {
    const Comment = "comment";
    const Imports = "imports";
    const Region = "region";
};
/// A set of predefined token modifiers. This set is not fixed
/// an clients can specify additional token types via the
/// corresponding client capabilities.
const SemanticTokenModifiers = struct {
    const abstract = "abstract";
    const @"async" = "async";
    const declaration = "declaration";
    const defaultLibrary = "defaultLibrary";
    const definition = "definition";
    const deprecated = "deprecated";
    const documentation = "documentation";
    const modification = "modification";
    const readonly = "readonly";
    const static = "static";
};
/// A set of predefined token types. This set is not fixed
/// an clients can specify additional token types via the
/// corresponding client capabilities.
const SemanticTokenTypes = struct {
    const class = "class";
    const comment = "comment";
    const decorator = "decorator";
    const @"enum" = "enum";
    const enumMember = "enumMember";
    const event = "event";
    const function = "function";
    const interface = "interface";
    const keyword = "keyword";
    const macro = "macro";
    const method = "method";
    const modifier = "modifier";
    const namespace = "namespace";
    const number = "number";
    const operator = "operator";
    const parameter = "parameter";
    const property = "property";
    const regexp = "regexp";
    const string = "string";
    const @"struct" = "struct";
    const @"type" = "type";
    const typeParameter = "typeParameter";
    const variable = "variable";
};
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
    needsConfirmation: boolean,
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
    isPreferred: boolean,

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
    alpha: ManuallyTranslateNumberType,

    /// The blue component of this color in the range [0-1].
    blue: ManuallyTranslateNumberType,

    /// The green component of this color in the range [0-1].
    green: ManuallyTranslateNumberType,

    /// The red component of this color in the range [0-1].
    red: ManuallyTranslateNumberType,
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
    deprecated: boolean,

    /// A human-readable string with additional information
    /// about this item, like type or symbol information.
    detail: []const u8,

    /// A human-readable string that represents a doc-comment.
    documentation: union(enum) {
        string: []const u8,
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
    preselect: boolean,

    /// A string that should be used when comparing this item
    /// with other items. When `falsy` the [label](#CompletionItem.label)
    /// is used.
    sortText: []const u8,

    /// Tags for this completion item.
    tags: []1,

    /// An [edit](#TextEdit) which is applied to a document when selecting
    /// this completion. When an edit is provided the value of
    /// [insertText](#CompletionItem.insertText) is ignored.
    textEdit: union(enum) {
        TextEdit: TextEdit,
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
    isIncomplete: boolean,

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
    ignoreIfExists: boolean,

    /// Overwrite existing file. Overwrite wins over `ignoreIfExists`
    overwrite: boolean,
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
    ignoreIfNotExists: boolean,

    /// Delete the content recursively if a folder is denoted.
    recursive: boolean,
};

/// Represents a diagnostic, such as a compiler error or warning. Diagnostic objects
/// are only valid in the scope of a resource.
const Diagnostic = struct {
    /// The diagnostic's code, which usually appear in the user interface.
    code: union(enum) {
        string: []const u8,
        number: ManuallyTranslateNumberType,
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
    deprecated: boolean,

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
    endCharacter: ManuallyTranslateNumberType,

    /// The zero-based end line of the range to fold. The folded area ends with the line's last character.
    /// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
    endLine: ManuallyTranslateNumberType,

    /// Describes the kind of the folding range such as `comment' or 'region'. The kind
    /// is used to categorize folding ranges and used by commands like 'Fold all comments'. See
    /// [FoldingRangeKind](#FoldingRangeKind) for an enumeration of standardized kinds.
    kind: []const u8,

    /// The zero-based character offset from where the folded range starts. If not defined, defaults to the length of the start line.
    startCharacter: ManuallyTranslateNumberType,

    /// The zero-based start line of the range to fold. The folded area starts after the line's last character.
    /// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
    startLine: ManuallyTranslateNumberType,
};

/// Value-object describing what options formatting should use.
const FormattingOptions = struct {
    /// Insert a newline character at the end of the file if one does not exist.
    insertFinalNewline: boolean,

    /// Prefer spaces over tabs.
    insertSpaces: boolean,

    /// Size of a tab in spaces.
    tabSize: ManuallyTranslateNumberType,

    /// Trim all newlines after the final newline at the end of the file.
    trimFinalNewlines: boolean,

    /// Trim trailing whitespaces on a line.
    trimTrailingWhitespace: boolean,
};

/// The result of a hover request.
const Hover = struct {
    /// The hover's content
    contents: union(enum) {
        MarkupContent: MarkupContent,
        MarkedString: MarkedString,
        undefined: []MarkedString,
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
    caseSensitiveLookup: boolean,

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
const Location = struct {
    range: Range,
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
    version: enum {
        null,
        ManuallyTranslateNumberType,

        usingnamespace IntBackedEnumStringify(@This());
    },
};

/// Represents a parameter of a callable-signature. A parameter can
/// have a label and a doc-comment.
const ParameterInformation = struct {
    /// The human-readable doc-comment of this signature. Will be shown
    /// in the UI but can be omitted.
    documentation: union(enum) {
        string: []const u8,
        MarkupContent: MarkupContent,
    },

    /// The label of this parameter information.
    label: union(enum) {
        string: []const u8,
        undefined: Tuple(&[_]type{
            ManuallyTranslateNumberType,
            ManuallyTranslateNumberType,
        }),
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
    character: ManuallyTranslateNumberType,

    /// Line position in a document (zero-based).
    line: ManuallyTranslateNumberType,
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
    includeDeclaration: boolean,
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
    ignoreIfExists: boolean,

    /// Overwrite target if existing. Overwrite wins over `ignoreIfExists`
    overwrite: boolean,
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
    data: []ManuallyTranslateNumberType,

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
    data: []ManuallyTranslateNumberType,

    /// The count of elements to remove.
    deleteCount: ManuallyTranslateNumberType,

    /// The start offset of the edit.
    start: ManuallyTranslateNumberType,
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
    activeParameter: ManuallyTranslateNumberType,

    /// The active signature. If omitted or the value lies outside the
    /// range of `signatures` the value defaults to zero or is ignored if
    /// the `SignatureHelp` has no signatures.
    activeSignature: ManuallyTranslateNumberType,

    /// One or more signatures.
    signatures: []SignatureInformation,
};

/// Represents the signature of something callable. A signature
/// can have a label, like a function-name, a doc-comment, and
/// a set of parameters.
const SignatureInformation = struct {
    /// The index of the active parameter.
    activeParameter: ManuallyTranslateNumberType,

    /// The human-readable doc-comment of this signature. Will be shown
    /// in the UI but can be omitted.
    documentation: union(enum) {
        string: []const u8,
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
    deprecated: boolean,

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
    lineCount: ManuallyTranslateNumberType,

    /// The associated URI for this document. Most documents have the __file__-scheme, indicating that they
    /// represent files on disk. However, some documents may have other schemes indicating that they are not
    /// available on disk.
    uri: []const u8,

    /// The version number of this document (it will increase after each
    /// change, including undo/redo).
    version: ManuallyTranslateNumberType,
};

/// Describes textual changes on a text document. A TextDocumentEdit describes all changes
/// on a document version Si and after they are applied move the document to version Si+1.
/// So the creator of a TextDocumentEdit doesn't need to sort the array of edits or do any
/// kind of ordering. However the edits must be non overlapping.
const TextDocumentEdit = struct {
    /// The edits to be applied.
    edits: []union(enum) {
        TextEdit: TextEdit,
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
    version: ManuallyTranslateNumberType,
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
    version: ManuallyTranslateNumberType,
};

/// A workspace edit represents changes to many resources managed in the workspace. The edit
/// should either provide `changes` or `documentChanges`. If documentChanges are present
/// they are preferred over `changes` if the client can handle versioned document edits.
const WorkspaceEdit = struct {
    /// Depending on the client capability `workspace.workspaceEdit.resourceOperations` document changes
    /// are either an array of `TextDocumentEdit`s to express changes to n different text documents
    /// where each text document edit addresses a specific version of a text document. Or it can contain
    /// above `TextDocumentEdit`s mixed with create, rename and delete file / folder operations.
    documentChanges: []union(enum) {
        TextDocumentEdit: TextDocumentEdit,
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
    location: union(enum) {
        Location: Location,
    },

    /// The name of this symbol.
    name: []const u8,

    /// Tags for this completion item.
    tags: []1,
};

/// The declaration of a symbol representation as one or many [locations](#Location).
const Declaration = union(enum) {
    Location: Location,
    undefined: []Location,
};

/// Information about where a symbol is declared.
const DeclarationLink = LocationLink;

/// The definition of a symbol represented as one or many [locations](#Location).
/// For most programming languages there is only one location at which a symbol is
/// defined.
const Definition = union(enum) {
    Location: Location,
    undefined: []Location,
};

/// Information about where a symbol is defined.
const DefinitionLink = LocationLink;

/// A tagging type for string properties that are actually document URIs.
const DocumentUri = []const u8;

/// Inline value information can be provided by different means:
/// - directly as a text value (class InlineValueText).
/// - as a name to use for a variable lookup (class InlineValueVariableLookup)
/// - as an evaluatable expression (class InlineValueEvaluatableExpression)
/// The InlineValue types combines all inline value types into one type.
const InlineValue = union(enum) {
    InlineValueText: InlineValueText,
    InlineValueVariableLookup: InlineValueVariableLookup,
    InlineValueEvaluatableExpression: InlineValueEvaluatableExpression,
};

/// A tagging type for string properties that are actually URIs
const URI = []const u8;
const EOL = ManuallyTranslateValue;
