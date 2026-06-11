import qualified Lexer.CoreSpec as CoreSpec
import qualified Lexer.ExprQC as ExprQC
import Test.Hspec

main :: IO ()
main = do
    hspec CoreSpec.spec
    putStrLn "" >> putStrLn "========= QuickCheck ========="
    hspec ExprQC.spec
