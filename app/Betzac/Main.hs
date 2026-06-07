module Main (main) where

import Betzac.Lexer.Core (LexError (..))
import Betzac.Pipeline (lexSource)
import Control.Monad
import System.IO

main :: IO ()
main = do
    hSetBuffering stdout NoBuffering
    hSetBuffering stdin NoBuffering
    putStrLn "Type a betza expression:"
    forever $ do
        putStr "> "
        line <- getLine
        case lexSource line of
            Left (LexError pos) -> putStrLn $ "Error at position " ++ show pos
            Right tokens -> mapM_ print tokens
