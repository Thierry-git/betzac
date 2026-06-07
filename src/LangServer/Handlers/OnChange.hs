{-# LANGUAGE DataKinds #-}

module LangServer.Handlers.OnChange (onChange) where

import Control.Lens ((^.))
import Data.Maybe (listToMaybe)
import Data.Text (Text, unpack)
import LangServer.Config (ConfigBLS)
import LangServer.Handlers.Core (publishLexDiagnostics)
import Language.LSP.Protocol.Lens hiding (changes)
import Language.LSP.Protocol.Message
import Language.LSP.Protocol.Types
import Language.LSP.Server (LspM)

getChangeText :: TextDocumentContentChangeEvent -> Text
getChangeText (TextDocumentContentChangeEvent (InL partial)) = partial ^. text
getChangeText (TextDocumentContentChangeEvent (InR whole)) = whole ^. text

onChange :: TNotificationMessage Method_TextDocumentDidChange -> LspM ConfigBLS ()
onChange msg = do
    let docId = msg ^. params . textDocument
        changes = msg ^. params . contentChanges
        content = maybe "" (unpack . getChangeText) (listToMaybe (reverse changes))
    publishLexDiagnostics (docId ^. uri) content
