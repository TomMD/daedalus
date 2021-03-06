{-# Language BangPatterns #-}
module Daedalus.Core.Semantics.Env where

import Data.Map(Map)
import qualified Data.Map as Map

import RTS.Parser(Parser)

import Daedalus.Panic(panic)
import Daedalus.PP(pp)
import Daedalus.Core(Name,FName)
import Daedalus.Core.Semantics.Value


data Env = Env
  { vEnv    :: Map Name Value
  , cEnv    :: Map FName Value   -- ^ Top level constants
  , fEnv    :: Map FName ([Value] -> Value)
  , gEnv    :: Map FName ([Value] -> Parser Value)
  }

lookupVar :: Name -> Env -> Value
lookupVar x env =
  case Map.lookup x (vEnv env) of
    Just v  -> v
    Nothing -> panic "lookupVar" [ "Undefined variable", show (pp x) ]

defLocal :: Name -> Value -> Env -> Env
defLocal x !v env = env { vEnv = Map.insert x v (vEnv env) }

lookupConst :: FName -> Env -> Value
lookupConst f env =
  case Map.lookup f (cEnv env) of
    Just v -> v
    Nothing -> panic "lookupConst" [ "Undefined constant", show (pp f) ]

defConst :: FName -> Value -> Env -> Env
defConst x !v env = env { cEnv = Map.insert x v (cEnv env) }


lookupFun :: FName -> Env -> [Value] -> Value
lookupFun f env =
  case Map.lookup f (fEnv env) of
    Just fv -> fv
    Nothing -> panic "lookupFun" [ "Undefined function", show (pp f) ]

defFun :: FName -> ([Value] -> Value) -> Env -> Env
defFun f v env = env { fEnv = Map.insert f v (fEnv env) }

defFuns :: Map FName ([Value] -> Value) -> Env -> Env
defFuns fs env = env { fEnv = Map.union fs (fEnv env) }

lookupGFun :: FName -> Env -> [Value] -> Parser Value
lookupGFun f env =
  case Map.lookup f (gEnv env) of
    Just fv -> fv
    Nothing -> panic "lookupGFun" [ "Undefined function", show (pp f) ]

defGFuns :: Map FName ([Value] -> Parser Value) -> Env -> Env
defGFuns fs env = env { gEnv = Map.union fs (gEnv env) }

