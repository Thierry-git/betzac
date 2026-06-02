module Betzac.Lexer.Expr (
    lexWhitespace,
    lexToken,
    lexExpr,
    runLexer,
)
where

import Betzac.Alphabet.Expr (alphanum, digit, nonzeroDigit, space, upper, whitespace)
import Betzac.Lexer.Core
import Betzac.Token

lexWhitespace :: Lexer ()
lexWhitespace = () <$ many (oneOf whitespace)

lexExpr :: Lexer [Token]
lexExpr = failOn (`elem` whitespace) >> many (lexToken <* lexWhitespace)

lexToken :: Lexer Token
lexToken =
    lexAtom
        <|> lexDescriptor
        <|> lexDirection
        <|> lexBehaviour
        <|> lexParen
        <|> lexBracket
        <|> lexBrace
        <|> lexAngle
        <|> lexChain
        <|> lexBang
        <|> lexNumber
        <|> lexComma

lexAtom :: Lexer Token
lexAtom = TokAtom <$> oneOf upper

lexDescriptor :: Lexer Token
lexDescriptor = TokDescriptor <$> (char ':' *> descriptor <* char ':')
  where
    descriptor = some (oneOf $ space : alphanum)

lexDirection :: Lexer Token
lexDirection = TokDirection <$> oneOf "fblrsva"

lexBehaviour :: Lexer Token
lexBehaviour = TokBehaviour <$> oneOf "cgijmnpy"

lexParen :: Lexer Token
lexParen = lparen <|> rparen
  where
    lparen = TokLParen <$ char '('
    rparen = TokRParen <$ char ')'

lexBracket :: Lexer Token
lexBracket = lbracket <|> rbracket
  where
    lbracket = TokLBracket <$ char '{'
    rbracket = TokRBracket <$ char '}'

lexBrace :: Lexer Token
lexBrace = lbrace <|> rbrace
  where
    lbrace = TokLBrace <$ char '['
    rbrace = TokRBrace <$ char ']'

lexAngle :: Lexer Token
lexAngle = langle <|> rangle
  where
    langle = TokLAngle <$ char '<'
    rangle = TokRAngle <$ char '>'

lexChain :: Lexer Token
lexChain = char '-' *> (TokChainSequence <$ char '-' <|> pure TokChainStep)

lexBang :: Lexer Token
lexBang = TokBang <$ char '!'

lexPosIntStr :: Lexer String
lexPosIntStr = (:) <$> oneOf nonzeroDigit <*> many (oneOf digit)

lexNumber :: Lexer Token
lexNumber = lexZeroStar <|> lexNonZero <|> lexZero
  where
    lexZeroStar = TokSlippery <$ (char '0' *> char '*')
    lexZero = TokNumber 0 <$ char '0'
    lexNonZero = TokNumber . read <$> lexPosIntStr

lexComma :: Lexer Token
lexComma = TokComma <$ char ','
