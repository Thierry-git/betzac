module LangServer.Handlers.Core (makeDiagnostic) where

import Data.Text
import Language.LSP.Protocol.Types

makeDiagnostic :: Int -> Text -> Diagnostic
makeDiagnostic pos message =
    let
        position = Position 0 (fromIntegral pos)
        range = Range position position
        severity = Just DiagnosticSeverity_Error
     in
        Diagnostic range severity Nothing Nothing Nothing message Nothing Nothing Nothing
