{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module LangServer.Handlers.OnOpen (onOpen) where

import Betzac.Lexer.Core (LexError (LexError))
import Betzac.Pipeline (lexSource)
import Control.Lens ((^.))
import Data.Text (unpack)
import LangServer.Config (ConfigBLS)
import LangServer.Handlers.Core (makeDiagnostic)
import Language.LSP.Diagnostics (partitionBySource)
import Language.LSP.Protocol.Lens (
    HasParams (params),
    HasTextDocument (textDocument),
    text,
    uri,
 )
import Language.LSP.Protocol.Message
import Language.LSP.Protocol.Types (
    Uri,
    toNormalizedUri,
 )
import Language.LSP.Server (LspM, publishDiagnostics)

onOpen :: TNotificationMessage Method_TextDocumentDidOpen -> LspM ConfigBLS ()
onOpen = \msg -> do
    let doc = msg ^. params . textDocument
        contents = doc ^. text
    publishLexDiagnostics (doc ^. uri) (unpack contents)

maxDiagnostics :: Int
maxDiagnostics = 100

publishLexDiagnostics :: Uri -> String -> LspM ConfigBLS ()
publishLexDiagnostics u source = do
    let diags = either toDiag (const []) (lexSource source) where
        toDiag (LexError pos) = [makeDiagnostic pos "Unexpected character"]
    Language.LSP.Server.publishDiagnostics maxDiagnostics (toNormalizedUri u) Nothing (partitionBySource diags)
