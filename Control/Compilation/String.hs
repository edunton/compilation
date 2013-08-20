----------------------------------------------------------------
--
-- | Compilation
--   Monad and combinators for quickly assembling simple
--   compilers.
--
-- @Control\/Compilation\/String.hs@
--
--   A generic compilation monad and combinators for quickly
--   assembling simple compilers that emit an ASCII string
--   representation of the target language (well-suited for
--   direct syntax translators).
--

----------------------------------------------------------------
--

{-# LANGUAGE FlexibleInstances, TypeSynonymInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Control.Compilation.String
  where
  
import Control.Compilation

----------------------------------------------------------------
-- | Type synonyms and class memberships.

type Indentation = Integer
type StateExtensionString = (Indentation, String)

instance StateExtension StateExtensionString where
  initial = (0, "")

----------------------------------------------------------------
-- | State extension class definition, including combinators
--   and convenient synonyms for compiling directly into a raw
--   ASCII string.

class StateExtension a => HasString a where
  project :: a -> StateExtensionString
  inject :: StateExtensionString -> a -> a
  
  indent :: Compilation a ()
  indent =
    do state <- get
       (i, s) <- return $ project state
       set $ inject (i + 2, s) state

  unindent :: Compilation a ()
  unindent =
    do state <- get
       (i, s) <- return $ project state
       set $ inject (max 0 (i - 2), s) state
   
  space :: Compilation a ()
  space =
    do state <- get
       (i, s) <- return $ project state
       set $ inject (i, s ++ " ") state

  spaces :: Int -> Compilation a ()
  spaces k =
    do state <- get
       (i, s) <- return $ project state
       set $ inject (i, s ++ (take k $ repeat ' ')) state

  newline :: Compilation a ()
  newline =
    do state <- get
       (i, s) <- return $ project state
       set $ inject (i, s ++ "\n" ++ (take (fromInteger i) $ repeat ' ')) state

  newlines :: Int -> Compilation a ()
  newlines k =
    do state <- get
       (i, s) <- return $ project state
       set $ inject (i, s ++ (take k $ repeat '\n') ++ (take (fromInteger i) $ repeat ' ')) state

  string :: String -> Compilation a ()
  string s' =
    do state <- get
       (i, s) <- return $ project state
       set $ inject (i, s ++ s') state

  raw :: String -> Compilation a ()
  raw = string
  
  compiled :: Compilation a b -> String
  compiled c = let (_, s) :: StateExtensionString = project (extract c) in s

--eof
