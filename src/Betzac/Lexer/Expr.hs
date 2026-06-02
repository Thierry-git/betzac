module Betzac.Lexer.Expr (
    lexWhitespace,
    lexToken,
    lexExpr,
    runLexer,
)
where

import Betzac.Alphabet.Expr (exprAlphabet, whitespace)
import Betzac.Lexer.Core
import Betzac.Token

lexWhitespace :: Lexer ()
lexWhitespace = () <$ many (oneOf whitespace)

lexExpr :: Lexer [Token]
lexExpr = failOn (`elem` whitespace) >> many (lexToken <* lexWhitespace)

lexToken :: Lexer Token
lexToken = TokDescriptor <$> some (oneOf exprAlphabet)
