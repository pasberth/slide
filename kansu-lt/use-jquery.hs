{-# LANGUAGE OverloadedStrings #-}

import JavaScript.JQuery

main :: IO ()
main = do
  select "body" >>= setHtml "<h1>hello world</h1>"
  return ()
