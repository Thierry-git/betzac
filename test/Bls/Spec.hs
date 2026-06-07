import qualified CoreSpec as CoreSpec
import qualified HandlersSpec as HandlersSpec
import Test.Hspec

main :: IO ()
main = hspec $ do
    CoreSpec.spec
    HandlersSpec.spec
