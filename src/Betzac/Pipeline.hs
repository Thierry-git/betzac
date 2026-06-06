module Betzac.Pipeline (
    lexSource,
    PipelineResult (..),
) where

import Betzac.Lexer.Core (LexError (..), runLexer)
import Betzac.Lexer.Expr (lexExpr)
import Betzac.Token (Token)
import Data.Text (Text)

lexSource :: String -> Either LexError [Token]
lexSource s = case runLexer lexExpr s of
    Left err -> Left err
    Right (tokens, pos, remaining) -> case remaining of
        [] -> Right tokens
        _ -> Left (LexError pos)

data PipelineResult = PipelineResult
    { sourceText :: Text
    , lexResult :: Maybe (Either LexError [Token])
    }
