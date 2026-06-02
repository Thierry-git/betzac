module Betzac.Alphabet.Comp (
    pathSep,
    compAlphabet,
) where

import Betzac.Alphabet.Stmt (stmtAlphabet)

pathSep :: Char
pathSep = '.'

compAlphabet :: String
compAlphabet = pathSep : stmtAlphabet
