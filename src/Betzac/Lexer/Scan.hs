module Betzac.Lexer.Scan (
    lexToken,
    lexAll,
    runLexer,
)
where

import Betzac.Lexer.Core
import Betzac.Token

lexWhitespace :: Lexer ()
lexWhitespace = () <$ some (oneOf " \n\t\r\f\b")

lexComment :: Lexer ()
lexComment = (() <$) (char '#' >> (many $ sat (/= '\n')))

lexIgnore :: Lexer ()
lexIgnore = () <$ some (lexWhitespace <|> lexComment)

lexToken :: Lexer Token
lexToken = TokComma <$ lexIgnore

lexAll :: Lexer [Token]
lexAll = many lexToken
