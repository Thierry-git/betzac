module Betzac.Lexer.CoreSpec (spec) where

import Betzac.Lexer.Core
import Data.Char
import Test.Hspec

-- shouldSucceed :: Either LexError a -> Expectation
-- shouldSucceed (Left e) = expectationFailure $ "expected success but got: " ++ show e
-- shouldSucceed (Right _) = return ()

shouldFail :: (Show a) => Either LexError a -> Expectation
shouldFail (Left _) = return ()
shouldFail (Right x) = expectationFailure $ "expected failure but got: " ++ show x

runLexer' :: Lexer a -> String -> Either LexError (a, String)
runLexer' l s = fmap (\(a, _, s') -> (a, s')) (runLexer l s)

posOf :: Lexer a -> String -> Either LexError Int
posOf l s = fmap (\(_, n, _) -> n) (runLexer l s)

spec :: Spec
spec = do
    describe "advance" $ do
        it "consumes and returns the first character" $
            runLexer' advance "abc" `shouldBe` Right ('a', "bc")
        it "fails on empty input" $
            shouldFail $
                runLexer' advance ""

    describe "peek" $ do
        it "returns the first character without consuming" $
            runLexer' peek "abc" `shouldBe` Right (Just 'a', "abc")
        it "returns Nothing on empty input" $
            runLexer' peek "" `shouldBe` Right (Nothing, "")

    describe "sat" $ do
        context "when the predicate is satisfied" $
            it "consumes and returns the first character" $ do
                runLexer' (sat $ \c -> c `elem` ['A' .. 'Z']) "Haskell" `shouldBe` Right ('H', "askell")
                runLexer' (sat $ const True) "anything!" `shouldBe` Right ('a', "nything!")
        context "when the predicate is not satisfied" $
            it "fails" $ do
                shouldFail $ runLexer' (sat $ \c -> c `notElem` ['A' .. 'Z']) "Haskell"
                shouldFail $ runLexer' (sat $ const False) "nothing..."
        it "fails on empty input" $
            shouldFail $
                runLexer' (sat $ const True) ""

    describe "char" $ do
        it "consumes and returns the first character if the next char matches" $
            runLexer' (char 'b') "betzac" `shouldBe` Right ('b', "etzac")
        it "fails when the character does not match" $
            shouldFail $
                runLexer' (char '_') "betzac"

    describe "fmap" $ do
        it "applies a function to the result without affecting the stream" $
            runLexer' (fmap toUpper $ char 'h') "hello" `shouldBe` Right ('H', "ello")

    describe "<*>" $ do
        it "sequences two lexers and applies the function to both results" $
            runLexer' ((\a b -> [a, b]) <$> char 'h' <*> char 'e') "hello" `shouldBe` Right ("he", "llo")
        it "fails if any lexer in the sequence fails" $
            shouldFail $
                runLexer' ((\a b -> [a, b]) <$> char 'h' <*> char 'x') "hello"

    describe "many" $ do
        it "consumes as many matching characters as possible" $
            runLexer' (many $ sat $ \c -> c `elem` ['a' .. 'z']) "hello123" `shouldBe` Right ("hello", "123")
        it "returns an empty list when nothing matches" $
            runLexer' (many $ sat $ \c -> c `elem` ['a' .. 'z']) "123" `shouldBe` Right ("", "123")
        it "returns an empty list on empty input" $
            runLexer' (many $ sat $ const False) "" `shouldBe` Right ("", "")

    describe "some" $ do
        it "consumes as many matching characters as possible" $
            runLexer' (some $ sat $ \c -> c `elem` ['a' .. 'z']) "hello123" `shouldBe` Right ("hello", "123")
        it "fails when the next character does not match" $ do
            shouldFail $ runLexer' (some $ sat $ \c -> c `elem` ['a' .. 'z']) "123"
            shouldFail $ runLexer' (some $ sat $ \c -> c `elem` ['a' .. 'z']) "321olleh"
        it "fails on empty input" $
            shouldFail $
                runLexer' (some $ sat $ \c -> c `elem` ['a' .. 'z']) ""

    describe "<|>" $ do
        it "returns the first success" $
            runLexer' (char 'x' <|> char 'h') "hello" `shouldBe` Right ('h', "ello")
        it "fails when both alternatives fail" $
            shouldFail $
                runLexer' (char 'x' <|> char 'y') "hello"

    describe "position tracking" $ do
        it "starts at 0" $
            posOf (return ()) "abc" `shouldBe` Right 0
        it "increments by 1 per advance" $
            posOf advance "abc" `shouldBe` Right 1
        it "tracks position across multiple advances" $
            posOf (advance >> advance >> advance) "abc" `shouldBe` Right 3
        it "reports correct position on failure" $ do
            posOf (advance >> advance >> char 'x') "abcd" `shouldBe` Left (LexError 2)
            posOf (many (char 'a') >> char 'x') "aaab" `shouldBe` Left (LexError 3)
        it "resets position on failure in <|>" $
            posOf (advance >> (char '_' <|> return '_')) "abc" `shouldBe` Right 1
        context "many" $ do
            it "tracks position through" $
                posOf (many $ char 'a') "aaa" `shouldBe` Right 3
            it "returns position 0 on empty input" $
                posOf (many advance) "" `shouldBe` Right 0
