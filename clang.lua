local ffi = require('ffi')
ffi.cdef([[typedef void* CXIndex;
typedef void* CXTranslationUnit;

typedef struct {
  const void *data;
  unsigned private_flags;
} CXString;

const char *clang_getCString(CXString string);

typedef struct {
  int kind;
  int xdata;
  const void *data[3];
} CXCursor;

enum CXErrorCode {
  CXError_Success,
  CXError_Failure,
  CXError_Crashed,
  CXError_InvalidArguments,
  CXError_ASTReadError
};

CXIndex clang_createIndex(int exclude_pch_decls, int display_diagnostics);
void clang_disposeIndex(CXIndex index);

struct CXUnsavedFile {
  const char *Filename;
  const char *Contents;
  unsigned long Length;
};

CXTranslationUnit clang_parseTranslationUnit(CXIndex CIdx,
                            const char *source_filename,
                            const char *const *command_line_args,
                            int num_command_line_args,
                            struct CXUnsavedFile *unsaved_files,
                            unsigned num_unsaved_files,
                            unsigned options);

int clang_reparseTranslationUnit(CXTranslationUnit TU,
                                 unsigned num_unsaved_files,
                                 struct CXUnsavedFile *unsaved_files,
                                 unsigned options);

void clang_disposeTranslationUnit(CXTranslationUnit);

CXCursor clang_getTranslationUnitCursor(CXTranslationUnit);

int clang_getCursorKind(CXCursor);

CXString clang_getCursorSpelling(CXCursor);

enum CXChildVisitResult {
  CXChildVisit_Break,
  CXChildVisit_Continue,
  CXChildVisit_Recurse
};

typedef enum CXChildVisitResult (*CXCursorVisitor)(CXCursor cursor,
                                                   CXCursor parent,
                                                   void* client_data);

typedef enum CXChildVisitResult (*ljclang_callback)(CXCursor* cursor, CXCursor* parent);

enum CXChildVisitResult ljclang_tree_visitor(CXCursor, CXCursor, void*);

typedef void* CXCompletionString;

CXCompletionString clang_getCursorCompletionString(CXCursor cursor);

CXString clang_getCompletionChunkText(CXCompletionString completion_string,
                                      unsigned chunk_number);

unsigned clang_getNumCompletionChunks(CXCompletionString completion_string);

unsigned clang_getCompletionPriority(CXCompletionString completion_string);

unsigned clang_visitChildren(CXCursor parent,
                             CXCursorVisitor visitor,
                             void* client_data);

int clang_getCompletionChunkKind(CXCompletionString completion_string,
                                 unsigned chunk_number);

typedef struct {
  int CursorKind;
  CXCompletionString CompletionString;
} CXCompletionResult;

typedef struct {
  CXCompletionResult *Results;
  unsigned NumResults;
} CXCodeCompleteResults;

enum CXCodeComplete_Flags {
  CXCodeComplete_IncludeMacros = 0x01,
  CXCodeComplete_IncludeCodePatterns = 0x02,
  CXCodeComplete_IncludeBriefComments = 0x04
};

CXCodeCompleteResults *clang_codeCompleteAt(CXTranslationUnit TU,
                                            const char *complete_filename,
                                            unsigned complete_line,
                                            unsigned complete_column,
                                            struct CXUnsavedFile *unsaved_files,
                                            unsigned num_unsaved_files,
                                            unsigned options);

void clang_sortCodeCompletionResults(CXCompletionResult *Results,
                                     unsigned NumResults);
void clang_disposeCodeCompleteResults(CXCodeCompleteResults *Results);
]])
local libclang = ffi.load(tostring(debug.getinfo(1).source:match('@?(.*/)')) .. "/libljclang.so")
local cursor_map = { }
cursor_map[1] = 'UnexposedDecl'
cursor_map[2] = 'StructDecl'
cursor_map[3] = 'UnionDecl'
cursor_map[4] = 'ClassDecl'
cursor_map[5] = 'EnumDecl'
cursor_map[6] = 'FieldDecl'
cursor_map[7] = 'EnumConstantDecl'
cursor_map[8] = 'FunctionDecl'
cursor_map[9] = 'VarDecl'
cursor_map[10] = 'ParmDecl'
cursor_map[11] = 'ObjCInterfaceDecl'
cursor_map[12] = 'ObjCCategoryDecl'
cursor_map[13] = 'ObjCProtocolDecl'
cursor_map[14] = 'ObjCPropertyDecl'
cursor_map[15] = 'ObjCIvarDecl'
cursor_map[16] = 'ObjCInstanceMethodDecl'
cursor_map[17] = 'ObjCClassMethodDecl'
cursor_map[18] = 'ObjCImplementationDecl'
cursor_map[19] = 'ObjCCategoryImplDecl'
cursor_map[20] = 'TypedefDecl'
cursor_map[21] = 'CXXMethod'
cursor_map[22] = 'Namespace'
cursor_map[23] = 'LinkageSpec'
cursor_map[24] = 'Constructor'
cursor_map[25] = 'Destructor'
cursor_map[26] = 'ConversionFunction'
cursor_map[27] = 'TemplateTypeParameter'
cursor_map[28] = 'NonTypeTemplateParameter'
cursor_map[29] = 'TemplateTemplateParameter'
cursor_map[30] = 'FunctionTemplate'
cursor_map[31] = 'ClassTemplate'
cursor_map[32] = 'ClassTemplatePartialSpecialization'
cursor_map[33] = 'NamespaceAlias'
cursor_map[34] = 'UsingDirective'
cursor_map[35] = 'UsingDeclaration'
cursor_map[36] = 'TypeAliasDecl'
cursor_map[37] = 'ObjCSynthesizeDecl'
cursor_map[38] = 'ObjCDynamicDecl'
cursor_map[39] = 'CXXAccessSpecifier'
cursor_map[40] = 'FirstRef'
cursor_map[40] = 'ObjCSuperClassRef'
cursor_map[41] = 'ObjCProtocolRef'
cursor_map[42] = 'ObjCClassRef'
cursor_map[43] = 'TypeRef'
cursor_map[44] = 'CXXBaseSpecifier'
cursor_map[45] = 'TemplateRef'
cursor_map[46] = 'NamespaceRef'
cursor_map[47] = 'MemberRef'
cursor_map[48] = 'LabelRef'
cursor_map[49] = 'OverloadedDeclRef'
cursor_map[50] = 'VariableRef'
cursor_map[70] = 'FirstInvalid'
cursor_map[70] = 'InvalidFile'
cursor_map[71] = 'NoDeclFound'
cursor_map[72] = 'NotImplemented'
cursor_map[73] = 'InvalidCode'
cursor_map[100] = 'FirstExpr'
cursor_map[100] = 'UnexposedExpr'
cursor_map[101] = 'DeclRefExpr'
cursor_map[102] = 'MemberRefExpr'
cursor_map[103] = 'CallExpr'
cursor_map[104] = 'ObjCMessageExpr'
cursor_map[105] = 'BlockExpr'
cursor_map[106] = 'IntegerLiteral'
cursor_map[107] = 'FloatingLiteral'
cursor_map[108] = 'ImaginaryLiteral'
cursor_map[109] = 'StringLiteral'
cursor_map[110] = 'CharacterLiteral'
cursor_map[111] = 'ParenExpr'
cursor_map[112] = 'UnaryOperator'
cursor_map[113] = 'ArraySubscriptExpr'
cursor_map[114] = 'BinaryOperator'
cursor_map[115] = 'CompoundAssignOperator'
cursor_map[116] = 'ConditionalOperator'
cursor_map[117] = 'CStyleCastExpr'
cursor_map[118] = 'CompoundLiteralExpr'
cursor_map[119] = 'InitListExpr'
cursor_map[120] = 'AddrLabelExpr'
cursor_map[121] = 'StmtExpr'
cursor_map[122] = 'GenericSelectionExpr'
cursor_map[123] = 'GNUNullExpr'
cursor_map[124] = 'CXXStaticCastExpr'
cursor_map[125] = 'CXXDynamicCastExpr'
cursor_map[126] = 'CXXReinterpretCastExpr'
cursor_map[127] = 'CXXConstCastExpr'
cursor_map[128] = 'CXXFunctionalCastExpr'
cursor_map[129] = 'CXXTypeidExpr'
cursor_map[130] = 'CXXBoolLiteralExpr'
cursor_map[131] = 'CXXNullPtrLiteralExpr'
cursor_map[132] = 'CXXThisExpr'
cursor_map[133] = 'CXXThrowExpr'
cursor_map[134] = 'CXXNewExpr'
cursor_map[135] = 'CXXDeleteExpr'
cursor_map[136] = 'UnaryExpr'
cursor_map[137] = 'ObjCStringLiteral'
cursor_map[138] = 'ObjCEncodeExpr'
cursor_map[139] = 'ObjCSelectorExpr'
cursor_map[140] = 'ObjCProtocolExpr'
cursor_map[141] = 'ObjCBridgedCastExpr'
cursor_map[142] = 'PackExpansionExpr'
cursor_map[143] = 'SizeOfPackExpr'
cursor_map[144] = 'LambdaExpr'
cursor_map[145] = 'ObjCBoolLiteralExpr'
cursor_map[146] = 'ObjCSelfExpr'
cursor_map[200] = 'FirstStmt'
cursor_map[200] = 'UnexposedStmt'
cursor_map[201] = 'LabelStmt'
cursor_map[202] = 'CompoundStmt'
cursor_map[203] = 'CaseStmt'
cursor_map[204] = 'DefaultStmt'
cursor_map[205] = 'IfStmt'
cursor_map[206] = 'SwitchStmt'
cursor_map[207] = 'WhileStmt'
cursor_map[208] = 'DoStmt'
cursor_map[209] = 'ForStmt'
cursor_map[210] = 'GotoStmt'
cursor_map[211] = 'IndirectGotoStmt'
cursor_map[212] = 'ContinueStmt'
cursor_map[213] = 'BreakStmt'
cursor_map[214] = 'ReturnStmt'
cursor_map[215] = 'GCCAsmStmt'
cursor_map[216] = 'ObjCAtTryStmt'
cursor_map[217] = 'ObjCAtCatchStmt'
cursor_map[218] = 'ObjCAtFinallyStmt'
cursor_map[219] = 'ObjCAtThrowStmt'
cursor_map[220] = 'ObjCAtSynchronizedStmt'
cursor_map[221] = 'ObjCAutoreleasePoolStmt'
cursor_map[222] = 'ObjCForCollectionStmt'
cursor_map[223] = 'CXXCatchStmt'
cursor_map[224] = 'CXXTryStmt'
cursor_map[225] = 'CXXForRangeStmt'
cursor_map[226] = 'SEHTryStmt'
cursor_map[227] = 'SEHExceptStmt'
cursor_map[228] = 'SEHFinallyStmt'
cursor_map[229] = 'MSAsmStmt'
cursor_map[230] = 'NullStmt'
cursor_map[231] = 'DeclStmt'
cursor_map[232] = 'OMPParallelDirective'
cursor_map[233] = 'OMPSimdDirective'
cursor_map[234] = 'OMPForDirective'
cursor_map[235] = 'OMPSectionsDirective'
cursor_map[236] = 'OMPSectionDirective'
cursor_map[237] = 'OMPSingleDirective'
cursor_map[238] = 'OMPParallelForDirective'
cursor_map[239] = 'OMPParallelSectionsDirective'
cursor_map[240] = 'OMPTaskDirective'
cursor_map[241] = 'OMPMasterDirective'
cursor_map[242] = 'OMPCriticalDirective'
cursor_map[243] = 'OMPTaskyieldDirective'
cursor_map[244] = 'OMPBarrierDirective'
cursor_map[245] = 'OMPTaskwaitDirective'
cursor_map[246] = 'OMPFlushDirective'
cursor_map[247] = 'SEHLeaveStmt'
cursor_map[248] = 'OMPOrderedDirective'
cursor_map[249] = 'OMPAtomicDirective'
cursor_map[250] = 'OMPForSimdDirective'
cursor_map[251] = 'OMPParallelForSimdDirective'
cursor_map[252] = 'OMPTargetDirective'
cursor_map[253] = 'OMPTeamsDirective'
cursor_map[300] = 'TranslationUnit'
cursor_map[400] = 'FirstAttr'
cursor_map[401] = 'IBActionAttr'
cursor_map[402] = 'IBOutletAttr'
cursor_map[403] = 'IBOutletCollectionAttr'
cursor_map[404] = 'CXXFinalAttr'
cursor_map[405] = 'CXXOverrideAttr'
cursor_map[406] = 'AnnotateAttr'
cursor_map[407] = 'AsmLabelAttr'
cursor_map[408] = 'PackedAttr'
cursor_map[409] = 'PureAttr'
cursor_map[410] = 'ConstAttr'
cursor_map[411] = 'NoDuplicateAttr'
cursor_map[412] = 'CUDAConstantAttr'
cursor_map[413] = 'CUDADeviceAttr'
cursor_map[414] = 'CUDAGlobalAttr'
cursor_map[415] = 'CUDAHostAttr'
cursor_map[416] = 'CUDASharedAttr'
cursor_map[500] = 'PreprocessingDirective'
cursor_map[501] = 'MacroDefinition'
cursor_map[502] = 'MacroExpansion'
cursor_map[503] = 'InclusionDirective'
cursor_map[600] = 'ModuleImportDecl'
local cursor_kinds = { }
cursor_kinds.UnexposedDecl = 1
cursor_kinds.StructDecl = 2
cursor_kinds.UnionDecl = 3
cursor_kinds.ClassDecl = 4
cursor_kinds.EnumDecl = 5
cursor_kinds.FieldDecl = 6
cursor_kinds.EnumConstantDecl = 7
cursor_kinds.FunctionDecl = 8
cursor_kinds.VarDecl = 9
cursor_kinds.ParmDecl = 10
cursor_kinds.ObjCInterfaceDecl = 11
cursor_kinds.ObjCCategoryDecl = 12
cursor_kinds.ObjCProtocolDecl = 13
cursor_kinds.ObjCPropertyDecl = 14
cursor_kinds.ObjCIvarDecl = 15
cursor_kinds.ObjCInstanceMethodDecl = 16
cursor_kinds.ObjCClassMethodDecl = 17
cursor_kinds.ObjCImplementationDecl = 18
cursor_kinds.ObjCCategoryImplDecl = 19
cursor_kinds.TypedefDecl = 20
cursor_kinds.CXXMethod = 21
cursor_kinds.Namespace = 22
cursor_kinds.LinkageSpec = 23
cursor_kinds.Constructor = 24
cursor_kinds.Destructor = 25
cursor_kinds.ConversionFunction = 26
cursor_kinds.TemplateTypeParameter = 27
cursor_kinds.NonTypeTemplateParameter = 28
cursor_kinds.TemplateTemplateParameter = 29
cursor_kinds.FunctionTemplate = 30
cursor_kinds.ClassTemplate = 31
cursor_kinds.ClassTemplatePartialSpecialization = 32
cursor_kinds.NamespaceAlias = 33
cursor_kinds.UsingDirective = 34
cursor_kinds.UsingDeclaration = 35
cursor_kinds.TypeAliasDecl = 36
cursor_kinds.ObjCSynthesizeDecl = 37
cursor_kinds.ObjCDynamicDecl = 38
cursor_kinds.CXXAccessSpecifier = 39
cursor_kinds.FirstRef = 40
cursor_kinds.ObjCSuperClassRef = 40
cursor_kinds.ObjCProtocolRef = 41
cursor_kinds.ObjCClassRef = 42
cursor_kinds.TypeRef = 43
cursor_kinds.CXXBaseSpecifier = 44
cursor_kinds.TemplateRef = 45
cursor_kinds.NamespaceRef = 46
cursor_kinds.MemberRef = 47
cursor_kinds.LabelRef = 48
cursor_kinds.OverloadedDeclRef = 49
cursor_kinds.VariableRef = 50
cursor_kinds.FirstInvalid = 70
cursor_kinds.InvalidFile = 70
cursor_kinds.NoDeclFound = 71
cursor_kinds.NotImplemented = 72
cursor_kinds.InvalidCode = 73
cursor_kinds.FirstExpr = 100
cursor_kinds.UnexposedExpr = 100
cursor_kinds.DeclRefExpr = 101
cursor_kinds.MemberRefExpr = 102
cursor_kinds.CallExpr = 103
cursor_kinds.ObjCMessageExpr = 104
cursor_kinds.BlockExpr = 105
cursor_kinds.IntegerLiteral = 106
cursor_kinds.FloatingLiteral = 107
cursor_kinds.ImaginaryLiteral = 108
cursor_kinds.StringLiteral = 109
cursor_kinds.CharacterLiteral = 110
cursor_kinds.ParenExpr = 111
cursor_kinds.UnaryOperator = 112
cursor_kinds.ArraySubscriptExpr = 113
cursor_kinds.BinaryOperator = 114
cursor_kinds.CompoundAssignOperator = 115
cursor_kinds.ConditionalOperator = 116
cursor_kinds.CStyleCastExpr = 117
cursor_kinds.CompoundLiteralExpr = 118
cursor_kinds.InitListExpr = 119
cursor_kinds.AddrLabelExpr = 120
cursor_kinds.StmtExpr = 121
cursor_kinds.GenericSelectionExpr = 122
cursor_kinds.GNUNullExpr = 123
cursor_kinds.CXXStaticCastExpr = 124
cursor_kinds.CXXDynamicCastExpr = 125
cursor_kinds.CXXReinterpretCastExpr = 126
cursor_kinds.CXXConstCastExpr = 127
cursor_kinds.CXXFunctionalCastExpr = 128
cursor_kinds.CXXTypeidExpr = 129
cursor_kinds.CXXBoolLiteralExpr = 130
cursor_kinds.CXXNullPtrLiteralExpr = 131
cursor_kinds.CXXThisExpr = 132
cursor_kinds.CXXThrowExpr = 133
cursor_kinds.CXXNewExpr = 134
cursor_kinds.CXXDeleteExpr = 135
cursor_kinds.UnaryExpr = 136
cursor_kinds.ObjCStringLiteral = 137
cursor_kinds.ObjCEncodeExpr = 138
cursor_kinds.ObjCSelectorExpr = 139
cursor_kinds.ObjCProtocolExpr = 140
cursor_kinds.ObjCBridgedCastExpr = 141
cursor_kinds.PackExpansionExpr = 142
cursor_kinds.SizeOfPackExpr = 143
cursor_kinds.LambdaExpr = 144
cursor_kinds.ObjCBoolLiteralExpr = 145
cursor_kinds.ObjCSelfExpr = 146
cursor_kinds.FirstStmt = 200
cursor_kinds.UnexposedStmt = 200
cursor_kinds.LabelStmt = 201
cursor_kinds.CompoundStmt = 202
cursor_kinds.CaseStmt = 203
cursor_kinds.DefaultStmt = 204
cursor_kinds.IfStmt = 205
cursor_kinds.SwitchStmt = 206
cursor_kinds.WhileStmt = 207
cursor_kinds.DoStmt = 208
cursor_kinds.ForStmt = 209
cursor_kinds.GotoStmt = 210
cursor_kinds.IndirectGotoStmt = 211
cursor_kinds.ContinueStmt = 212
cursor_kinds.BreakStmt = 213
cursor_kinds.ReturnStmt = 214
cursor_kinds.GCCAsmStmt = 215
cursor_kinds.ObjCAtTryStmt = 216
cursor_kinds.ObjCAtCatchStmt = 217
cursor_kinds.ObjCAtFinallyStmt = 218
cursor_kinds.ObjCAtThrowStmt = 219
cursor_kinds.ObjCAtSynchronizedStmt = 220
cursor_kinds.ObjCAutoreleasePoolStmt = 221
cursor_kinds.ObjCForCollectionStmt = 222
cursor_kinds.CXXCatchStmt = 223
cursor_kinds.CXXTryStmt = 224
cursor_kinds.CXXForRangeStmt = 225
cursor_kinds.SEHTryStmt = 226
cursor_kinds.SEHExceptStmt = 227
cursor_kinds.SEHFinallyStmt = 228
cursor_kinds.MSAsmStmt = 229
cursor_kinds.NullStmt = 230
cursor_kinds.DeclStmt = 231
cursor_kinds.OMPParallelDirective = 232
cursor_kinds.OMPSimdDirective = 233
cursor_kinds.OMPForDirective = 234
cursor_kinds.OMPSectionsDirective = 235
cursor_kinds.OMPSectionDirective = 236
cursor_kinds.OMPSingleDirective = 237
cursor_kinds.OMPParallelForDirective = 238
cursor_kinds.OMPParallelSectionsDirective = 239
cursor_kinds.OMPTaskDirective = 240
cursor_kinds.OMPMasterDirective = 241
cursor_kinds.OMPCriticalDirective = 242
cursor_kinds.OMPTaskyieldDirective = 243
cursor_kinds.OMPBarrierDirective = 244
cursor_kinds.OMPTaskwaitDirective = 245
cursor_kinds.OMPFlushDirective = 246
cursor_kinds.SEHLeaveStmt = 247
cursor_kinds.OMPOrderedDirective = 248
cursor_kinds.OMPAtomicDirective = 249
cursor_kinds.OMPForSimdDirective = 250
cursor_kinds.OMPParallelForSimdDirective = 251
cursor_kinds.OMPTargetDirective = 252
cursor_kinds.OMPTeamsDirective = 253
cursor_kinds.TranslationUnit = 300
cursor_kinds.FirstAttr = 400
cursor_kinds.UnexposedAttr = 400
cursor_kinds.IBActionAttr = 401
cursor_kinds.IBOutletAttr = 402
cursor_kinds.IBOutletCollectionAttr = 403
cursor_kinds.CXXFinalAttr = 404
cursor_kinds.CXXOverrideAttr = 405
cursor_kinds.AnnotateAttr = 406
cursor_kinds.AsmLabelAttr = 407
cursor_kinds.PackedAttr = 408
cursor_kinds.PureAttr = 409
cursor_kinds.ConstAttr = 410
cursor_kinds.NoDuplicateAttr = 411
cursor_kinds.CUDAConstantAttr = 412
cursor_kinds.CUDADeviceAttr = 413
cursor_kinds.CUDAGlobalAttr = 414
cursor_kinds.CUDAHostAttr = 415
cursor_kinds.CUDASharedAttr = 416
cursor_kinds.PreprocessingDirective = 500
cursor_kinds.MacroDefinition = 501
cursor_kinds.MacroExpansion = 502
cursor_kinds.InclusionDirective = 503
cursor_kinds.ModuleImportDecl = 600
local completion_map = { }
completion_map[0] = 'Optional'
completion_map[1] = 'TypedText'
completion_map[2] = 'Text'
completion_map[3] = 'Placeholder'
completion_map[4] = 'Informative'
completion_map[5] = 'CurrentParameter'
completion_map[6] = 'LeftParen'
completion_map[7] = 'RightParen'
completion_map[8] = 'LeftBracket'
completion_map[9] = 'RightBracket'
completion_map[10] = 'LeftBrace'
completion_map[11] = 'RightBrace'
completion_map[12] = 'LeftAngle'
completion_map[13] = 'RightAngle'
completion_map[14] = 'Comma'
completion_map[15] = 'ResultType'
completion_map[16] = 'Colon'
completion_map[17] = 'SemiColon'
completion_map[18] = 'Equal'
completion_map[19] = 'HorizontalSpace'
completion_map[20] = 'VerticalSpace'
local completion_kinds = { }
completion_kinds.Optional = 0
completion_kinds.TypedText = 1
completion_kinds.Text = 2
completion_kinds.Placeholder = 3
completion_kinds.Informative = 4
completion_kinds.CurrentParameter = 5
completion_kinds.LeftParen = 6
completion_kinds.RightParen = 7
completion_kinds.LeftBracket = 8
completion_kinds.RightBracket = 9
completion_kinds.LeftBrace = 10
completion_kinds.RightBrace = 11
completion_kinds.LeftAngle = 12
completion_kinds.RightAngle = 13
completion_kinds.Comma = 14
completion_kinds.ResultType = 15
completion_kinds.Colon = 16
completion_kinds.SemiColon = 17
completion_kinds.Equal = 18
completion_kinds.HorizontalSpace = 19
completion_kinds.VerticalSpace = 20
local unsaved_files
unsaved_files = function(unsaved)
  local unsaved_len = 0
  for _ in pairs(unsaved) do
    unsaved_len = unsaved_len + 1
  end
  local unsaved_c = ffi.new('struct CXUnsavedFile[?]', unsaved_len)
  local i = 0
  for p, v in pairs(unsaved) do
    unsaved_c[i].Filename = p
    unsaved_c[i].Contents = v
    unsaved_c[i].Length = ffi.new('int', #v)
    i = i + 1
  end
  return {
    unsaved_c,
    unsaved_len
  }
end
local opts
opts = function(options)
  local res = 0
  for _index_0 = 1, #options do
    local opt = options[_index_0]
    res = bit.bor(res, opt)
  end
  return res
end
local CursorKind
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, value)
      self.value = value
      self.string = cursor_map[self.value]
    end,
    __base = _base_0,
    __name = "CursorKind"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CursorKind = _class_0
end
local CompletionKind
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, value)
      self.value = value
      self.string = completion_map[self.value]
    end,
    __base = _base_0,
    __name = "CompletionKind"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CompletionKind = _class_0
end
local CompletionChunk
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, text, kind)
      self.text, self.kind = text, kind
    end,
    __base = _base_0,
    __name = "CompletionChunk"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CompletionChunk = _class_0
end
local CompletionString
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, __string)
      self.__string = __string
      local chunk_count = libclang.clang_getNumCompletionChunks(self.__string)
      self.chunks = { }
      for i = 0, chunk_count - 1 do
        local text = ffi.string(libclang.clang_getCString(libclang.clang_getCompletionChunkText(self.__string, i)))
        local kind = CompletionKind(libclang.clang_getCompletionChunkKind(self.__string, i))
        self.chunks[i + 1] = CompletionChunk(text, kind)
      end
      self.priority = libclang.clang_getCompletionPriority(self.__string)
    end,
    __base = _base_0,
    __name = "CompletionString"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CompletionString = _class_0
end
local CompletionResult
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, __result)
      self.__result = __result
      self.kind = CursorKind(self.__result.CursorKind)
      self.string = CompletionString(self.__result.CompletionString)
    end,
    __base = _base_0,
    __name = "CompletionResult"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CompletionResult = _class_0
end
local CompletionResults
do
  local _class_0
  local _base_0 = {
    sort = function(self)
      return liblcang.clang_sortCodeCompletionResults(self.__results[0].Results, self.__results[0].NumResults)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, __results)
      self.__results = __results
      self.__results = ffi.gc(self.__results, libclang.clang_disposeCodeCompleteResults)
      do
        local _tbl_0 = { }
        for i = 1, self.__results[0].NumResults do
          _tbl_0[i] = CompletionResult(self.__results[0].Results[i - 1])
        end
        self.results = _tbl_0
      end
    end,
    __base = _base_0,
    __name = "CompletionResults"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CompletionResults = _class_0
end
local Cursor
do
  local _class_0
  local _base_0 = {
    visit = function(self, func)
      local cb = ffi.cast('ljclang_callback', function(cursor, parent, _)
        return func(Cursor(cursor[0]), Cursor(parent[0])) or self.__class.visit_continue
      end)
      libclang.clang_visitChildren(self.__cursor, libclang.ljclang_tree_visitor, ffi.cast('void*', cb))
      cb:free()
      return nil
    end,
    get_children = function(self)
      local res = { }
      local count = 0
      self:visit(function(cursor, _)
        res[count] = cursor
        count = count + 1
        return cursor.visit_continue
      end)
      return res
    end,
    get_completion_string = function(self)
      return CompletionString(libclang.clang_getCursorCompletionString(self.__cursor))
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, __cursor)
      self.__cursor = __cursor
      self.visit_break = self.__class.visit_break
      self.visit_continue = self.__class.visit_continue
      self.visit_recurse = self.__class.visit_recurse
      self.spelling = ffi.string(libclang.clang_getCString(libclang.clang_getCursorSpelling(self.__cursor)))
      if self.spelling == '' then
        self.spelling = nil
      end
      self.kind = CursorKind(libclang.clang_getCursorKind(self.__cursor))
    end,
    __base = _base_0,
    __name = "Cursor"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.visit_break = libclang.CXChildVisit_Break
  self.visit_continue = libclang.CXChildVisit_Continue
  self.visit_recurse = libclang.CXChildVisit_Recurse
  Cursor = _class_0
end
local TranslationUnit
do
  local _class_0
  local _base_0 = {
    reparse = function(self, unsaved, options)
      if unsaved == nil then
        unsaved = { }
      end
      if options == nil then
        options = { }
      end
      local unsaved_c, unsaved_len
      do
        local _obj_0 = unsaved_files(unsaved)
        unsaved_c, unsaved_len = _obj_0[1], _obj_0[2]
      end
      local res = libclang.clang_reparseTranslationUnit(self.__unit, unsaved_len, unsaved_c, opts(options))
      return assert(res == 0)
    end,
    complete_at = function(self, filename, line, column, unsaved)
      local unsaved_c, unsaved_len
      do
        local _obj_0 = unsaved_files(unsaved)
        unsaved_c, unsaved_len = _obj_0[1], _obj_0[2]
      end
      return CompletionResults(libclang.clang_codeCompleteAt(self.__unit, filename, line, column, unsaved_c, unsaved_len, 0))
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, __unit)
      self.__unit = __unit
      self.__unit = ffi.gc(self.__unit, libclang.clang_disposeTranslationUnit)
      self.cursor = Cursor(libclang.clang_getTranslationUnitCursor(self.__unit))
    end,
    __base = _base_0,
    __name = "TranslationUnit"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.DetailedPreprocessingRecord = 0x01
  self.Incomplete = 0x02
  self.PrecompiledPreamble = 0x04
  self.CacheCompletionResults = 0x08
  self.ForSerialization = 0x10
  self.CXXChainedPCH = 0x20
  self.SkipFunctionBodies = 0x40
  self.IncludeBriefCommentsInCodeCompletion = 0x80
  TranslationUnit = _class_0
end
local Index
do
  local _class_0
  local _base_0 = {
    parse = function(self, path, args, unsaved, options)
      if args == nil then
        args = { }
      end
      if unsaved == nil then
        unsaved = { }
      end
      if options == nil then
        options = { }
      end
      local unsaved_c, unsaved_len
      do
        local _obj_0 = unsaved_files(unsaved)
        unsaved_c, unsaved_len = _obj_0[1], _obj_0[2]
      end
      local args_c = ffi.new('const char*[?]', #args, args)
      local unit = libclang.clang_parseTranslationUnit(self.__index, path, args_c, #args, unsaved_c, unsaved_len, opts(options))
      assert(unit ~= nil)
      return TranslationUnit(unit)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, exclude_pch_decls, display_diagnostics)
      if exclude_pch_decls == nil then
        exclude_pch_decls = 0
      end
      if display_diagnostics == nil then
        display_diagnostics = 1
      end
      self.__index = ffi.gc(libclang.clang_createIndex(exclude_pch_decls, display_diagnostics), libclang.clang_disposeIndex)
    end,
    __base = _base_0,
    __name = "Index"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Index = _class_0
end
return {
  Index = Index,
  TranslationUnit = TranslationUnit,
  Cursor = Cursor,
  CursorKind = CursorKind,
  CompletionChunk = CompletionChunk,
  CompletionString = CompletionString,
  CompletionResult = CompletionResult,
  CompletionResults = CompletionResults,
  cursor_kinds = cursor_kinds,
  completion_kinds = completion_kinds
}
