module Betzac.Token (Token (..)) where

data Token
    = TokAtom Char
    | TokDescriptor String
    | TokDirection Char
    | TokBehaviour Char
    | TokLParen
    | TokRParen
    | TokLBracket
    | TokRBracket
    | TokLBrace
    | TokRBrace
    | TokLAngle
    | TokRAngle
    | TokChainStep
    | TokChainSequence
    | TokBang
    | TokSlippery
    | TokNumber Int
    | TokComma
    deriving (Show)
