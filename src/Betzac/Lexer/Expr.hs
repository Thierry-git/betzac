module Betzac.Lexer.Expr (
    lexToken,
    lexExpr,
    runLexer,
)
where

import Betzac.Alphabet.Expr (whitespace)
import Betzac.Lexer.Core
import Betzac.Token

lexWhitespace :: Lexer ()
lexWhitespace = () <$ some (oneOf whitespace)

lexComment :: Lexer ()
lexComment = (() <$) (char '#' >> (many $ sat (/= '\n')))

lexIgnore :: Lexer ()
lexIgnore = () <$ many (lexWhitespace <|> lexComment)

lexToken :: Lexer Token
lexToken = TokDescriptor <$> some (sat $ \c -> c `notElem` whitespace)

lexExpr :: Lexer [Token]
lexExpr = lexIgnore >> many lexTokenIgnore
  where
    lexTokenIgnore = do
        t <- lexToken
        lexIgnore >> return t
