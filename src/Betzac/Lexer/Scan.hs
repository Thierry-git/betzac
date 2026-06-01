module Betzac.Lexer.Scan
  ( lexToken,
    lexAll,
  )
where

import Betzac.Lexer.Core
import Betzac.Token

lexToken :: Lexer Token
lexToken = undefined

lexAll :: Lexer [Token]
lexAll = do
  mc <- peek
  case mc of
    Nothing -> return []
    Just _ -> do
      t <- lexToken
      ts <- lexAll
      return (t : ts)
