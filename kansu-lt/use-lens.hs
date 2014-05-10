{-# LANGUAGE TemplateHaskell #-}

import Control.Lens

data Foo a = Foo { _bar :: a }
makeLenses ''Foo

foo1 :: Foo String
foo1 = Foo { _bar = "baaaar" }

main :: IO ()
main = do
  putStrLn (foo1 ^. bar)
