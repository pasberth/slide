import qualified GHCJS.Types    as T
import qualified GHCJS.Foreign  as F

foreign import javascript unsafe "alert($1)" js_alert :: T.JSString -> IO ()

alert :: String -> IO ()
alert s = js_alert $ F.toJSString s

main :: IO ()
main = alert "hello world"
