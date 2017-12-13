module Model exposing (..)

import DropZone

type alias Point =
    { x: Int
    , y: Int
    }

type alias Line =
    { start: Point
    , end: Point
    }

type alias Graphics =
    { points: List Point
    , lines: List Line
    }

type alias Offset =
    { w: Int
    , h: Int
    }

type Geometry
    = Rect Point Offset
    | Quad Point Point Point Point

type PendingGeometry
    = NoShape
    | PendingRect (List Point)
    | PendingQuad (List Point)

type alias Shape =
    { label: String
    , geom: Geometry
    }

type alias Image =
    { url: String
    , shapes: List Shape
    }

type alias Model =
    { pending: List Image
    , processed: List Image
    , pendingGeom: PendingGeometry
    , width: Int
    , height: Int
    , dropZone: DropZone.Model
    }

init : Model
init =
    Model
        []
        []
        NoShape
        2000
        2000
        DropZone.init

graphics : Model -> Graphics
graphics m =
    let
        current =
            List.head m.pending
                |> Maybe.withDefault (Image "" [])
        lines =
            List.map .geom current.shapes
                |> List.map toLines
                |> List.concat
        points =
            case m.pendingGeom of
                NoShape -> []
                PendingRect l -> l
                PendingQuad l -> l
    in
    Graphics points lines

toLines : Geometry -> List Line
toLines g =
    case g of
        Rect p o ->
            rectLines p o
        Quad p1 p2 p3 p4 ->
            quadLines p1 p2 p3 p4

rectLines : Point -> Offset -> List Line
rectLines p o =
    let
        tl = p
        tr = Point (p.x + o.w) p.y
        br = Point (p.x + o.w) (p.y + o.h)
        bl = Point p.x (p.y + o.h)
    in
    quadLines tl tr br bl

quadLines : Point -> Point -> Point -> Point -> List Line
quadLines tl tr br bl =
        [ Line tl tr
        , Line tr br
        , Line br bl
        , Line bl tl
        ]
