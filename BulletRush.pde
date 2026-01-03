import java.util.EnumMap;

// ---------- グローバル ----------
Player player;
ArrayList<Bullet> enemyBullets = new ArrayList<Bullet>();
ArrayList<Bullet> playerBullets = new ArrayList<Bullet>();
BulletManager bulletManager = new BulletManager();
BombField bombField;
Boss boss;
Difficulty diff = null;
int selected = 0;

PhaseLoader loader = new PhaseLoader(this);
ArrayList<LoopPhase> phases;

Selector<Difficulty> diffSelector;
Difficulty selectedDifficulty;
Difficulty[] diffs = Difficulty.values();

ScoreManager score = new ScoreManager();
int playWidth;
Input input = new Input();

enum PauseMenu {
  RESUME, RETRY, QUIT
}

Selector<PauseMenu> pauseSelector;

// ---------- シーン ----------
enum Scene {
  TITLE,
  SELECT_LEVEL,
  SELECT_WEAPON,
  PRE_BATTLE,   // 初期化専用
  BATTLE,
  RESULT,
  GAME_OVER
}

Scene scene = Scene.TITLE;

// ---------- モード ----------
enum Mode { EDITOR, PLAY }
Mode mode = Mode.PLAY;

void setup() {
  size(700, 600);
  smooth();
    
  fileRoad();
  
  playWidth = 2 * width / 3;
  
  diffSelector = new Selector<>(
    Difficulty.values(),
    width/2,
    height/4,
    height/5,
    width*0.6,
    80
  );
  
  pauseSelector = new Selector<>(
    PauseMenu.values(),
    width/2, height/3, 80,
    400, 60
  );
}

void draw() {
  println("scene =", scene);

  background(0);

  switch(scene) {
    case TITLE:
      if(input.released(Key.Z)) {
        scene = Scene.SELECT_LEVEL;
        if(player != null) {
          player.resetHP();
          player.resetBomb();
        }
      }
      score.reset();
      break;    
    case SELECT_LEVEL:
      if(input.released(Key.Z)) {
        game.bossIndex = 0;
        scene = Scene.PRE_BATTLE;
        if(diff == Difficulty.EXTRA) {
          game.carryHP = false;
          game.carryBomb  = false;
        }else {
          game.carryHP = true;
          game.carryBomb  = true;
        }
      }
      if(input.released(Key.X)) scene = Scene.TITLE;
      break;
    case SELECT_WEAPON:
      scene = Scene.PRE_BATTLE;
    case PRE_BATTLE:
      updatePreBattle();
      break;    
    case BATTLE:
      player.update();
      player.draw();

      boss.update();    
      boss.draw();

      updateBullets();
    
      if(boss.state == BossState.DEAD) {
        scene = Scene.RESULT;
      }
      if(player.lifeStock <= 0) {
        scene = Scene.GAME_OVER;
      }
      break;
    case RESULT:
      drawResult();
    
      if(input.released(Key.Z)) {
        game.bossIndex++;
        if(game.bossIndex >= game.maxBossIndex) scene = Scene.TITLE;
        else scene = Scene.PRE_BATTLE;
      }
      if(input.released(Key.X)) {
        scene = Scene.TITLE;
      }
      break;
    
    case GAME_OVER:
      drawGameOver();
      if(input.released(Key.Z)) scene = Scene.TITLE;
      break;
  }
  
  drawUIByScene();

  input.endFrame();
}

class GameState {
  int bossIndex = 0;
  int maxBossIndex = 5;
  boolean carryHP = false;
  boolean carryBomb = false;
}
GameState game = new GameState();

int preBattleTimer = 0;
// 初期化を 1 回だけ行うためのフラグ
boolean preBattleInitialized = false;
boolean preBattleReady = false;

void updatePreBattle() {
  // 初回フレームで初期化
  if (!preBattleReady) {

    // ---- Player ----
    if (player == null) {
      player = new Player(playWidth/2, height-80, 3, 1.5);
    } else {
      if (game.carryHP)   player.resetHP();
      if (game.carryBomb) player.resetBomb();
    }

    // ---- Boss ----
    boss = createBoss(game.bossIndex);

    // ---- 弾・状態リセット ----
    enemyBullets.clear();
    playerBullets.clear();
    bombField = null;

    preBattleTimer = 0;
    preBattleReady = true;
  }

  preBattleTimer++;

  // 入力で開始
  if (preBattleTimer > 30 && input.pressed(Key.Z)) {
    preBattleReady = false;
    scene = Scene.BATTLE;
  }
  if(input.released(Key.X)) scene = Scene.SELECT_LEVEL;
}

// ---------- Difficulty ----------
enum Difficulty {
  EASY(0.8, 0.8, 0.8, 0.8, 0.8, 0),
  NORMAL(1.0, 1.0, 1.0, 1.0, 1.0, 1),
  HARD(1.3, 1.4, 1.2, 1.2, 1.3, 2),
  EXTRA(1.3, 1.4, 1.2, 1.2, 1.3, 2);
  
  float speedRate;
  float densityRate;
  float spreadRate;
  float hpRate;
  float endureTimeRate;
  int rank;
  
  Difficulty(float s, float d, float sp, float h, float e, int r) {
    speedRate = s;
    densityRate = d;
    spreadRate = sp;
    hpRate = h;
    endureTimeRate = e;
    rank = r;
  }
}


color withAlpha(color c, float a) {
  return color(red(c), green(c), blue(c), a);
}
