module Token (Token) where

import AST (Behaviour, Direction)

data Token
  = TokAtom Char
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
  | TokColon
  | TokComma
  deriving (Show)
