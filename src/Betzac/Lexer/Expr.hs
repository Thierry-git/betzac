module Betzac.Lexer.Expr (
    lexWhitespace,
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

lexToken :: Lexer Token
lexToken = TokDescriptor <$> some (sat $ \c -> c `notElem` whitespace)

lexExpr :: Lexer [Token]
lexExpr = lexWhitespace *> many (lexToken <* lexWhitespace)
