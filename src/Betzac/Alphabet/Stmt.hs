module Betzac.Alphabet.Stmt (
    assign,
    stmtEnd,
    stmtAlphabet,
) where

import Betzac.Alphabet.Expr (exprAlphabet)

assign :: Char
assign = '='

stmtEnd :: Char
stmtEnd = ';'

stmtAlphabet :: String
stmtAlphabet = assign : stmtEnd : exprAlphabet
