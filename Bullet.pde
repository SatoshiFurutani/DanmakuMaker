//***************************//
// ---------- 更新 ----------
//***************************//
void updateBullets() {
  // 敵弾
  for (int i = enemyBullets.size()-1; i >= 0; i--) {
    Bullet b = enemyBullets.get(i);
    println("debug");
    
    if(bombField != null && inBomb(b, bombField)) {
      enemyBullets.remove(i);
      continue;
    }

    b.update();
    b.draw();
    if (b.out()) enemyBullets.remove(i);
    else if (player.hit(b)) player.hitted = true;
    else if (player.graze(b)) score.onEvent(ScoreEvent.GRAZE);
  }

  // プレイヤ弾
  for (int i = playerBullets.size()-1; i >= 0; i--) {
    Bullet b = playerBullets.get(i);
    b.update();
    b.draw();
    if (b.out()) playerBullets.remove(i);
    else if (boss.hit(b)) {
      playerBullets.remove(i);
      score.onEvent(ScoreEvent.HIT);
    }
  }  
  
  // Bomb
  if(bombField != null) {
    bombField.update();
    bombField.draw();
    if(bombField.isDead()) bombField = null;
  }
}

//***************************//
// ---------- Bomb ----------
//***************************//
class BombField {
  PVector center;
  int t = 0;
  int max_t = 200;
  float rad = 20;
  float max_rad = 200;
  
  BombField(PVector c) {
    center = c.copy();
    rad = 0;
    t = 0;
  }
  
  void update() {
    t++;
    rad = map(t, 0, max_t, 0, max_rad);
  }
  
  void draw() {
    noFill();
    stroke(100, 200, 255);
    ellipse(center.x, center.y, 2*rad, 2*rad);
  }
  
  boolean isDead() {
    return t > max_t;
  }
}

boolean inBomb(Bullet b, BombField f) {
  return PVector.dist(b.pos, f.center) < f.rad;
}

//***************************//
// ---------- Bullet ----------
//***************************//
class Bullet {

  PVector pos;
  PVector vel = new PVector();
  PVector dir = new PVector(0, 1); // 初期向き（下）

  Motion motion;
  BulletStyle style;

  int age = 90;
  boolean dead = false;

  Bullet(PVector startPos, Motion m, BulletStyle s) {
    pos = startPos.copy();
    motion = m;
    style = s;
  }

  void update() {
    if (dead) return;

    PVector v = motion.velocity(age);
    age++;

    if (v.magSq() > 0.0001) {
      vel = v;
      dir = v.copy().normalize();
    }

    pos.add(vel);

    if (out()) dead = true;
  }

  void draw() {
    if (dead) return;
    style.draw(pos, atan2(dir.y, dir.x));
  }

  boolean out() {
    return pos.x < -60 || pos.x > playWidth + 60
        || pos.y < -60 || pos.y > height + 60;
  }
}

class BulletManager {
  ArrayList<Bullet> bullets = new ArrayList<>();

  void add(Bullet b) {
    bullets.add(b);
  }

  void update() {
    for (int i = bullets.size() - 1; i >= 0; i--) {
      Bullet b = bullets.get(i);
      b.update();
      if (b.dead) bullets.remove(i);
    }
  }

  void draw() {
    for (Bullet b : bullets) b.draw();
  }

  void clear() {
    bullets.clear();
  }
}
