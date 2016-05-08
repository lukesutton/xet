# Xet

Initially, this is an experiment in writing a small web-framework. It puts focus on value-types, protocols, and functions over class-hierarchies.

## General Goals

- No magic; configuration is explicit
- Easily testable; as much as is practical, avoid the need for stubbing and mocking
- Type-safe
- Simple to reason about; no ambient state
- A simple core and an extra, opinionated, 'batteries-included' distribution

## Non-goals

- Default or built-in persistence layer
- Being 'easy to use'; simple is better in the long term
