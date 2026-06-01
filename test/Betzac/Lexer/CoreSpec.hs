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
