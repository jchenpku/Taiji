{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
module Main where

import           Control.Lens           ((.=))
import           Scientific.Workflow
import           Taiji.Core             (builder)
import           Taiji.Core.Config      (TaijiConfig)
import qualified Taiji.Pipeline.ATACSeq as ATACSeq
import qualified Taiji.Pipeline.RNASeq  as RNASeq

initialization :: () -> WorkflowConfig TaijiConfig ()
initialization _ = return ()

mainWith defaultMainOpts { programHeader = "Taiji" } $ do
    namespace "RNA" RNASeq.builder
    namespace "ATAC" ATACSeq.builder
    builder
    nodeS "Initialization" 'initialization $ submitToRemote .= Just False
    ["Initialization"] ~> "RNA_Make_Index"
    ["Initialization"] ~> "ATAC_Make_Index"
    path ["ATAC_Merge_Bed", "Find_Active_Promoter"]
    ["Find_Active_Promoter", "ATAC_Get_TFBS"] ~> "Link_Gene_TF_prep"
