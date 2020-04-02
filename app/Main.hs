{-# LANGUAGE NamedFieldPuns #-}

module Main where

import           Graphics.Gloss
import           Graphics.Gloss.Data.ViewPort       (ViewPort)
import           Graphics.Gloss.Interface.Pure.Game

-- | The starting state for the game of Pong.
initialState :: PongGame
initialState = Game {ballLoc = (-10, 30), ballVel = (-100, -30), player1 = 40, player2 = -80}

-- | Update the game by moving the ball and bouncing off walls.
update :: Float -> PongGame -> PongGame
update seconds = wallBounce . paddleBounce . moveBall seconds . borderBounce

main :: IO ()
main = play window background fps initialState render handleKeys update

-- | GENERAL SETTING
width, height, offset :: Int
width = 400

height = 400

offset = 200

window :: Display
window = InWindow "BlogPong" (width, height) (offset, offset)

background :: Color
background = yellow

paddleWidth, paddleHeight, paddleDistance, ballRadius :: Float
paddleWidth = 10

paddleHeight = 100

paddleDistance = 180

ballRadius = 15

fps :: Int
fps = 60

-- | GAMESTATE
data PongGame =
  Game
    { ballLoc :: (Float, Float) -- ^ Pong ball (x, y) location.
    , ballVel :: (Float, Float) -- ^ Pong ball (x, y) velocity.
    , player1 :: Float -- ^ Left player paddle height.
    , player2 :: Float -- ^ Right player paddle height.
    }
  deriving (Show)

-- | Convert a game state into a picture.
render ::
     PongGame -- ^ The game state to render.
  -> Picture -- ^ A picture of this game state.
render game =
  pictures [ball, walls, mkPaddle black paddleDistance $ player1 game, mkPaddle black (-paddleDistance) $ player2 game]
    --  The pong ball.
  where
    ballSize = ballRadius
    ballColor = black
    ball = uncurry translate (ballLoc game) $ color ballColor $ circleSolid ballSize
    --  The bottom and top walls.
    wall :: Float -> Picture
    wall offset = translate 0 offset $ color wallColor $ rectangleSolid 400 50
    wallColor = black
    walls = pictures [wall 175, wall (-175)]
    --  Make a paddle of a given border and vertical offset.
    mkPaddle :: Color -> Float -> Float -> Picture
    mkPaddle col x y =
      pictures
        [ translate (x) (y) $ color col $ rectangleSolid paddleWidth paddleHeight
        , translate (x) (y) $ color col $ rectangleSolid paddleWidth paddleHeight
        ]
    paddleColor = light (light blue)

-- | Respond to key events.
handleKeys :: Event -> PongGame -> PongGame
handleKeys (EventKey (Char 'r') _ _ _) game = game {ballLoc = (0, 0)}
--handleKeys (EventKey (Char 'w') _ _ _)
--
--  game = game {player1 = ()}
handleKeys (EventKey (SpecialKey KeyUp) _ _ _) game = game {player1 = y}
  where
    y1 = player1 game
    y =
      if y1 < (100)
        then y1 + 10
        else y1
handleKeys (EventKey (SpecialKey KeyDown) _ _ _) game = game {player1 = y}
  where
    y1 = player1 game
    y =
      if y1 > (-100)
        then y1 - 10
        else y1
handleKeys (EventKey (Char 'w') _ _ _) game = game {player2 = y}
  where
    y1 = player2 game
    y =
      if y1 < (100)
        then y1 + 10
        else y1
handleKeys (EventKey (Char 's') _ _ _) game = game {player2 = y}
  where
    y1 = player2 game
    y =
      if y1 > (-100)
        then y1 - 10
        else y1
-- Do nothing for all other events.
handleKeys _ game = game

moveBall ::
     Float -- ^ The number of seconds since last update
  -> PongGame -- ^ The initial game state
  -> PongGame -- ^ A new game state with an updated ball position
moveBall seconds game = game {ballLoc = (x', y')}
    -- Old locations and velocities.
  where
    (x, y) = ballLoc game
    (vx, vy) = ballVel game
    -- New locations.
    x' = x + vx * seconds
    y' = y + vy * seconds

-- | Detect a collision with a paddle. Upon collisions,
-- change the velocity of the ball to bounce it off the paddle.
paddleBounce :: PongGame -> PongGame
paddleBounce game = game {ballVel = (vx', vy)}
  where
    radius = 10
    (vx, vy) = ballVel game
    vx' =
      if paddleCollision (game)
        then -vx
        else vx

-- | Given position and radius of the ball, return whether a collision occurred.
paddleCollision ::
     PongGame -- ^ The game
  -> Bool -- ^ Collision with the paddles?
paddleCollision game =
  ((deltaXP1 * deltaXP1 + deltaYP1 * deltaYP1) < (ballRadius * ballRadius)) ||
  ((deltaXP2 * deltaXP2 + deltaYP2 * deltaYP2) < (ballRadius * ballRadius))
            -- Ball's center
  where
    (ballX, ballY) = ballLoc game
            -- Player 1's paddle's center
    recXP1 = paddleDistance
    recYP1 = player1 game
            -- Player 2's paddle's center
    recXP2 = -paddleDistance
    recYP2 = player2 game
            -- Player A's paddle's left bottom corner (needed for collision math)
    rectCornerXP1 = recXP1 - paddleWidth / 2
    rectCornerYP1 = recYP1 - paddleHeight / 2
            -- Player 2's paddle's left bottom corner (needed for collision math)
    rectCornerXP2 = recXP2 - paddleWidth / 2
    rectCornerYP2 = recYP2 - paddleHeight / 2
    deltaXP1 = ballX - max rectCornerXP1 (min ballX (rectCornerXP1 + paddleWidth))
    deltaYP1 = ballY - max rectCornerYP1 (min ballY (rectCornerYP1 + paddleHeight))
    deltaXP2 = ballX - max rectCornerXP2 (min ballX (rectCornerXP2 + paddleWidth))
    deltaYP2 = ballY - max rectCornerYP2 (min ballY (rectCornerYP2 + paddleHeight))
    padLx2 = player2 game

-- | Detect a collision with one of the side walls. Upon collisions,
-- update the velocity of the ball to bounce it off the wall.
wallBounce :: PongGame -> PongGame
wallBounce game = game {ballVel = (vx, vy')}
    -- Radius. Use the same thing as in `render`.
    -- The old velocities.
  where
    (vx, vy) = ballVel game
    vy' =
      if wallCollision (ballLoc game) ballRadius
             -- Update the velocity.
        then -vy
            -- Do nothing. Return the old velocity.
        else vy

type Radius = Float

type Position = (Float, Float)

-- | Given position and radius of the ball, return whether a collision occurred.
wallCollision :: Position -> Radius -> Bool
wallCollision (_, y) radius = topCollision || bottomCollision
  where
    topCollision = y - radius <= -fromIntegral width / 2 + 50
    bottomCollision = y + radius >= fromIntegral width / 2 - 50

-- | Detect a collision with one of the side walls. Upon collisions,
-- update the velocity of the ball to bounce it off the wall.
borderBounce :: PongGame -> PongGame
borderBounce game = game {ballLoc = (vx', vy')}
                             -- Radius. Use the same thing as in `render`.
                             -- The old velocities.
  where
    (vx, vy) = ballLoc game
    (vx', vy') =
      if borderCollision (ballLoc game) ballRadius
                                      -- Update the velocity.
        then (0, 0)
                                     -- Do nothing. Return the old velocity.
        else (vx, vy)

borderCollision :: Position -> Radius -> Bool
borderCollision (x, _) radius = leftCollision || rightCollision
  where
    leftCollision = x - radius <= -fromIntegral width / 2
    rightCollision = x + radius >= fromIntegral width / 2
