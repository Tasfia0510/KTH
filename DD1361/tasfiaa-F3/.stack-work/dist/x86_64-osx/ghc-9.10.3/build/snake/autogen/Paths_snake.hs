{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
#if __GLASGOW_HASKELL__ >= 810
{-# OPTIONS_GHC -Wno-prepositive-qualified-module #-}
#endif
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_snake (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath




bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/Users/tasfiaalam/tasfiaa-F3/.stack-work/install/x86_64-osx/065439cc607578b350f9eae1347922a54bb0c1f34d8279284facc2a776ab3ccc/9.10.3/bin"
libdir     = "/Users/tasfiaalam/tasfiaa-F3/.stack-work/install/x86_64-osx/065439cc607578b350f9eae1347922a54bb0c1f34d8279284facc2a776ab3ccc/9.10.3/lib/x86_64-osx-ghc-9.10.3-5528/snake-0.1.0.0-3Urt1bl8cM3DPYYD1NYnN8-snake"
dynlibdir  = "/Users/tasfiaalam/tasfiaa-F3/.stack-work/install/x86_64-osx/065439cc607578b350f9eae1347922a54bb0c1f34d8279284facc2a776ab3ccc/9.10.3/lib/x86_64-osx-ghc-9.10.3-5528"
datadir    = "/Users/tasfiaalam/tasfiaa-F3/.stack-work/install/x86_64-osx/065439cc607578b350f9eae1347922a54bb0c1f34d8279284facc2a776ab3ccc/9.10.3/share/x86_64-osx-ghc-9.10.3-5528/snake-0.1.0.0"
libexecdir = "/Users/tasfiaalam/tasfiaa-F3/.stack-work/install/x86_64-osx/065439cc607578b350f9eae1347922a54bb0c1f34d8279284facc2a776ab3ccc/9.10.3/libexec/x86_64-osx-ghc-9.10.3-5528/snake-0.1.0.0"
sysconfdir = "/Users/tasfiaalam/tasfiaa-F3/.stack-work/install/x86_64-osx/065439cc607578b350f9eae1347922a54bb0c1f34d8279284facc2a776ab3ccc/9.10.3/etc"

getBinDir     = catchIO (getEnv "snake_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "snake_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "snake_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "snake_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "snake_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "snake_sysconfdir") (\_ -> return sysconfdir)



joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
