//***************************//
// ---------- Player ----------
//***************************//
class Player {
  PVector pos;
  float r = 3;
  float power = 1;
  float def_sp = 4;
  float sp;
  boolean hitted = false;
  boolean useBomb = false;
  boolean slow = false;
  int invicibleTimer = 0;
  int shotTimer = 0;
  int def_bombStock = 3;
  int bombStock = 3;
  int def_lifeStock = 3;
  int lifeStock = 3;
  
  Player(float x, float y, float r, float power) {
    pos = new PVector(x, y);
    this.r = r;
    this.power = power;
  }
  
  void resetHP() { lifeStock = def_lifeStock; }

  void resetBomb(){ bombStock = def_bombStock; }

  void resetPos() { pos.x = playWidth/2; pos.y = height-80;};
  
  void update() {
    if(input.pressed(Key.X)) bomb();
    if(input.down(Key.Z)) shoot();
    
    if(input.down(Key.SHIFT)) slow = true;
    else slow = false;
    
    sp = slow ? def_sp * 0.3 : def_sp;

    if (input.down(Key.LEFT)) pos.x -= sp;
    if (input.down(Key.RIGHT)) pos.x += sp;
    if (input.down(Key.UP)) pos.y -= sp;
    if (input.down(Key.DOWN)) pos.y += sp;
    
    pos.x = constrain(pos.x, r, playWidth-r);
    pos.y = constrain(pos.y, r, height-r);
    
    if(shotTimer > 0) shotTimer--;
    if (invicibleTimer > 0) invicibleTimer--;
  }

  void shoot() {
    if (shotTimer > 0) return;
    playerBullets.add(new Bullet(new PVector(pos.x, pos.y - 10),
      new Straight(0, -8), new CircleStyle(color(0,255,255), 4)));
    shotTimer = 4;
  }
  
  void bomb() {
    if (bombStock <= 0) return;
    bombStock--;
    useBomb = true;
    bombField = new BombField(pos);
   
    invicibleTimer = 150;
  }
  
  void draw() {
    if(invicibleTimer > 0 && invicibleTimer % 6 > 2)  fill(0, 200, 255, 100);
    else  fill(0, 200, 255);
    ellipse(pos.x, pos.y, 14, 20);
    if(slow) {
      fill(255, 0, 0);
      ellipse(pos.x, pos.y, r * 2, r * 2);
    }
  }

  boolean hit(Bullet b) {
    if(invicibleTimer > 0) return false;
    boolean hit = dist(pos.x, pos.y, b.pos.x, b.pos.y) < r + b.style.hitRadius();
    if(hit) {
      invicibleTimer = 150;
      lifeStock--;
    }
    return hit;
  }
  
  boolean graze(Bullet b) {
     return dist(pos.x, pos.y, b.pos.x, b.pos.y) < r * 2 + b.style.hitRadius(); 
  }
}

//***************************//
// ---------- Score ----------
//***************************//

enum ScoreEvent {
  HIT,
  GRAZE,
  HP_BREAK,
  SPELL_BREAK,
  BOSS_KILL,
  BOMB
}

class ScoreManager {
  int score = 0;
  int graze = 0;

  void reset() {
    score = 0;
    graze = 0;
  }
  
  void onEvent(ScoreEvent e) {
    switch(e) {
      case HIT:
        score += 10;
        break;

      case GRAZE:
        graze++;
        score += 100;
        break;
      case HP_BREAK:
        bonus(0.5);
        break;
      case SPELL_BREAK:
        score += 50000;
        bonus(1.0);
        break;

      case BOSS_KILL:
        score += 200000;
        break;
    }
  }
  
  void bonus(float rate) {
    if(!player.hitted) { 
      score += 20000 * rate;
      if(!player.useBomb) score += 15000 * rate;
    }
    player.hitted = false;
    player.useBomb = false;
  }
}

//******************************//
// ---------- キー入力 ----------
//******************************//
enum Key {SHIFT, Z, X, UP, DOWN, RIGHT, LEFT};

class KeyState {
  boolean down = false;      // 押している間 true
  boolean pressed = false;   // 押した瞬間だけ true
  boolean released = false;  // 離した瞬間だけ true

  void press() {
    if (!down) pressed = true;
    down = true;
  }

  void release() {
    if (down) released = true;
    down = false;
  }

  void endFrame() {
    pressed = false;
    released = false;
  }
}

class Input {
  EnumMap<Key, KeyState> keys = new EnumMap<>(Key.class);

  Input() {
    for (Key k : Key.values()) {
      keys.put(k, new KeyState());
    }
  }

  // ---- 状態取得（短く書く用） ----
  boolean down(Key k) {
    return keys.get(k).down;
  }

  boolean pressed(Key k) {
    return keys.get(k).pressed;
  }

  boolean released(Key k) {
    return keys.get(k).released;
  }

  // ---- 内部用 ----
  void press(Key k) {
    keys.get(k).press();
  }

  void release(Key k) {
    keys.get(k).release();
  }

  void endFrame() {
    for (Key k : Key.values()) {
      keys.get(k).endFrame();
    }
  }
}

void keyPressed() {
  if (key == 'z' || key == 'Z') input.press(Key.Z);
  if (key == 'x' || key == 'X') input.press(Key.X);

  if (key == CODED) {
    if (keyCode == LEFT)  input.press(Key.LEFT);
    if (keyCode == RIGHT) input.press(Key.RIGHT);
    if (keyCode == UP)    input.press(Key.UP);
    if (keyCode == DOWN)  input.press(Key.DOWN);
    if (keyCode == SHIFT) input.press(Key.SHIFT);
  }
}

void keyReleased() {
  if (key == 'z' || key == 'Z') input.release(Key.Z);
  if (key == 'x' || key == 'X') input.release(Key.X);

  if (key == CODED) {
    if (keyCode == LEFT)  input.release(Key.LEFT);
    if (keyCode == RIGHT) input.release(Key.RIGHT);
    if (keyCode == UP)    input.release(Key.UP);
    if (keyCode == DOWN)  input.release(Key.DOWN);
    if (keyCode == SHIFT) input.release(Key.SHIFT);
  }
}
