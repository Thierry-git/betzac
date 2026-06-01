module Betzac.Token (Token (..)) where

import Betzac.AST (Behaviour, Direction)

data Token
    = TokAtom Char
    | TokDescriptor String
    | TokDirection Direction
    | TokBehaviour Behaviour
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
    | TokInfinite
    | TokNumber Int
    | TokComma
    deriving (Show)
