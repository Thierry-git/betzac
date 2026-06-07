module LangServer.Config (defaultConfigBLS, ConfigBLS, optionsBLS) where

import Language.LSP.Protocol.Types
import Language.LSP.Server

data ConfigBLS = ConfigBLS

defaultConfigBLS :: ConfigBLS
defaultConfigBLS = ConfigBLS

optionsBLS :: Options
optionsBLS =
    defaultOptions
        { optTextDocumentSync = Just $ TextDocumentSyncOptions (Just True) (Just TextDocumentSyncKind_Full) (Just False) (Just False) Nothing
        }
