module Betzac.AST
  ( BetzaExpr,
    Direction,
    Behaviour,
  )
where

data BetzaExpr = BetzaExpr ChainExpr
  deriving (Show)

data ChainExpr = ChainExpr OptionExpr (Maybe (ChainOperator, ChainExpr))
  deriving (Show)

data OptionExpr = Choose BetzaExpr | IffUnblocked BetzaExpr | Mandatory UnionExpr
  deriving (Show)

data UnionExpr = UnionExpr SetupExpr (Maybe UnionExpr)
  deriving (Show)

data SetupExpr = Setup ModifierExpr | NoSetup ModifierExpr
  deriving (Show)

data ModifierExpr = ModifierExpr [Modifier] ExponentExpr
  deriving (Show)

data ExponentExpr = ExponentExpr AtomExpr (Maybe Exponent)
  deriving (Show)

data AtomExpr = Paren BetzaExpr | From Label
  deriving (Show)

data ChainOperator = Step | Sequence
  deriving (Show)

data Modifier = Directional DirectionModifier | Behavioural Behaviour
  deriving (Show)

data DirectionModifier = Amalgamated Direction Direction | Single Direction
  deriving (Show)

data Direction = Forward | Backward | Leftward | Rightward | Sideway | Vertically | Any
  deriving (Show)

data Behaviour = Capture | Leap | Initial | Jump | Move | NoJump | Hop | All
  deriving (Show)

data Exponent = Infinite | Repeat Number | ModifiedRepeat (Maybe ChainOperator) [Modifier]
  deriving (Show)

type Number = Int

data Label = Upper Char | Descriptor String
  deriving (Show)
