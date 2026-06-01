{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module Betzac.Lexer.Core where

import Control.Applicative
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

instance Alternative Lexer where
  empty = Lexer $ const $ Left LexError
  l <|> r = Lexer $ \s -> case runLexer l s of
    Left _ -> runLexer r s
    Right a -> Right a

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
  c <- advance
  if p c then return c else empty

char :: Char -> Lexer Char
char c = sat (== c)
