module Main (main) where

import LangServer.Server (serverBLS)
import Language.LSP.Server (runServer)

main :: IO Int
main = runServer serverBLS
