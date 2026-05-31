{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module Betzac.Lexer.Core where

import Data.Maybe (listToMaybe)

newtype Lexer a = Lexer {runLexer :: String -> Either LexError (a, String)}

data LexError = LexError deriving (Eq, Show)

instance Functor Lexer where
  fmap f a = pure f <*> a

instance Applicative Lexer where
  pure a = Lexer $ \s -> Right (a, s)
  (<*>) l a = l >>= \f -> fmap f a

instance Monad Lexer where
  l >>= f = Lexer $ \s -> do
    (a, s') <- runLexer l $ s
    runLexer (f a) s'

liftMaybe :: LexError -> Maybe a -> Lexer a
liftMaybe err = maybe (Lexer $ const $ Left err) pure

peek :: Lexer (Maybe Char)
peek = Lexer $ \s -> Right (listToMaybe s, s)

advance :: Lexer Char
advance = Lexer go
  where
    go [] = Left LexError
    go (c : cs) = Right (c, cs)

satisfy :: (Char -> Bool) -> Lexer Char
satisfy p = Lexer sat
  where
    sat [] = Left LexError
    sat (c : cs) = if p c then Right (c, cs) else Left LexError

char :: Char -> Lexer Char
char c = satisfy (== c)
