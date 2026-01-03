//***************************//
// ---------- Boss ----------
//***************************//
class Boss {

  // ---- transform ----
  PVector pos = new PVector(playWidth/2, 120);
  float hitRadius = 20;

  // ---- state ----
  BossState state = BossState.NORMAL;
  int timer = 0;          // 現在 Phase に入ってからの時間
  int barIndex = 0;

  // ---- data ----
  ArrayList<LifeBar> bars;

  Boss(ArrayList<LifeBar> bars) {
    this.bars = bars;
  }

  // ---------------- update ----------------
  void update() {
    if (state == BossState.DEAD) return;

    LifeBar bar = currentBar();
    LoopPhase phase = (state == BossState.NORMAL)
                  ? bar.normalPhase
                  : bar.endurePhase;

    phase.update(this);
    timer++;

    if (bar.isFinished(state, timer)) {
      onPhaseFinished();
    }
  }

  // ---------------- draw ----------------
  void draw() {
    if (state == BossState.DEAD) return;
    fill(255, 100, 100);
    ellipse(pos.x, pos.y, hitRadius*2, hitRadius*2);
  }

  // ---------------- hit ----------------
  boolean hit(Bullet b) {
    if (state == BossState.DEAD) return false;

    if (PVector.dist(pos, b.pos) < hitRadius) {

      if (state == BossState.NORMAL) {
        LifeBar bar = currentBar();
        bar.hp -= player.power;

        if (bar.hp <= 0) {
          state = BossState.ENDURE;
          timer = 0;
          score.onEvent(ScoreEvent.HP_BREAK);
        }
      }

      return true;
    }
    return false;
  }

  // ---------------- phase transition ----------------
  void onPhaseFinished() {
    timer = 0;

    if (state == BossState.ENDURE) {
      barIndex++;
      if (barIndex >= bars.size()) {
        state = BossState.DEAD;
        score.onEvent(ScoreEvent.BOSS_KILL);
      } else {
        state = BossState.NORMAL;
      }
      score.onEvent(ScoreEvent.SPELL_BREAK);
    }
  }

  // ---------------- util ----------------
  LifeBar currentBar() {
    if (barIndex >= bars.size()) return null;
    return bars.get(barIndex);
  }

  void spawnBullet(PVector pos, Motion m, BulletStyle s) {
    enemyBullets.add(new Bullet(pos.copy(), m, s));
  }
}

// ---------- BossState ----------
enum BossState { NORMAL, ENDURE, DEAD }
