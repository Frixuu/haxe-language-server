package haxeLanguageServer.features;

import jsonrpc.CancellationToken;
import jsonrpc.ResponseError;
import jsonrpc.Types.NoData;
import languageServerProtocol.Types;

class CodeActionFeature {
    var context:Context;
    var diagnostics:DiagnosticsManager;

    public function new(context:Context, diagnostics:DiagnosticsManager) {
        this.context = context;
        this.diagnostics = diagnostics;
        context.protocol.onRequest(Methods.CodeAction, onCodeAction);
    }

    function onCodeAction(params:CodeActionParams, token:CancellationToken, resolve:Array<Command>->Void, reject:ResponseError<NoData>->Void) {
        var codeActions = diagnostics.getCodeActions(params);
        codeActions = codeActions.concat(getRefactorings(params));
        resolve(codeActions);
    }

    function getRefactorings(params:CodeActionParams):Array<Command> {
        if (params.range.isEmpty()) return [];
        var doc = context.documents.get(params.textDocument.uri);
        var range = params.range;
        var startLine = range.start.line;
        var indent = doc.indentAt(startLine);
        var extraction = doc.getRange(range).replace("$", "\\$");
        var variable = '${indent}var $$ = $extraction;\n';
        var insertRange = {line: startLine, character: 0}.toRange();
        return [{
            title: "Extract variable",
            arguments: [params.textDocument.uri, 0, [{range: insertRange, newText: variable}, {range: params.range, newText: "$"}]],
            command: "haxe.applyFixes"
        }];
    }
}
