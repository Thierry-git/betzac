module Betzac.Lexer.Scan (
    lexIgnore,
) where

import Betzac.Lexer.Core
import Betzac.Lexer.Expr

lexComment :: Lexer ()
lexComment = (() <$) (char '#' >> (many $ sat (/= '\n')))

lexIgnore :: Lexer ()
lexIgnore = () <$ many (lexWhitespace <|> lexComment)
