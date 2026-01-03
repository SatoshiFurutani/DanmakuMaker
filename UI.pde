//***************************//
// ---------- UI ----------
//***************************//

// ---------- Scene UI Dispatcher ----------
void drawUIByScene() {
  switch(scene) {
    case TITLE:
      drawTitle();
      break;
    case SELECT_LEVEL:
      drawSelectLevel();
      break;
    case SELECT_WEAPON:
      break;
    case PRE_BATTLE:
      drawPreBattle();
      break;
    case BATTLE:
      drawUIBattle();
      break;
    case RESULT:
      drawResult();
      break;
    case GAME_OVER:
      drawGameOver();
      break;
  }
}

//***************************//
// ---------- Battle UI ----------
//***************************//

float hpBarVis = 0;

void drawUIBattle() {
  strokeWeight(1);
  if (boss == null) return;
  if (boss.state != BossState.NORMAL && boss.state != BossState.ENDURE) return;

  LifeBar bar = boss.currentBar();
  if (bar == null) return;
  // ---- HP BAR ----
  if (bar != null) {
    float targetW = map(bar.hp, 0, bar.maxHP, 0, 300);
    hpBarVis = lerp(hpBarVis, targetW, 0.1);

    noStroke();
    fill(120, 0, 0);
    rect(90, 20, hpBarVis, 10);

    fill(255, 80, 80);
    rect(90, 20, targetW, 10);

    stroke(255);
    noFill();
    rect(90, 20, 300, 10);
    noStroke();
  }

  // ---- SIDE PANEL ----
  fill(30, 30, 40);
  rect(playWidth, 0, width - playWidth, height);
  stroke(100);
  line(playWidth, 0, playWidth, height);
  noStroke();

  // ---- SCORE ----
  fill(255);
  textAlign(LEFT, BASELINE);
  textSize(20);
  text("SCORE", playWidth + 20, 40);
  textSize(26);
  text(score.score, playWidth + 20, 70);

  // ---- LIFE ----
  textSize(18);
  text("LIFE", playWidth + 20, 110);
  for (int i = 0; i < player.lifeStock; i++) {
    fill(255, 100, 100);
    stroke(255);
    ellipse(playWidth + 80 + i * 26, 105, 16, 16);
  }
  noStroke();

  // ---- BOMB ----
  fill(255);
  text("BOMB", playWidth + 20, 150);
  for (int i = 0; i < player.bombStock; i++) {
    fill(100, 200, 255);
    stroke(255);
    rect(playWidth + 80 + i * 26, 140, 14, 14, 3);
  }
  noStroke();

  // ---- HELP ----
  fill(180);
  textSize(14);
  text("SHIFT:SLOW  Z:SHOT  X:BOMB", playWidth + 20, height - 20);
}

//***************************//
// ---------- Title ----------
//***************************//

void drawTitle() {
  background(20);

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(72);
  text("Bullet Rush", width / 2, height / 3);

  float a = 150 + 105 * sin(frameCount * 0.05);
  fill(255, a);
  textSize(32);
  text("Press Z", width / 2, height * 0.65);
}

//***************************//
// ---------- Select Level ----------
//***************************//

void drawSelectLevel() {
  background(30);

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(48);
  text("Select Difficulty", width / 2, 80);

  diffSelector.update(input);
  diffSelector.draw();

  Difficulty result = diffSelector.getResult();
  if (result != null) {
    diff = result;
  }

  fill(180);
  textSize(14);
  textAlign(RIGHT, BASELINE);
  text("Z:OK  X:BACK  ↑↓:SELECT", width - 10, height - 20);
}


//***************************//
// ---------- PreBattle ----------
//***************************//
void drawPreBattle() {
  background(0);

  // ---- フェードイン ----
  float alpha = constrain(preBattleTimer * 5, 0, 255);
  fill(255, alpha);
  textAlign(CENTER, CENTER);

  // ---- タイトル ----
  textSize(48);
  text("NEXT BOSS", width/2, height/3);

  // ---- ボス名（仮） ----
  textSize(32);
  text("Boss " + (game.bossIndex + 1), width/2, height/2);

  // ---- 操作案内 ----
  if (preBattleTimer > 30) {
    float a = 150 + 105 * sin(frameCount * 0.05);
    fill(255, a);
    textSize(24);
    text("Press Z to Start", width/2, height*0.65);
  }

  // ---- 持ち越し表示 ----
  fill(180);
  textSize(16);
  text("Carry HP   : " + (game.carryHP ? "ON" : "OFF"), width/2, height*0.75);
  text("Carry Bomb : " + (game.carryBomb ? "ON" : "OFF"), width/2, height*0.80);
}

//***************************//
// ---------- Result ----------
//***************************//

void drawResult() {
  background(10);

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(56);
  text("RESULT", width / 2, height / 4);

  textSize(28);
  text("SCORE : " + score.score, width / 2, height / 2 - 40);

  textSize(20);
  fill(200);
  text("Z : NEXT BOSS", width / 2, height / 2 + 20);
  text("X : QUIT", width / 2, height / 2 + 60);
}

//***************************//
// ---------- Game Over ----------
//***************************//

void drawGameOver() {
  background(0);

  textAlign(CENTER, CENTER);
  fill(255, 50, 50);
  textSize(64);
  text("GAME OVER", width / 2, height / 2 - 40);

  fill(200);
  textSize(24);
  text("Press Z to return", width / 2, height / 2 + 40);
}

//***************************//
// ---------- UI Parts ----------
//***************************//

// ---- Slider ----
class Slider {
  float x, y, w;
  float min, max, value;
  String label;
  boolean dragging = false;
  boolean changed = false;

  Slider(float x, float y, float w, float min, float max, float v, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.min = min;
    this.max = max;
    this.value = v;
    this.label = label;
  }

  void update() {
    changed = false;
    if (mousePressed && mouseY > y - 10 && mouseY < y + 10 && mouseX > x && mouseX < x + w) {
      dragging = true;
    }
    if (!mousePressed) dragging = false;
    if (dragging) {
      value = constrain(map(mouseX, x, x + w, min, max), min, max);
      changed = true;
    }
  }

  void draw() {
    fill(255);
    text(label + " : " + nf(value, 1, 2), x, y - 12);
    stroke(150);
    line(x, y, x + w, y);
    float px = map(value, min, max, x, x + w);
    noStroke();
    fill(dragging ? color(255, 200, 100) : 255);
    ellipse(px, y, dragging ? 16 : 12, dragging ? 16 : 12);
  }
}

// ---- CheckBox ----
class CheckBox {
  float x, y;
  String label;
  boolean checked;
  boolean changed = false;

  CheckBox(float x, float y, String label, boolean init) {
    this.x = x;
    this.y = y;
    this.label = label;
    checked = init;
  }

  void update() {
    changed = false;
    if (mousePressed && mouseX > x && mouseX < x + 15 && mouseY > y && mouseY < y + 15) {
      checked = !checked;
      changed = true;
    }
  }

  void draw() {
    stroke(255);
    noFill();
    rect(x, y, 15, 15);
    if (checked) {
      line(x, y, x + 15, y + 15);
      line(x + 15, y, x, y + 15);
    }
    fill(255);
    text(label, x + 25, y + 13);
  }
}

// ---- Selector ----
class Selector<T> {
  T[] items;
  int index = 0;
  boolean decided = false;

  float cx, startY, gap;
  float boxW, boxH;

  Selector(T[] items, float cx, float startY, float gap, float boxW, float boxH) {
    this.items = items;
    this.cx = cx;
    this.startY = startY;
    this.gap = gap;
    this.boxW = boxW;
    this.boxH = boxH;
  }

  void update(Input input) {
    if (input.pressed(Key.UP)) index = (index - 1 + items.length) % items.length;
    if (input.pressed(Key.DOWN)) index = (index + 1) % items.length;
    if (input.pressed(Key.Z)) decided = true;
  }

  void draw() {
    textAlign(CENTER, CENTER);
    for (int i = 0; i < items.length; i++) {
      float y = startY + i * gap;
      if (i == index) {
        stroke(255, 255, 0);
        strokeWeight(4);
        textSize(52);
      } else {
        stroke(255);
        strokeWeight(1);
        textSize(46);
      }
      noFill();
      rectMode(CENTER);
      rect(cx, y, boxW, boxH);
      fill(255);
      text(items[i].toString(), cx, y);
    }
    rectMode(CORNER);
  }

  T getResult() {
    return decided ? items[index] : null;
  }
}
