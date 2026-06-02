module Betzac.Lexer.Core (
    module Control.Applicative,
    Lexer (..),
    LexError (..),
    liftMaybe,
    peek,
    advance,
    sat,
    failOn,
    char,
    oneOf,
    noneOf,
) where

import Control.Applicative (Alternative (..))
import Data.Bifunctor (Bifunctor (first))
import Data.Maybe (listToMaybe)

newtype Lexer a = Lexer {runLexer :: String -> Either LexError (a, String)}

data LexError = LexError deriving (Eq, Show)

instance Functor Lexer where
    fmap f (Lexer g) = Lexer $ \s -> fmap (first f) (g s)

instance Applicative Lexer where
    pure a = Lexer $ \s -> Right (a, s)
    (<*>) l a = l >>= \f -> fmap f a

instance Monad Lexer where
    l >>= f = Lexer $ \s -> do
        (a, s') <- runLexer l $ s
        runLexer (f a) s'

instance Alternative Lexer where
    empty = Lexer $ const $ Left LexError
    l <|> r = Lexer $ \s -> case runLexer l s of
        Left _ -> runLexer r s
        Right a -> Right a
    many p = Lexer $ \s -> runLexer (some p <|> pure []) s
    some p = do
        x <- p
        xs <- many p
        return (x : xs)

liftMaybe :: LexError -> Maybe a -> Lexer a
liftMaybe err = maybe (Lexer $ const $ Left err) pure

peek :: Lexer (Maybe Char)
peek = Lexer $ \s -> Right (listToMaybe s, s)

advance :: Lexer Char
advance = Lexer go
  where
    go [] = Left LexError
    go (c : cs) = Right (c, cs)

sat :: (Char -> Bool) -> Lexer Char
sat p = do
    c <- peek >>= liftMaybe LexError
    if p c then advance else empty

failOn :: (Char -> Bool) -> Lexer ()
failOn p = do
    mc <- peek
    case mc of
        Just c | p c -> empty
        _ -> return ()

char :: Char -> Lexer Char
char c = sat (== c)

oneOf :: String -> Lexer Char
oneOf s = sat $ (`elem` s)

noneOf :: String -> Lexer Char
noneOf s = sat (`notElem` s)
