module Betzac.Lexer.Scan (
    lexToken,
    lexAll,
    runLexer,
)
where

import Betzac.Lexer.Core
import Betzac.Token

whitespace :: String
whitespace = " \n\t\r\f\b"

lexWhitespace :: Lexer ()
lexWhitespace = () <$ some (oneOf whitespace)

lexComment :: Lexer ()
lexComment = (() <$) (char '#' >> (many $ sat (/= '\n')))

lexIgnore :: Lexer ()
lexIgnore = () <$ many (lexWhitespace <|> lexComment)

lexToken :: Lexer Token
lexToken = TokDescriptor <$> some (sat $ \c -> c `notElem` whitespace)

lexAll :: Lexer [Token]
lexAll = lexIgnore >> many lexTokenIgnore
  where
    lexTokenIgnore = do
        t <- lexToken
        lexIgnore >> return t
