{-# LANGUAGE OverloadedStrings #-}

module CoreSpec (spec) where

import Control.Lens
import LangServer.Handlers.Core (makeDiagnostic)
import Language.LSP.Protocol.Lens hiding (length)
import Language.LSP.Protocol.Types
import Test.Hspec

spec :: Spec
spec = describe "makeDiagnostic" $ do
    it "sets severity to error" $
        makeDiagnostic 0 "msg" ^. severity `shouldBe` Just DiagnosticSeverity_Error

    it "sets the source to betzac" $
        makeDiagnostic 0 "msg" ^. source `shouldBe` Just "betzac"

    it "sets the message" $
        makeDiagnostic 3 "Unexpected character" ^. message `shouldBe` "Unexpected character"

    it "sets the character position correctly" $
        makeDiagnostic 5 "msg" ^. range . start . character `shouldBe` 5

    it "sets the line to 0" $
        makeDiagnostic 5 "msg" ^. range . start . line `shouldBe` 0

    it "positions the range start and end at the same character" $ do
        let diag = makeDiagnostic 3 "msg"
        diag ^. range . start `shouldBe` diag ^. range . end
