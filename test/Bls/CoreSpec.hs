{-# LANGUAGE OverloadedStrings #-}

module CoreSpec (spec) where

import Control.Lens
import Control.Monad.IO.Class (liftIO)
import Data.Text (pack)
import Language.LSP.Protocol.Lens hiding (context, length)
import Language.LSP.Protocol.Types
import Language.LSP.Test
import Test.Hspec

betzaKind :: LanguageKind
betzaKind = LanguageKind_Custom "betza"

blsSession :: Session () -> IO ()
blsSession = runSession "bls" fullLatestClientCaps "."

spec :: Spec
spec = describe "bls" $ do
    describe "textDocument/didOpen" $ do
        context "with valid expressions" $ do
            it "produces no diagnostics for a simple atom" $
                blsSession $ do
                    diags <- createDoc "test.betza" betzaKind (pack "W") >> waitForDiagnostics
                    liftIO $ diags `shouldBe` []

            it "produces no diagnostics for a modified atom" $
                blsSession $ do
                    diags <- createDoc "test.betza" betzaKind (pack "W") >> waitForDiagnostics
                    liftIO $ diags `shouldBe` []

            it "produces no diagnostics for a chained expression" $
                blsSession $ do
                    diags <- createDoc "test.betza" betzaKind (pack "fW-[B]") >> waitForDiagnostics
                    liftIO $ diags `shouldBe` []

            it "produces no diagnostics for a complex expression" $
                blsSession $ do
                    diags <- createDoc "test.betza" betzaKind (pack "fWbF") >> waitForDiagnostics
                    liftIO $ diags `shouldBe` []

            it "produces no diagnostics for whitespace between tokens" $
                blsSession $ do
                    diags <- createDoc "test.betza" betzaKind (pack "fW bF") >> waitForDiagnostics
                    liftIO $ diags `shouldBe` []

        context "with invalid expressions" $ do
            it "produces a diagnostic for a character outside the alphabet" $
                blsSession $ do
                    diags <- createDoc "test.betza" betzaKind (pack "fW@bF") >> waitForDiagnostics
                    liftIO $ length diags `shouldBe` 1

            it "produces a diagnostic for a hash character" $
                blsSession $ do
                    diags <- createDoc "test.betza" betzaKind (pack "#comment") >> waitForDiagnostics
                    liftIO $ length diags `shouldBe` 1

            it "reports the diagnostic at the correct position" $
                blsSession $ do
                    diags <- createDoc "test.betza" betzaKind (pack "fW@bF") >> waitForDiagnostics
                    let pos = diags !! 0 ^. range . start . character
                    liftIO $ pos `shouldBe` 2

            it "produces exactly one diagnostic even for multiple invalid characters" $
                blsSession $ do
                    diags <- createDoc "test.betza" betzaKind (pack "@@@@") >> waitForDiagnostics
                    liftIO $ length diags `shouldBe` 1
