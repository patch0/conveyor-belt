# AssemblyLine

This is a simulation engine for the [conveyor belt challenge](https://gist.github.com/immunda/81bcdda0dc3b390117dc3c5cf2b2ea5d).

## Setup and Run Instructions

1. Install gems:

```
bundle install
```

2. Run tests:

```
bundle exec rspec
```

3. Run simulation

```
ruby -Ilib -rassembly_line -e 'AssemblyLine.new.run'
```

This produces output like

```
{"A"=>22, "B"=>12, "P"=>16}
```

which shows the count of each item that comes off the end of the conveyor, i.e. 22 `A` parts, 12 `B` parts and 16 complete `P` products.

4. Changing the specs for the simulation

The `AssemblyLine#new` method accepts a couple of arguments that can be used to alter the simulation, specifically how many workers, and how many workers can attend each slot on the conveyor belt.  E.g. to run it with 100 workers, at 3 per slot, run;

```
ruby -Ilib -rassembly_line -e 'AssemblyLine.new(100, 3).run'
```

The `#run` method also takes a single argument for the number of times the simulation should be run, e.g. to run it 1000 times, instead of the default 100, do

```
ruby -Ilib -rassembly_line -e 'AssemblyLine.new.run(1000)'
```

Other things can be changed, e.g. the frequency that parts are delivered to the start of the belt, and how many of each component is required to build the product.  These are set as constants in the `ConveyorBelt` and `Worker` classes respectively.

## Design Decisions

This design is not thread safe!  With a small number of workers I don't suppose this would make a lot of difference, as each worker is regulated by the pace of the belt, and I'm anticipating that the work to advance the belt is greater than the work each worker needs to conduct.  Making this thread-safe would involve adding a mutex around the state of the belt, or maybe just the locking mechanism that I've written,

I decided to allow the workers flexibility in the number of parts needed to build a product.  This can be specified in the `REQUIRED_COMPONENTS` hash in the `Worker` class.  Similarly the production line might want to change frequencies of parts being produced.  This is defined in the `COMPONENT_FREQS` hash in the `ConveyorBelt` class.

There is some time keeping too, which could be used to see how many iterations that each worker is blocked waiting for space on the conveyor, or for the correct part to show up.

