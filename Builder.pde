//***************************//
// ---------- LifeBar ----------
//***************************//
class LifeBar {

  int maxHP;
  int hp;
  int endureTime;

  LoopPhase normalPhase;
  LoopPhase endurePhase;

  LifeBar(int hp, int endureT, LoopPhase normalP, LoopPhase endureP) {
    maxHP = (int)(hp * diff.hpRate);
    this.hp = (int)(hp * diff.hpRate);
    endureTime = (int)(endureT * diff.endureTimeRate);
    normalPhase = normalP;
    endurePhase = endureP;
  }

  boolean isFinished(BossState state, int timer) {
    if (state == BossState.NORMAL)
      return hp <= 0;

    if (state == BossState.ENDURE)
      return timer > endureTime;

    return false;
  }
}

//***************************//
// ---------- Phase ----------
//***************************//
class LoopPhase {

  int loopLength;
  int localTime = 0;

  Timeline<Emitter> emitters;
  Timeline<BossMotion> motions;

  LoopPhase(int len,
            Timeline<Emitter> e,
            Timeline<BossMotion> m) {
    loopLength = len;
    emitters = e;
    motions  = m;
  }

  void update(Boss b) {
    motions.update(b, localTime);
    emitters.update(b, localTime);

    localTime++;
    if (localTime >= loopLength) localTime = 0;
  }
}


//***************************//
// ---------- Timeline ----------
//***************************//
interface TimelineItem {
  int start();
  int end();
  void update(Boss b, int t);
}

class Timeline<T extends TimelineItem> {

  ArrayList<T> items = new ArrayList<>();

  void update(Boss b, int localTime) {
    for (T item : items) {
      if (localTime < item.start() || localTime > item.end()) continue;
      item.update(b, localTime - item.start());
    }
  }
}

class BossMotionTimeline {
  ArrayList<TimelineItem> items = new ArrayList<>();

  void add(TimelineItem item) {
    items.add(item);
  }

  void update(Boss b, int localTime) {
    for (TimelineItem item : items) {
      item.update(b, localTime);
    }
  }
}

class EmitterTimeline {
  ArrayList<TimelineItem> items = new ArrayList<>();

  void add(TimelineItem item) {
    items.add(item);
  }

  void update(Boss b, int localTime) {
    for (TimelineItem item : items) {
      item.update(b, localTime);
    }
  }
}


//***************************//
// ---------- BossMotion ----------
//***************************//
interface BossMove {
  void apply(Boss b, int t);
}

class BossMotion implements TimelineItem {

  int start, end;
  BossMove move;

  public int start() { return start; }
  public int end()   { return end; }

  public void update(Boss b, int t) {
    move.apply(b, t);
  }
}

//***************************//
// ---------- Emitter ----------
//***************************//
class Emitter implements TimelineItem {

  int start, end;
  int interval, count;

  SpawnFunc spawn;
  PatternFunc pattern;
  MotionFactory motion;
  StyleFactory style;

  public int start() { return start; }
  public int end()   { return end; }

  public void update(Boss b, int t) {
    if (interval <= 0) return;
    if (t % interval != 0) return;

    for (int i = 0; i < count; i++) {
      PVector pos = spawn.pos(b, t, i, count);
      float ang   = pattern.angle(b, t, i, count);
      b.spawnBullet(pos, motion.create(ang, t), style.create());
    }
  }
}

//***************************************//
// ---------- Emitter用interface ----------
//***************************************//
interface SpawnFunc {
  PVector pos(Boss b, int t, int i, int n);
}

interface PatternFunc {
  float angle(Boss b, int t, int i, int n);
}

interface MotionFactory {
  Motion create(float ang, int t);
}

interface StyleFactory {
  BulletStyle create();
}
