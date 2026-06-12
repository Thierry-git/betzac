module Betzac.Alphabet.Expr (
    space,
    whitespace,
    upper,
    alpha,
    nonzeroDigit,
    digit,
    alphanum,
    symbol,
    exprAlphabet,
    direction,
    behaviour,
)
where

import Prelude hiding (Word)

space :: Char
space = ' '

whitespace :: String
whitespace = space : "\n\t\r\f\b"

upper :: String
upper = ['A' .. 'Z']

alpha :: String
alpha = upper ++ ['a' .. 'z']

nonzeroDigit :: String
nonzeroDigit = ['1' .. '9']

direction :: String
direction = "fblrsva"

behaviour :: String
behaviour = "cgijmnpy"

digit :: String
digit = '0' : nonzeroDigit

alphanum :: String
alphanum = alpha ++ digit

symbol :: String
symbol = "(,)<>-[]{}*:+?!"

exprAlphabet :: String
exprAlphabet = alphanum ++ symbol
