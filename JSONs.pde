void fileRoad() {
   String[] phaseFiles = {
    "JSONs/phase1.json",
    "JSONs/phase2.json",
    "JSONs/phase3.json",
    "JSONs/phase4.json",
    "JSONs/phase5.json",
    "JSONs/phase6.json",
    "JSONs/phase7.json",
    "JSONs/phase8.json",
    "JSONs/phase9.json",
    "JSONs/phase10.json"
  };

  phases = new ArrayList<LoopPhase>();
  
  int count = 0;
  for (String path : phaseFiles) {
    count++;
    println(count);
    phases.add(loader.load(path));
  }
}

// ===============================
// PhaseLoader
// ===============================
class PhaseLoader {

  PApplet app;
  EmitterFactory emitterFactory;
  BossMotionFactory bossMotionFactory;

  PhaseLoader(PApplet app) {
    this.app = app;
    emitterFactory = new EmitterFactory(app);
    bossMotionFactory = new BossMotionFactory();
  }

  LoopPhase load(String path) {
    JSONObject json = app.loadJSONObject(path);

    int loopLength = json.getInt("loopLength");

    Timeline<Emitter> emitters =
      loadEmitters(json.getJSONArray("emitters"));

    Timeline<BossMotion> motions =
      loadMotions(json.getJSONArray("motions"));

    return new LoopPhase(loopLength, emitters, motions);
  }

  Timeline<Emitter> loadEmitters(JSONArray arr) {
    Timeline<Emitter> tl = new Timeline<>();
    for (int i = 0; i < arr.size(); i++) {
      tl.items.add(emitterFactory.fromJSON(arr.getJSONObject(i)));
    }
    return tl;
  }

  Timeline<BossMotion> loadMotions(JSONArray arr) {
    Timeline<BossMotion> tl = new Timeline<>();
    for (int i = 0; i < arr.size(); i++) {
      tl.items.add(bossMotionFactory.fromJSON(arr.getJSONObject(i)));
    }
    return tl;
  }
}

// ===============================
// EmitterFactory
// ===============================
class EmitterFactory {

  SpawnRegistry spawn;
  PatternRegistry pattern;
  MotionRegistry motion;
  StyleRegistry style;

  EmitterFactory(PApplet app) {
    spawn   = new SpawnRegistry();
    pattern = new PatternRegistry();
    motion  = new MotionRegistry();
    style   = new StyleRegistry(app);
  }

  Emitter fromJSON(JSONObject o) {
    Emitter e = new Emitter();

    e.start    = o.getInt("start");
    e.end      = o.getInt("end");
    e.interval = o.getInt("interval");
    e.count    = o.getInt("count");

    e.spawn   = spawn.fromJSON(o.getJSONObject("spawn"));
    e.pattern = pattern.fromJSON(o.getJSONObject("pattern"));
    e.motion  = motion.fromJSON(o.getJSONObject("motion"));
    e.style   = style.fromJSON(o.getJSONObject("style"));

    return e;
  }
}

// ===============================
// BossMotionFactory
// ===============================
class BossMotionFactory {

  BossMoveRegistry registry = new BossMoveRegistry();

  BossMotion fromJSON(JSONObject o) {
    BossMotion m = new BossMotion();
    m.start = o.getInt("start");
    m.end   = o.getInt("end");
    m.move  = registry.fromJSON(o.getJSONObject("motion"));
    return m;
  }
}

// ===============================
// Registry Interfaces
// ===============================
interface MotionBuilder {
  MotionFactory build(JSONObject o);
}

interface StyleBuilder {
  StyleFactory build(JSONObject o);
}

interface SpawnBuilder {
  SpawnFunc build(JSONObject o);
}

interface PatternBuilder {
  PatternFunc build(JSONObject o);
}

interface BossMoveBuilder {
  BossMove build(JSONObject o);
}

// ===============================
// MotionRegistry
// ===============================
class MotionRegistry {

  HashMap<String, MotionBuilder> map = new HashMap<>();

  MotionRegistry() {

    map.put("straight", (o) -> {
      float speed = o.getFloat("speed");
      return (ang, t) -> {
        float a = ang + HALF_PI;  // ★ ここで下基準に変換
        return new Straight(cos(a)*speed, sin(a)*speed);};
    });

    map.put("sine", (o) -> {
      float amp   = o.getFloat("amp");
      float freq  = o.getFloat("freq");
      float speed = o.getFloat("speed");
      return (ang, t) -> {
        float a = ang + HALF_PI;  // ★ ここで下基準に変換
        return new SineMotion(a, amp, freq, speed);};
    });

    map.put("accelerate", (o) -> {
      float acc = o.getFloat("a");
      return (ang, t) -> {
        float a = ang + HALF_PI;  // ★ ここで下基準に変換
        return new Accelerate(a, acc);};
    });

    map.put("homing", (o) -> {
      int start  = o.getInt("start");
      int end    = o.getInt("end");
      float sp   = o.getFloat("speed");
      float rate = o.getFloat("rate");
      return (ang, t) ->
        new Homing(start, end, sp, rate);
    });

    map.put("sum", (o) -> {
      JSONArray arr = o.getJSONArray("motions");
      MotionFactory[] fs = new MotionFactory[arr.size()];
      for (int i=0;i<arr.size();i++)
        fs[i] = fromJSON(arr.getJSONObject(i));

      return (ang,t) -> {
        ArrayList<Motion> ms = new ArrayList<>();
        for (MotionFactory f : fs)
          ms.add(f.create(ang, t));
        return new SumMotion(ms.toArray(new Motion[0]));
      };
    });
  }

  MotionFactory fromJSON(JSONObject o) {
    String type = o.getString("type");
    if (!map.containsKey(type))
      throw new RuntimeException("Unknown Motion: " + type);
    return map.get(type).build(o);
  }
}

// ===============================
// StyleRegistry
// ===============================
class StyleRegistry {

  PApplet app;
  HashMap<String, StyleBuilder> map = new HashMap<>();

  StyleRegistry(PApplet app) {
    this.app = app;

    map.put("circle", (o) -> {
      color c = parseColor(o);
      float r = o.getFloat("r");
      return () -> new CircleStyle(c, r);
    });

    map.put("laser", (o) -> {
      color c = parseColor(o);
      float w = o.getFloat("width");
      float l = o.getFloat("length");
      return () -> new LaserBullet(c, w, l);
    });

    map.put("rice", (o) -> {
      color c = parseColor(o);
      float s = o.getFloat("scale");
      return () -> new RiceBullet(c, s);
    });
  }

  StyleFactory fromJSON(JSONObject o) {
    String type = o.getString("type");
    if (!map.containsKey(type))
      throw new RuntimeException("Unknown Style: " + type);
    return map.get(type).build(o);
  }

  color parseColor(JSONObject o) {
    JSONArray c = o.getJSONArray("color");
    return app.color(c.getInt(0), c.getInt(1), c.getInt(2));
  }
}

// ===============================
// SpawnRegistry
// ===============================
class SpawnRegistry {

  HashMap<String, SpawnBuilder> map = new HashMap<>();

  SpawnRegistry() {

    map.put("boss", (o) ->
      (b,t,i,n) -> b.pos.copy()
    );

    map.put("circle", (o) -> {
      float r = o.getFloat("radius");
      return (b,t,i,n) -> {
        float ang = TWO_PI * i / n;
        return PVector.add(b.pos,
          PVector.fromAngle(ang).mult(r));
      };
    });

    map.put("arc", (o) -> {
      float r  = o.getFloat("radius");
      float a0 = o.getFloat("start");
      float a1 = o.getFloat("end");
      return (b,t,i,n) -> {
        float ang = lerp(a0, a1, i/(float)(n-1));
        return PVector.add(b.pos,
          PVector.fromAngle(ang).mult(r));
      };
    });

    map.put("wallTop", (o) ->
      (b,t,i,n) ->
        new PVector(width * i/(float)(n-1), -10)
    );
  }

  SpawnFunc fromJSON(JSONObject o) {
    String type = o.getString("type");
    if (!map.containsKey(type))
      throw new RuntimeException("Unknown Spawn: " + type);
    return map.get(type).build(o);
  }
}

// ===============================
// PatternRegistry
// ===============================
class PatternRegistry {

  HashMap<String, PatternBuilder> map = new HashMap<>();

  PatternRegistry() {

    map.put("circle", (o) ->
      (b,t,i,n) -> TWO_PI * i / n
    );

    map.put("random", (o) -> {
      float s = o.getFloat("spread");
      return (b,t,i,n) -> random(-s, s);
    });

    map.put("wave", (o) -> {
      float base = o.getFloat("base");
      float amp  = o.getFloat("amp");
      float freq = o.getFloat("freq");
      return (b,t,i,n) ->
        base + sin(t*freq + i)*amp;
    });

    map.put("pyramid", (o) ->
      (b,t,i,n) -> (i - n/2)*0.15
    );
    
    map.put("fixed", (o) -> {
      float ang = o.getFloat("angle");
      return (b, t, i, n) -> ang;
    });
    
    map.put("aim", (o) -> {
      return (b, t, i, n) ->
        atan2(player.pos.y - b.pos.y,
              player.pos.x - b.pos.x);
    });
  }

  PatternFunc fromJSON(JSONObject o) {
    String type = o.getString("type");
    if (!map.containsKey(type))
      throw new RuntimeException("Unknown Pattern: " + type);
    return map.get(type).build(o);
  }
}

// ===============================
// BossMoveRegistry
// ===============================
class BossMoveRegistry {

  HashMap<String, BossMoveBuilder> map = new HashMap<>();

  BossMoveRegistry() {

    map.put("sineMove", (o) -> {
      float amp  = o.getFloat("amp");
      float freq = o.getFloat("freq");
      return (b,t) ->
        b.pos.x = playWidth/2 + sin(t*freq)*amp;
    });

    map.put("moveTo", (o) -> {
      float x = o.getFloat("x");
      float y = o.getFloat("y");
      float sp = o.getFloat("speed");
      return (b,t) -> {
        PVector d = PVector.sub(new PVector(x,y), b.pos);
        if (d.mag() > sp) d.setMag(sp);
        b.pos.add(d);
      };
    });

    map.put("hover", (o) -> (b,t) -> {});
  }

  BossMove fromJSON(JSONObject o) {
    String type = o.getString("type");
    if (!map.containsKey(type))
      throw new RuntimeException("Unknown BossMove: " + type);
    return map.get(type).build(o);
  }
}
