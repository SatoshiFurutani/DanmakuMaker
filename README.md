# DanmakuMaker

Bullet Rush – Game Design Specification (Latest)
Overview

This project is a vertical bullet-hell shooting game implemented in Processing (Java).
All bullet patterns, motions, and boss behaviors are fully data-driven and defined via JSON.

The core design goal is:

To describe bullet patterns as combinations of geometry and motion,
not as ad-hoc procedural logic.

Core Design Principles

All gameplay behavior must be data-driven

Do not introduce special cases with conditional logic

Express complexity through composition, not branching

Separate structure, motion, and appearance strictly

Randomness is allowed only in phase/position, never in bullet count

High-Level Architecture
Phase
 └─ Formation
     ├─ Transform Motion (structure-level)
     └─ Parts
         ├─ Shape
         ├─ Reference Position
         ├─ Individual Motion
         └─ Style

Formation

A Formation represents a spatial and kinematic unit of a bullet pattern.

Responsibilities

Defines a local coordinate space

Evaluates transform motions (structure-level motion)

Owns multiple Parts

Restrictions

Formation does NOT own bullets

Formation does NOT define styles or hit shapes

Formation does NOT manage per-bullet state

Part

A Part is a bullet-emitting unit inside a Formation.

Responsibilities

Each Part must define:

Shape
(single, line, ring)

Reference Position
A fixed point in Formation space

Motion Layer

mode: transform or individual

Motion Timeline

Style

Restrictions

A Part does NOT manage time directly

A Part does NOT define Motion logic itself

Motions do NOT own reference positions

Reference Position (基準位置)

Each Part defines a reference position in Formation coordinates.

Definition

The base direction (base_dir = 0) is defined as:

Direction from reference position → target position


Target = Part (transform motion)

Target = Bullet (individual motion)

baseDir0 = normalize(targetPos - referencePos)

Rules

Reference position is shared by all motions in the Part

Reference position is not time-varying

Reference position is not defined per MotionBlock

Shape

Shapes define initial bullet placement only.

Supported Shapes
Shape	Description
single	Single point
line	Linear arrangement
ring	Circular arrangement
Shape Rules

Shapes do NOT change over time

Shapes do NOT own motion logic

Shapes only define initial positions

Normal Direction Definition
Shape	Normal Direction
ring	Formation center → bullet
line	Perpendicular to line direction
single	Formation center → point
Motion System
Motion Philosophy

Motion transforms existing velocity

Motion is stateful, not a pure function

Motion effects are composed over time

Motion Timeline

Each Part (and Formation) owns a Motion Timeline composed of MotionBlocks.

Each MotionBlock defines:

start (frame)

end (frame)

motion (type + parameters)

Motion Lifecycle Rules
Motion Start

Capture current velocity

Apply base_dir relative to reference position

Fix local motion coordinate system

Motion During

Do NOT recompute base direction

Only update velocity by motion logic

Motion End

Final velocity is preserved

Next motion starts from this velocity

Motion Composition Rules

Normal motions: additive or transformative

Stop motion: dominant override

Stop + Anything = Stop


Restrictions:

Stop is NOT implemented as velocity = (0,0)

Stop is NOT separated into another system

Transform vs Individual Motion

Each Part selects one motion mode:

Transform Motion

Motion evaluated once per Part

Entire structure moves as a unit

Reference position evaluated at Part level

Individual Motion

Motion evaluated per bullet

Each bullet computes its own normal direction

Reference position is shared, target differs

Frame Evaluation Order (Mandatory)

Each frame must evaluate in the following order:

1. Formation transform motion
2. Part shape placement
3. Bullet spawn
4. Part individual motion
5. Bullet position update


This order must not be changed.

Style and Hit Detection

Style belongs to Part

Hit shape is derived from Style

Motion and Shape must NOT affect hit logic

Timeline and Time Management

Timeline unit is frame-based

Loop length is defined at the Phase level

MotionBlocks do NOT manage looping

Editor Design Constraints

The visual editor must expose:

Formation origin

Part shapes

Reference position markers

Normal direction visualization

Motion timelines

Editor behavior must reflect runtime semantics exactly.

Extension Rules

When adding new features:

Try to express behavior using:

reference position

base_dir

transform / individual

MotionBlock composition

Avoid introducing special cases

Prefer reuse of existing motion logic

Design Philosophy Summary

This system treats bullet patterns as
geometry + motion + composition,
not as procedural scripts.

By maintaining strict separation of responsibilities,
the system remains expressive, debuggable, and editor-friendly.
