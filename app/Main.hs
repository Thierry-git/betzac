module Main (main) where

import Betzac.Lexer.Expr (lexExpr, runLexer)

main :: IO ()
main = do
    putStrLn "Om nom nom! Feed me stuff to lex (Ctrl+D to finish):"
    s <- getContents
    putStrLn . show $ runLexer lexExpr s
