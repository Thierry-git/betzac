module Betzac.Lexer.CoreSpec (spec) where

import Betzac.Lexer.Core
import Test.Hspec

spec :: Spec
spec = do
    describe "advance" $ do
        it "consumes and returns the first character" $
            runLexer advance "abc" `shouldBe` Right ('a', "bc")
        it "fails on empty input" $
            runLexer advance "" `shouldBe` Left LexError

        describe "peek" $ do
            it "returns the first character without consuming" $
                runLexer peek "abc" `shouldBe` Right (Just 'a', "abc")
            it "returns Nothing on empty input" $
                runLexer peek "" `shouldBe` Right (Nothing, "")

        describe "sat" $ do
            context "when the predicate is satisfied" $
                it "consumes and returns the first character" $ do
                    runLexer (sat $ \c -> c `elem` ['A' .. 'Z']) "Haskell" `shouldBe` Right ('H', "askell")
                    runLexer (sat $ const True) "anything!" `shouldBe` Right ('a', "nything!")
            context "when the predicate is not satisfied" $
                it "returns a LexError" $ do
                    runLexer (sat $ \c -> c `notElem` ['A' .. 'Z']) "Haskell" `shouldBe` Left LexError
                    runLexer (sat $ const False) "nothing..." `shouldBe` Left LexError

        describe "char" $ do
            it "consumes and returns the first character if the next char matches" $
                runLexer (char 'b') "betzac" `shouldBe` Right ('b', "etzac")
            it "returns a LexError if the next char does not match" $
                runLexer (char '_') "betzac" `shouldBe` Left LexError
