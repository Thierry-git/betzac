import qualified CoreSpec as CoreSpec
import Test.Hspec

main :: IO ()
main = hspec $ do
    CoreSpec.spec
