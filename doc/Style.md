# Agora coding style

This document describes the style used within Agora.
It covers the style itself, which should be clear and unambiguous,
as well as more design aspects on how we approach / solve problems.

## Commits

- A commit must be a self-contained unit of logical change.

- A commit should not contain unrelated changes mixed into the same commit.

- A commit should be relatively simple to review. If the commit changes
too many files, or adds too much functionality, consider splitting it
up into several distinct commits.

- Each commit **must** compile and **must** pass all tests. Hence it is not good form to add tests and then make them pass.
  A simple way to check that each of your branch's commits compiles and pass test is to run the following command:
  `git rebase -i --exec 'dub test && dub build' v0.x.x`. This assumes your branch is based on `v0.x.x`.
  You might also want to run the integration test suite, in which case look at what [the CI is doing](../.travis.yaml).

- The commit title and description should follow some general rules:

An example good commit: https://github.com/bpfkorea/agora/commit/71e7d1cc1da314d92eb76c1d02e04f43bc83784f

The commit title is: `Remove enforcement for expected_validators`

This explains **what** the commit does in a short but meaningful way.
The commit title should in general not be longer than ~80 characters.

A **bad** commit message would be: `Modified Network.d`. This doesn't
tell us anything about the contents of the commit other than which file
was edited. And it's unnecessary, the list of modified files is in the diff of the commit itself.

The description of the previously linked commit is:

```
It is a valid use case for a full node to not have any validator,
as validators only make sense when the node itself is a validator.
```

Note how the commit explains **why** the change was made. Sometimes the
commit message might explain the "how" in more detail if it's necessary.
But explaining the _reason_ of the change (the **why**) is the most
important part of the commit message.

A general guide on how to write good commits is explained in this blog post: https://chris.beams.io/posts/git-commit/

## Formatting

We mostly follow [the D style](https://dlang.org/dstyle.html).

The following is a list of exceptions:

### Modules

All modules should have a module documentation. If you create a new module,
just look at how another module is documented.

Module names are CamelCase. While the D style recommend `std.exception`,
we use `std.Exception`.
This makes the module more prominent and disambiguate any symbol when
reading fully qualified names, as the first CamelCase name is the module.

Imports are organized by packages: `agora` first, dependencies second, `std` third,
`core` last. Within packages, alphabetical order is prefered, with modules
taking preference over packages, e.g.:
```D
import agora.foo.Bar;
import agora.foo.Zyx; // In alphabetical order, this would be last
import agora.foo.pkg.Bar;
```

### Explicit, readable code

Visibility attribute (`public`, `protected`, `package`, `private`) is always specified.
Statement covering a scope without indentation (`private:`) should be avoided.
This made code much easier to read, and code is read much more than it is written.

When implementing an interface, while `override` is not enforced by the language,
it is mandatory in our style, as changing the interface might lead to silent
breakage of implementers without `override` being used.
It also informs the reader that there is an additional context needed.

Prefer longer, more descriptive names over short names in API (e.g. parameters),
as it makes the documentation more readable.
Likewise, when writing unittests for documentation purpose, avoid `auto` and
`const` without a type spelled out.

When importing outside modules, selective import (e.g. `import std.exception : enforce`)
are prefered. This does not matter as much for `agora`, as modules tend to
be smaller, with less dependencies.

Put public symbols first in a module / aggregate whenever possible.

### Functions

Functions have a space between their name and their opening parenthesis
E.g. a function is: `void foobar ()`, not `void foobar()`.
With parameters: `void foobar (int p1, void* p2)`.
Templated functions are written as `void foobar (T) (T arg)`.
This makes functions easy to `grep` for.

### Attributes (@trusted, @safe, @nogc, pure, etc)

Prefer adding `@safe`, `@nogc`, and `pure` atttributes to functions when it's
possible. If one or more statements inside of a non-trivial function call a
non-safe or non-trusted function, don't mark the function itself as `@trusted`.
Instead, mark it as `@safe` and use trusted anonymous delegates on the
statement level.

For example, don't do this:

```D
public void add (Transaction tx) @trusted
{
    auto tx_bytes = serializeFull(tx);
    db.execute("INSERT INTO tx_pool (key, val) VALUES (?, ?)",
        hashFull(tx)[], tx_bytes);
}
```

Instead do this:

```D
public void add (Transaction tx) @safe
{
    auto tx_bytes = serializeFull(tx);  // serializeFull() is already @safe

    () @trusted {
    db.execute("INSERT INTO tx_pool (key, val) VALUES (?, ?)",
        hashFull(tx)[], tx_bytes); }();
}
```

The above code declares an anonymous delegate, and immediately calls it.
Notice that the delegate itself is marked as `@trusted`.

Note: You should only mark code as trusted if it really should be trusted.
For a general definition of what code can be trusted, consult this page: https://dlang.org/spec/function.html#trusted-functions

### Variable & Fields

Note: our rules for variables & fields deviate from the official D style-guide.
For variables and field names we use `snake_case`, and not `camelCase`. For example:

```D
struct LinkedList
{
    void* prevValue;   // Incorrect!!

    void* prev_value;  // correct
}

void main ()
{
    LinkedList linkedList;  // incorrect

    LinkedList linked_list; // ok

    LinkedList list; // even better
}
```

This is to allow easier visual distinction between functions and variables.

In general, try not to use variable names that have too many underscores,
as this implies the variable has many meanings, and it might even signal
that the variable is too complex to use.

### Aggregates (`class` & `struct`)

The order in which members of an aggregate are ordered is as follow:
- `alias this`
- Fields
- Constructors
- Destructors
- Operator overloads
- `public` functions
- `protected` functions
- `package` functions
- `private` function
The intent is to have the interface presented to the world grouped together
and visible with minimal effort.
An additional suggestion is to put `override`ing functions first.


### Documentation

Documentation matters. Ideally, all non-private symbols should be documented,
and private symbols which are fairly complicated should be as well.

`/// Ditto` can be used to document that two symbols share the same purpose or are
in the same  overload set. In the case of overload set, the actual documentation
for the set should include all parameters, as seen in the next example.

When writing documentation, we use multiple styles depending on the circumstance:
1) When the symbol purpose is obvious, a simple `///` is enough
   This is generally the case for fields of aggregates and getters/setters
2) When the purpose can be trivially explained, a `/// Comment goes here` is used.
3) Otherwise, we use a ASCII-style approach:
```D
/********************************************************************************

    This is extended documentation.

    This function is quite complicated and requires more doc.

    Params:
        param = The answer to life, universe and the rest.
        message = Message to send to our overloads. Vertical alignment is not
            required. Add one level of indentation to continue a line.

    Returns:
        When called with `param == 0`, `42`. `false` otherwise.

********************************************************************************/

bool foobar (int param);

/// Ditto
bool foobar (int param, string message);
```
It might look heavy on the eyes, but it actually separate the code well enough
that it is readable.
Documentation, unlike code, has a strict 80 columns rule
Indentation in documentation is similar to that of code: 4 spaces indentation,
one indentation level by default, one extra level per scope.

When implementing an interface / `override` ing a function, one can just document it as:
```D
public class Node : API
{
    /// See `super.func`
    public override void func () { /* ... */ }
}
```

## Design approaches

### Keep module dependencies low

While upstream modules tend to be rather large, we favor an approach where modules
are kept small and self-contained.
The aim is to make the code more modular and easier to reason about.

### Avoid globals / module constructors

Global data decouple the usage of the symbol from its definition.
While it is sometimes necessary, it widely expands the context one has to keep in mind
when reasoning about a piece of code, making comprehension of said code more complex.

### Use overloads over templates when convenient

While template are a quick way to get the job done, they have don't exactly define
the interface exposed by the method. For example, for the declaration
`size_t foo (T) (T arg)` there is no information about what `T` is supposed to be.
It could be a basic type, a reference type, a struct with certain members...
One has to inspect the body which can then contains the expected dependencies:
```D
size_t foo (T) (T arg)
{
    return arg.input.length;
}
```
In this case, the function expects `T` to define an `input` symbol which itself
accept the `.length` call. In D, this could be done in a dozen different ways:
`input` or  `length` could  be UFCS calls,  `input` could be an array,
`input` could be a member  returning a `struct` which defines `length`, etc..

While template constraints are a remedy to this issue, they require additional
developer work, which is usually duplicated.
Finally, templates go through a complex resolution algorithm, and need to be
instantiated, leading to slow down in compilation.

### Separate / abstract away IO from business code

Separating IO from business code allows to provide mock IO primitives in tests,
which enables us to simulate an entire network from a `unittest`.

### Balance OO and procedural programming

The traditional D style is very procedural, with seldom use of object.
In comparison, other close language such as C++ and Java are more OOP-oriented.
We tend to favor an approach which is closer to C++, althought with reduced
reliance on constructors / destructors.


## Tests

There are four kind of tests we perform: `unittest`, network `unittest`,
integration tests and testnet tests.

Unittests and network unittests can give us code coverage data,
which can then be merged to assess that new code is thoroughly tested.
This is not currently integrated but will be in the future.

### Unittests

Unittests are contained within an `unittest` block.
They should be simple, short, and independent of other tests.
They usually test a single function / symbol, or eventually a few working together.
For example the basic key signature unittest:

```D
/// Test that `verify`  and `sign` work in concert
unittest
{
    KeyPair kp = KeyPair.random();
    Signature sign = kp.secret.sign("Hello World".representation);
    assert(kp.address.verify(sign, "Hello World".representation));
}
```

### Network unittests

Network unittests are taking advantage of `agora`'s design to allow testing
an entire network through `unittest`.
Those tests live in the `agora.test` package so they can be selectively
disabled if they grow too large,  or when they don't need to be run.

Following is a template for such a test:
```D
/*******************************************************************************

    <Test summary>

    <Extended description>

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Name;

version (unittest):

// [...] Any import you need
import agora.test.Base; // Base functions for the test environment

///
unittest
{
    const NodeCount = 4;
    auto network = makeTestNetwork(NetworkTopology.Simple, NodeCount);
    network.start();
    network.waitForDiscovery();

   /// Use API as needed
   foreach (/*PublicKey*/ key, ref /*API*/ node; network.apis)
       node.sendTransaction(...);
}
```
Those tests shouldn't spawn **too many** nodes: they are intended to simulate a specific
network behavior based on a given topology, and should not be used to test load or performances.

### Integration tests

Integration tests are currently not implemented.

Integration tests are aimed at testing the IO code of the node.
While they are usually used to test a node fully, by using "Network unittests" we can already
test most of the situations which are relevant to consensus, hence greatly reducing the amount
of tests that need to go in integration tests.

### Testnet

Testnet is currently not running, and this section will be edited when it is.
