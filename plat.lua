-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

FLAG_SOLID = 1
DIR_LEFT = 1
DIR_RIGHT = 0

-- Player
Player = {}
Player.new = function(x, y)
  local obj = {}

  obj.x = x
  obj.y = y
  obj.vx = 0  --velocity
  obj.vy = 0
  obj.cr = {x=2, y=2, w=5, h=5}  -- collision rectangle
  obj.jump = 0
  -- obj.jump_seq={-3, -3, -3, -3, -2, -2, -2, 1, 1, 0, 0, 0, 0, 0}
  obj.jump_seq={-4, -4, -4, -4, 
                -3, -3, -3, 
                -2, -2, -2,
                1, 1, 0, 0, 0, 0, 0}
  obj.coyote = 0  -- remaining Coyote time count

  obj.dir = 0  -- 0=left, 1=right
  obj.grounded = false
  obj.grounded_recent = false

  obj.anim = 1
  obj.anim_seq = { 257, 257, 257, 257, 258, 258, 258, 258 }

  obj.draw = function()
    spr(obj.anim_seq[obj.anim], plr.x, plr.y, 0, 1, plr.dir ,0, 1, 1)
  end
  return obj
end

-- Physix

-- x, y : point to position where CR want to move
-- CR : Collosion Rectangle
function CanMove(x, y, cr)
  local x1 = x + cr.x
  local y1 = y + cr.y
  local x2 = x1 + cr.w - 1
  local y2 = y1 + cr.h - 1

  local startC = x1 // 8
  local endC = x2 // 8
  local startR = y1 // 8
  local endR = y2 // 8
  
  for c = startC, endC do
    for r = startR, endR do
      if IsTileSolid(mget(c, r)) then 
        return false
      end
    end
  end
  return true
end

function TryMoveBy(dx, dy)
  if CanMove(plr.x + dx, plr.y + dy, plr.cr) then
    plr.x = plr.x + dx
    plr.y = plr.y + dy
    return true
  end
  return false
end

function IsTileSolid(tile_id)
  if fget(tile_id, FLAG_SOLID) then return true end
  return false
end


function UpdatePlayer()
  -- is player grounded?
  plr.grounded_recent = plr.grounded
  if CanMove(plr.x, plr.y + 1, plr.cr) then
    plr.grounded = false
  else
    plr.grounded = true
  end

  -- falling
  if not plr.grounded then
    plr.coyote = plr.coyote - 1
    plr.y = plr.y + 1
    -- when first frame of falling, get Coyote time
    if plr.grounded_recent then
      plr.coyote = 3
    end
  end

  -- jump sequence
  if plr.jump > 0 then
    if CanMove(plr.x, plr.y + plr.jump_seq[plr.jump], plr.cr) then
      plr.y = plr.y + plr.jump_seq[plr.jump]
    end
    plr.jump = plr.jump + 1
    if plr.jump > #plr.jump_seq then
      -- end jump
      plr.jump = 0
    end
  end

  -- Player Input
  if btn(2) then
    TryMoveBy(-1, 0)
    plr.dir = DIR_LEFT
    plr.anim = plr.anim + 1
  end
  if btn(3) then
    TryMoveBy(1, 0)
    plr.dir = DIR_RIGHT
    plr.anim = plr.anim + 1
  end
  if btnp(4) and plr.grounded then
  -- if btn(4) and ( plr.grounded or plr.coyote >= 1 ) then
    plr.jump = 1
    sfx(0)
  end

  -- Animation
  if plr.anim >= #plr.anim_seq then
    plr.anim = 1
  end
end



-- InGame
function init()
  plr = Player.new(96, 24)
end
init()

function TIC()
  -- physix
  UpdatePlayer()

  -- draw
  cls(00)

  rect(0, 0, 240, 136, 01)
  map(0, 0, 30, 17)
  plr.draw()

  -- debug
  print(tostring(plr.jump_seq[plr.jump]), 8, 8)
  print(tostring(plr.coyote), 8, 16)
end
