{-# LANGUAGE OverloadedStrings #-}

module Config where

import Network.Wai.Middleware.RequestLogger (logStdoutDev, logStdout)
import Network.Wai                          (Middleware)
import Control.Monad.Logger                 (runNoLoggingT, runStdoutLoggingT)

import Database.Persist.MySQL (ConnectionPool, createMySQLPool, ConnectInfo (..), defaultConnectInfo)

data Config = Config 
    { getPool :: ConnectionPool
    , getEnv  :: Environment
    }

data Environment = 
    Development
  | Test
  | Production
  deriving (Eq, Show, Read)

defaultConfig :: Config
defaultConfig = Config
    { getPool = undefined
    , getEnv  = Development
    }

setLogger :: Environment -> Middleware
setLogger Test = id
setLogger Development = logStdoutDev
setLogger Production = logStdout

makePool :: Environment -> IO ConnectionPool
makePool Test = runNoLoggingT $ createMySQLPool (connStr Test) (envPool Test)
makePool e = runStdoutLoggingT $ createMySQLPool (connStr e) (envPool e)

envPool :: Environment -> Int
envPool Test = 1
envPool Development = 1
envPool Production = 8

connStr :: Environment -> ConnectInfo
connStr _ = defaultConnectInfo 
    {
      connectHost = "localhost" 
    , connectPort = 3306
    , connectUser = "test"
    , connectPassword = "secret"
    , connectDatabase = "perservant"
    }
