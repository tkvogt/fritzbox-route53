{-# LANGUAGE DataKinds, DeriveGeneric, OverloadedStrings, TypeOperators #-}
module Main where

import Control.Lens
import Control.Monad.IO.Class(liftIO)
import Data.List.NonEmpty
import Data.Maybe(fromMaybe)
import Network.AWS.Route53.ChangeResourceRecordSets
import Network.AWS.Route53.Types
import Network.AWS
import Network.Wai
import Network.Wai.Handler.Warp
import Options.Generic
import Servant
import Servant.API
import System.IO

b :: Text -> Text -> Text -> ChangeResourceRecordSets
b rid domain ip =
 changeResourceRecordSets (ResourceId rid)
   (changeBatch $
     (change Upsert $ resourceRecordSet domain A & rrsTTL .~ Just 60 & rrsResourceRecords .~ (Just (pure (resourceRecord ip)))) :| [])

-- call with: http://localhost:8090/update?hostname=test.example.com&zoneid=Z32NAI0V3I6P4A&ipv4=<ipaddr>
-- stack build --file-watch --fast --test --exec="register-homeip-route53 --rid=Z32NAI0V3I6P4A --domain=test.example.com --ip=89.247.99.130"

type Api = "update" :> QueryParam "hostname" Text :>
                       QueryParam "zoneid" Text :>
                       QueryParam "ipv4" Text :>
                       Get '[JSON] Bool
apiProxy :: Proxy Api
apiProxy = Proxy

updateIP :: Maybe Text -> Maybe Text -> Maybe Text -> Handler Bool
updateIP hostname zoneid ipv4 = do
  lgr <- newLogger Debug stdout
  env <- newEnv Discover
  liftIO $ putStrLn (show (hostname, zoneid, ipv4))
  liftIO $ runResourceT $ runAWS (env & envLogger .~ lgr) $
                          within Frankfurt $ send (b (fromMaybe "" zoneid) (fromMaybe "" hostname) (fromMaybe "" ipv4))
  return True

app :: Application
app = serve apiProxy updateIP

main :: IO ()
main = do
  run 8090 app

