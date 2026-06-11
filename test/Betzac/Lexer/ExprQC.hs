module Lexer.ExprQC (spec) where

import Betzac.Alphabet.Expr (exprAlphabet, whitespace)
import Betzac.Lexer.Expr (lexExpr, runLexer)
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck

-- TODO: not even always lexable right now, because labels need two colons, e.g. :my descr:, to lex
lexable :: Gen String
lexable = (:) <$> elements exprAlphabet <*> lexableTail
  where
    lexableTail = sized $ \n ->
        frequency
            [ (1, (: []) <$> elements exprAlphabet)
            , (n, (:) <$> oneof [(elements exprAlphabet), (elements whitespace)] <*> lexable)
            ]

prop_lexableNoLeadingWhitespace :: Property
prop_lexableNoLeadingWhitespace = forAll lexable noLeadingWhitespace
  where
    noLeadingWhitespace [] = True
    noLeadingWhitespace (c : _) = c `notElem` whitespace

badChar :: Gen Char
badChar = arbitrary `suchThat` \c -> c `notElem` exprAlphabet <> whitespace

semiLexable :: Gen String
semiLexable = (<>) <$> lexable <*> listOf1 badChar

-- manyLexableStatements :: Gen String
-- manyLexableStatements = sized $ \n -> let n' = round $ sqrt (fromIntegral n :: Double) in intercalate ";" <$> vectorOf n' (resize n' lexable)

prop_lexableNeverFails :: Property
prop_lexableNeverFails = forAll lexable $ \s ->
    case runLexer lexExpr s of
        Left _ -> False
        Right _ -> True

-- No more tokens than characters
prop_informationReduction :: Property
prop_informationReduction = forAll lexable $ \s -> case runLexer lexExpr s of
    Left _ -> False
    Right (toks, _, _) -> length toks <= length s

prop_yieldOnGarbage :: Property
prop_yieldOnGarbage = forAll semiLexable $ \s ->
    case runLexer lexExpr s of
        Left _ -> False
        Right (_, l, _) -> l < length s

spec :: Spec
spec = describe "Lexer.Core" $ do
    context "test generators" $ do
        prop "lexable input is considered not to have leading whitespace" prop_lexableNoLeadingWhitespace
    describe "expression lexer" $ do
        prop "never fails on lexable strings" prop_lexableNeverFails
        prop "reduces the amount of information of lexable input" prop_informationReduction
        prop "yields with success on garbage characters" prop_yieldOnGarbage
