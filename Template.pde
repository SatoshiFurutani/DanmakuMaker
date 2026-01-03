//***************************//
// ---------- Pattern ----------
//***************************//

class FixedPattern implements PatternFunc {

  float angle;

  FixedPattern(float angle) {
    this.angle = angle;
  }

  float angle(Boss b, int t, int i, int n) {
    return angle;
  }
}


//***************************//
// ---------- Motion ----------
//***************************//
interface Motion {
  PVector velocity(int t);
}

// Motionの合成
class SumMotion implements Motion {
  ArrayList<Motion> motions = new ArrayList<Motion>();
  
  SumMotion(Motion... ms) {
    for(Motion m : ms) motions.add(m);
  }
  
  PVector velocity(int t) {
    PVector v = new PVector();
    for (Motion m : motions) {
      v.add(m.velocity(t));
    }
    return v;
  }
}

// 直進
class Straight implements Motion {
  PVector v;
  Straight(float x, float y) {
    v = new PVector(x, y); 
  }
  PVector velocity(int t) {
    return v; 
  }
}

// 正弦波
class SineMotion implements Motion {
  float base, amp, freq, speed;
  SineMotion(float b, float a, float f, float s) {
    base = b; amp = a; freq = f; speed = s;
  }
  PVector velocity(int t) {
    float ang = base + sin(t*freq) * amp;
    return PVector.fromAngle(ang).mult(speed * diff.speedRate);
  }
}

// 加速
class Accelerate implements Motion {
  PVector dir;
  float a;
  Accelerate(float ang, float a) {
    dir = PVector.fromAngle(ang);
    this.a = a;
  }
  PVector velocity(int t) {
    return PVector.mult(dir, t * a);
  }
}

// 停止→移動
class StopAndGo implements Motion {
  float ang;
  int stop_t = 30;
  int move_t = 60;
  StopAndGo(int stop, int move, float ang) { 
    stop_t = stop;
    move_t = move; 
    this.ang = ang; 
  }

  PVector velocity(int t) {
    if (t > stop_t && t < move_t) return new PVector(0,0);
    return PVector.fromAngle(ang).mult(3);
  }
}

// ホーミング
class Homing implements Motion {
  PVector vel = new PVector();
  int endHoming, startHoming;
  float rate;  // 曲がりやすさ
  float speed;
  Homing(int start, int end, float speed, float rate) {
    endHoming = end;
    startHoming = start;
    this.speed = speed;
    this.rate = rate;
  }
  PVector velocity(int t) {
    if(t > startHoming && t < endHoming) {
      PVector target = PVector.sub(player.pos, boss.pos).normalize().mult(speed);
      vel.lerp(target, rate);
    }
    return vel;
  }
}


//***************************//
// ---------- BulletStyle ----------
//***************************//
interface BulletStyle {
  void draw(PVector pos, float ang);
  float hitRadius();
}

// 球
class CircleStyle implements BulletStyle {
  color c;
  float r;
  
  CircleStyle(color c, float r) {
    this.c = c; 
    this.r = r; 
  }
  
  void draw(PVector p, float a) {
    noStroke(); 
    fill(withAlpha(c, 120));
    ellipse(p.x, p.y, r*2, r*2);
    fill(c);
    ellipse(p.x, p.y, r, r);
  }
  
  float hitRadius() {
    return r * 0.6; 
  }
}

// レーザー
class LaserBullet implements BulletStyle {
  color c;
  float l_width;
  float length;

  LaserBullet(color c, float w, float l) {
    this.c = c;
    l_width = w;
    length = l;
  }

  void draw(PVector p, float a) {
    pushMatrix();
    translate(p.x, p.y);
    rotate(a);
    rectMode(CENTER);
    fill(c);
    rect(0, length/2, l_width, length);
    popMatrix();
    rectMode(CORNER);
  }

  float hitRadius() {
    return l_width * 1.2;
  }
}

// 米粒
class RiceBullet implements BulletStyle {
  color c;
  float scale;

  RiceBullet(color c, float scale) {
    this.c = c;
    this.scale = scale;
  }

  void draw(PVector p, float a) {
    pushMatrix();
    translate(p.x, p.y);
    rotate(a);
    fill(c);
    ellipse(0, 0, 6*scale, 12*scale);
    popMatrix();
  }

  float hitRadius() {
    return 3 * scale;
  }
}
