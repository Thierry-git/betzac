module Betzac.Lexer.Scan (
    lexToken,
    lexAll,
)
where

import Betzac.Lexer.Core
import Betzac.Token
import Control.Applicative

lexToken :: Lexer Token
lexToken = undefined

lexAll :: Lexer [Token]
lexAll = many lexToken
