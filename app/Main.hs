module Main (main) where

import Betzac.Lexer.Scan (lexAll, runLexer)

main :: IO ()
main = putStrLn . show $ runLexer lexAll "  \n \t    #samkl mfl m a  mal mf\n\n\nSalut!"
