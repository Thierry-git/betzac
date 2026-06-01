import qualified Betzac.Lexer.CoreSpec as CoreSpec
import Test.Hspec

main :: IO ()
main = hspec $ do
    CoreSpec.spec
