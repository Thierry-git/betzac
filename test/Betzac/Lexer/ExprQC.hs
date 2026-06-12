module Lexer.ExprQC (spec) where

import Betzac.Alphabet.Expr (alphanum, behaviour, direction, exprAlphabet, space, upper, whitespace)
import Betzac.Lexer.Expr (lexExpr, runLexer)
import Betzac.Token
import Data.List (intercalate)
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck

unlex :: [Token] -> String
unlex [] = ""
unlex (t : ts) = s <> unlex ts
  where
    s = case t of
        TokAtom c -> [c]
        TokDescriptor d -> ":" <> d <> ":"
        TokDirection c -> [c]
        TokBehaviour c -> [c]
        TokLParen -> "("
        TokRParen -> ")"
        TokLBracket -> "["
        TokRBracket -> "]"
        TokLBrace -> "{"
        TokRBrace -> "}"
        TokLAngle -> "<"
        TokRAngle -> ">"
        TokChainStep -> "-"
        TokChainSequence -> "--"
        TokBang -> "!"
        TokSlippery -> "0*"
        TokNumber n -> show n
        TokComma -> ","

descriptor :: Gen String
descriptor = intercalate [space] <$> resize 4 (listOf1 $ resize 7 $ listOf1 $ elements (',' : alphanum))

token :: Gen Token
token = sized $ \n ->
    oneof
        [ TokAtom <$> elements upper
        , TokDescriptor <$> descriptor
        , TokDirection <$> elements direction
        , TokBehaviour <$> elements behaviour
        , oneof [pure TokLParen, pure TokRParen]
        , oneof [pure TokLBracket, pure TokRBracket]
        , oneof [pure TokLBrace, pure TokRBrace]
        , oneof [pure TokLAngle, pure TokRAngle]
        , oneof [pure TokChainStep, pure TokChainSequence]
        , pure TokBang
        , pure TokSlippery
        , frequency
            [ (1, pure $ TokNumber 0)
            , (3, TokNumber <$> choose (0, let n' = (n + 1) `div` 5 in 10 ^ n'))
            ]
        , pure TokComma
        ]

lexable :: Gen String
lexable = unlex <$> listOf1 token

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
