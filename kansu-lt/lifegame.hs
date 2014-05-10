{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE OverloadedStrings #-}

import qualified GHCJS.Types    as T
import qualified GHCJS.Foreign  as F
import           Control.Monad
import           Control.Lens
import qualified Data.Vector    as V
import qualified Data.Text      as T
import qualified Data.IORef     as R
import qualified JavaScript.JQuery as JQ

type Board = V.Vector (V.Vector Bool)

data CanvasContext_
type CanvasContext = T.JSRef CanvasContext_

foreign import javascript unsafe "$1[0].getContext('2d')" getContext :: JQ.JQuery -> IO CanvasContext
foreign import javascript unsafe "$1.fillRect($2,$3,$4,$5)" fillRect :: CanvasContext -> Int -> Int -> Int -> Int -> IO ()
foreign import javascript unsafe "$1.clearRect($2,$3,$4,$5)" clearRect :: CanvasContext -> Int -> Int -> Int -> Int -> IO ()
foreign import javascript unsafe "setInterval($1,$2)" setInterval :: T.JSFun a -> Int -> IO ()

updateBoard :: Int -> Int -> R.IORef Board -> IO ()
updateBoard width height boardRef = do
  board <- R.readIORef boardRef
  canvas <- JQ.select "#lifegame"
  cxt <- getContext canvas
  clearRect cxt 0 0 (width * 10) (height * 10)
  iRef <- R.newIORef 0
  jRef <- R.newIORef 0
  V.forM_ board $ \row -> do
    i <- R.readIORef iRef
    R.writeIORef jRef 0
    V.forM_ row $ \t -> do
      j <- R.readIORef jRef
      when t $ do
        fillRect cxt (i*2) (j*2) 2 2
      R.writeIORef jRef (j+1)
    R.writeIORef iRef (i+1)

step :: Int -> Int -> Board -> IO Board
step width height board = do
  newBoardRef <- R.newIORef board
  iRef <- R.newIORef 0
  jRef <- R.newIORef 0
  replicateM_ width $ do
    i <- R.readIORef iRef
    R.writeIORef jRef 0
    replicateM_ height $ do
      j <- R.readIORef jRef
      let getIsLive i' j' = if i' >= 0 && j' >= 0 && i' < width && j' < height
                              then (V.!) ((V.!) board i') j'
                              else False
      let isLive = getIsLive i j
      let isLive1 = getIsLive (i+1) j
      let isLive2 = getIsLive (i-1) j
      let isLive3 = getIsLive i (j+1)
      let isLive4 = getIsLive i (j-1)
      let isLive5 = getIsLive (i+1) (j+1)
      let isLive6 = getIsLive (i-1) (j+1)
      let isLive7 = getIsLive (i+1) (j-1)
      let isLive8 = getIsLive (i-1) (j-1)
      let neighbourCount = length (filter id [isLive1, isLive2, isLive3, isLive4, isLive5, isLive6, isLive7, isLive8])
      if
        | isLive && (neighbourCount == 2 || neighbourCount == 3) -> do
          return ()
        | isLive && (neighbourCount == 1 || neighbourCount == 4) -> do
          board <- R.readIORef newBoardRef
          R.writeIORef newBoardRef (board & element i . element j .~ False)
        | not isLive && (neighbourCount == 3) -> do
          board <- R.readIORef newBoardRef
          R.writeIORef newBoardRef (board & element i . element j .~ True)
        | otherwise -> do
          return ()
      R.writeIORef jRef (j+1)
    R.writeIORef iRef (i+1)
  R.readIORef newBoardRef

main :: IO ()
main = do
  let width = 100
  let height = 100
  boardRef <- R.newIORef (V.empty :: Board)
  replicateM height $ do
    board <- R.readIORef boardRef
    let row = V.replicate width False
    R.writeIORef boardRef (V.snoc board row)
  (do
    board <- R.readIORef boardRef
    let pentomino = board & element 51 . element 50 .~ True
                          & element 52 . element 50 .~ True
                          & element 50 . element 51 .~ True
                          & element 51 . element 51 .~ True
                          & element 51 . element 52 .~ True
    R.writeIORef boardRef pentomino)
  canvas <- JQ.select "#lifegame"
  JQ.setWidth (realToFrac (width * 5)) canvas
  JQ.setHeight (realToFrac (height * 5)) canvas
  callback <- F.syncCallback True True $ do
    R.readIORef boardRef >>= step width height >>= R.writeIORef boardRef
    updateBoard width height boardRef
  setInterval callback 100
