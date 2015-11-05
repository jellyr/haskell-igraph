module IGraph.Exporter.GEXF
    ( NodeAttr(..)
    , defaultNodeAttributes
    , EdgeAttr(..)
    , defaultEdgeAttributes
    , genXMLTree
    , writeGEXF
    ) where

import Data.Colour (AlphaColour, black, over, alphaChannel, opaque)
import Data.Colour.SRGB (toSRGB24, channelRed, channelBlue, channelGreen)
import Data.Function (on)
import Data.Serialize (Serialize, put, get)
import Data.Tree.NTree.TypeDefs
import Text.XML.HXT.Core
import Text.XML.HXT.DOM.TypeDefs
import IGraph

data NodeAttr = NodeAttr
    { _size :: Double
    , _nodeColour :: AlphaColour Double
    , _nodeLabel :: String
    , _positionX :: Double
    , _positionY :: Double
    } deriving (Show, Read)

instance Serialize NodeAttr where
    put = put . show
    get = fmap read get

instance Ord NodeAttr where
    compare = compare `on` _nodeLabel

instance Eq NodeAttr where
    (==) = (==) `on` _nodeLabel

defaultNodeAttributes :: NodeAttr
defaultNodeAttributes = NodeAttr
    { _size = 1.0
    , _nodeColour = opaque black
    , _nodeLabel = ""
    , _positionX = 0
    , _positionY = 0
    }

data EdgeAttr = EdgeAttr
    { _edgeLabel :: String
    , _edgeColour :: AlphaColour Double
    , _edgeWeight :: Double
    } deriving (Show, Read)

instance Serialize EdgeAttr where
    put = put . show
    get = fmap read get

instance Ord EdgeAttr where
    compare = compare `on` _edgeLabel

instance Eq EdgeAttr where
    (==) = (==) `on` _edgeLabel

defaultEdgeAttributes :: EdgeAttr
defaultEdgeAttributes = EdgeAttr
    { _edgeLabel = ""
    , _edgeColour = opaque black
    , _edgeWeight = 1.0
    }

genXMLTree :: ArrowXml a => LGraph U NodeAttr EdgeAttr -> a XmlTree XmlTree
genXMLTree gr = root [] [gexf]
  where
    gexf = mkelem "gexf" [ attr "version" $ txt "1.2"
                              , attr "xmlns" $ txt "http://www.gexf.net/1.2draft"
                              , attr "xmlns:viz" $ txt "http://www.gexf.net/1.2draft/viz"
                              , attr "xmlns:xsi" $ txt "http://www.w3.org/2001/XMLSchema-instance"
                              , attr "xsi:schemaLocation" $ txt "http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd"
                              ] [graph]
    graph = mkelem "graph" [ attr "mode" $ txt "static"
                           , attr "defaultedgetype" $ txt "undirected"
                           ] [ns, es]
    ns = mkelem "nodes" [] $ map mkNode $ nodes gr
    es = mkelem "edges" [] $ map mkEdge $ edges gr
    mkNode i =
        mkelem "node" [ attr "id" $ txt $ show i
                      , attr "label" $ txt $ _nodeLabel at ]
                      [ aelem "viz:position" [ attr "x" $ txt $ show $ _positionX at
                                             , attr "y" $ txt $ show $ _positionY at ]
                      , aelem "viz:color" [ attr "r" $ txt r
                                          , attr "g" $ txt g
                                          , attr "b" $ txt b
                                          , attr "a" $ txt a ]
                      , aelem "viz:size" [attr "value" $ txt $ show $ _size at]
                      ]
      where
        at = nodeLab gr i
        rgb = toSRGB24 $ _nodeColour at `over` black
        r = show (fromIntegral $ channelRed rgb :: Int)
        b = show (fromIntegral $ channelBlue rgb :: Int)
        g = show (fromIntegral $ channelGreen rgb :: Int)
        a = show $ alphaChannel $ _nodeColour at

    mkEdge (fr,to) =
        mkelem "edge" [ attr "source" $ txt $ show fr
                      , attr "target" $ txt $ show to
                      , attr "weight" $ txt $ show $ _edgeWeight at ]
                      [ aelem "viz:color" [ attr "r" $ txt r
                                          , attr "g" $ txt g
                                          , attr "b" $ txt b
                                          , attr "a" $ txt a ]
                      ]
      where
        at = edgeLab gr (fr,to)
        rgb = toSRGB24 $ _edgeColour at `over` black
        r = show (fromIntegral $ channelRed rgb :: Int)
        b = show (fromIntegral $ channelBlue rgb :: Int)
        g = show (fromIntegral $ channelGreen rgb :: Int)
        a = show $ alphaChannel $ _edgeColour at
{-# INLINE genXMLTree #-}

writeGEXF :: FilePath -> LGraph U NodeAttr EdgeAttr -> IO ()
writeGEXF fl gr = runX (genXMLTree gr >>> writeDocument config fl) >> return ()
  where
    config = [withIndent yes]
