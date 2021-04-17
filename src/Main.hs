{-# LANGUAGE DataKinds, DeriveGeneric, OverloadedStrings, TypeOperators #-}
module Main where

import Control.Lens
import Control.Monad(when)
import Control.Monad.IO.Class(liftIO)
import Data.List.NonEmpty
import Data.Maybe(fromMaybe)
import Data.Text
import qualified Data.Text.IO as T
import qualified Data.Text.Lazy as L
import Network.AWS.Route53.ChangeResourceRecordSets
import Network.AWS.Route53.Types
import Network.AWS
import Options.Applicative
import System.Exit (exitFailure, exitSuccess)
import System.IO
import Text.PrettyPrint.ANSI.Leijen(text, (<$$>))


data SourceOptions = SourceOptions
  { dom :: Text
  , rid :: Text
  , ip :: Text }

source :: Parser SourceOptions
source = SourceOptions
  <$> Options.Applicative.argument str (metavar "domain")
  <*> Options.Applicative.argument str (metavar "amazon_route53_zone_id")
  <*> Options.Applicative.argument str (metavar "ipv4")

updateIP :: SourceOptions -> IO ()
updateIP (SourceOptions domain zoneid ipv4) = do
  lgr <- newLogger Debug stdout
  env <- newEnv Discover
  T.appendFile ("ip_" ++ (unpack domain) ++ ".txt") ""
  oldIP <- T.readFile ("ip_" ++ (unpack domain) ++ ".txt")
  T.writeFile ("ip_" ++ (unpack domain) ++ ".txt") ipv4
  when (oldIP /= ipv4)
       (do runResourceT $ runAWS (env & envLogger .~ lgr) $
                          within Frankfurt $ send (b domain zoneid ipv4)
           putStrLn "IP has changed"
           putStrLn (show (domain, zoneid, ipv4)))
  return ()


b :: Text -> Text -> Text -> ChangeResourceRecordSets
b domain rid ip =
 changeResourceRecordSets (ResourceId rid)
   (changeBatch $
     (change Upsert $ resourceRecordSet domain A & rrsTTL .~ Just 60 & rrsResourceRecords .~ (Just (pure (resourceRecord ip)))) :| [])


main :: IO ()
main = do
  execParser opts >>= updateIP
  exitSuccess
 where
  opts = info (helper <*> source)
   (   fullDesc
    <> progDescDoc (Just (
       (text "") <$$>
       (text "See cronjob-route53 -h for details.")))
    <> header "" )

-- cronjob-route53 *.example.com Z32NAI0V3I6P4A $(dig +short wm.myfritz.net)
