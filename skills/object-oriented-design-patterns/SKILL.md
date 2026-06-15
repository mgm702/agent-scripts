---
name: Object-Oriented Design Patterns
description: SOLID principles and the Gang-of-Four design patterns (creational, structural, behavioral) — when to reach for each and when not to. Reference for OO design decisions.
triggers:
  - design pattern
  - SOLID
  - object oriented
  - OOP design
  - which pattern
  - refactor classes
  - class design
  - interface design
  - decouple
---

# Object-Oriented Design Patterns

Reference for OO design decisions. Adapted from [oodesign.com](https://www.oodesign.com/).

> **Apply [coding-standards](../coding-standards/SKILL.md) first.** Match the existing
> complexity — pick the *simplest* thing that solves the problem. A pattern is justified
> only when the code already carries the complexity it's meant to tame. Don't pattern-ify
> code that a plain function would handle.

## SOLID Principles (apply before patterns)

| Principle | Rule |
|-----------|------|
| **S**ingle Responsibility | A class should have one reason to change |
| **O**pen/Closed | Open for extension, closed for modification |
| **L**iskov Substitution | Subtypes must be substitutable for their base types |
| **I**nterface Segregation | Clients shouldn't depend on interfaces they don't use |
| **D**ependency Inversion | Depend on abstractions, not concrete implementations |

## Creational — object construction

| Pattern | Use when |
|---------|----------|
| **Singleton** | Exactly one instance must exist and be globally reachable |
| **Factory** | Hide instantiation logic behind a common interface |
| **Factory Method** | Subclasses decide which concrete class to instantiate |
| **Abstract Factory** | Create families of related objects without naming concretes |
| **Builder** | Construct a complex object step-by-step with fine control |
| **Prototype** | Create new objects by cloning an existing one |
| **Object Pool** | Reuse expensive-to-create objects across clients |

## Structural — object composition

| Pattern | Use when |
|---------|----------|
| **Adapter** | Convert one interface into another a client expects |
| **Bridge** | Decouple an abstraction from its implementation so both vary |
| **Composite** | Treat part-whole tree hierarchies uniformly |
| **Decorator** | Add responsibilities to an object dynamically |
| **Flyweight** | Share many similar objects to save memory |
| **Proxy** | Stand in for an object to control access to it |
| **Memento** | Capture and restore internal state without breaking encapsulation |

## Behavioral — object interaction

| Pattern | Use when |
|---------|----------|
| **Chain of Responsibility** | Pass a request along handlers until one handles it |
| **Command** | Encapsulate a request as an object (queue, log, undo) |
| **Interpreter** | Represent and evaluate a simple grammar |
| **Iterator** | Traverse a collection without exposing its structure |
| **Mediator** | Centralize how a set of objects interact; loosen coupling |
| **Observer** | Notify dependents automatically when state changes |
| **Strategy** | Swap interchangeable algorithms behind one interface |
| **Template Method** | Fix an algorithm skeleton; defer steps to subclasses |
| **Visitor** | Add operations over an object structure without changing it |
| **Null Object** | Provide a do-nothing surrogate instead of null checks |

## Choosing a Pattern

1. State the problem: construction, composition, or interaction?
2. Check SOLID — often a violation points straight at the fix.
3. Pick the **lightest** pattern that resolves it. Prefer none over a forced fit.
4. Confirm the codebase's existing complexity warrants it (coding-standards Rule 2).

## Anti-Patterns

- Applying a pattern to demonstrate it rather than to solve a problem
- Singletons used as global mutable state
- Deep inheritance where composition (Strategy, Decorator) is cleaner
- Wrapping simple code in factories/builders it doesn't need
- Reaching for a pattern before checking a plain function suffices
