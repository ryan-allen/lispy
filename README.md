# LISPY

Yeah, right. Get a room, you two.

![Nothing to do with LISP, Problem?](http://1.bp.blogspot.com/_Tbc9D_HLbrs/TR3Vi-dyOnI/AAAAAAAAAOE/n8zDvBlzH3I/s320/troll-face_design.png)

## The backstory.

I've written a number of Ruby libraries in my time. I've used many, many more. Wait, let's back up a bit.

## Assumptions.

* People love libraries like Sinatra and ActiveRecord and Babushka and AASM and (name your favourite Ruby library).
* What they love about these is the small amount of Ruby syntax required to get a whole lot done.
* They love that they can contextualise their definitions (that make the libraries do things) with natural Ruby syntax such as blocks.
* To enable these kinds of libraries the use of so-called 'meta-programming' constructs are required (instance_eval, instance_exec).
* Clever but inexperienced Ruby programmers often make very useful libraries with wonderful APIs but horrible internals (my hand is up, see: Workflow).

## Goals.

* Decouple the 'pretty Ruby junk' from the (hopefully) clean and explicit implementation that makes the library do it's job.
* Allow library authors to dream up APIs and implement them without entering Ruby metaprogramming hell (it is a real place).

## Examples.

Take the following example:

    Lispy.configure
    class SomeUsageOfMyAwesomeDSL
      Lispy.extend

      fart 1
      fart 2
      fart 3, 4
      fart
      fart :where => :in_bed
    end
    SomeUsageOfMyAwesomeDSL.output

This will return `[[:fart, 1], [:fart, 2], [:fart, [3, 4]], [:fart, []], [:fart, {:where => :in_bed}]]`. It looks somewhat like an abstract syntax tree (I think). Let's take an example with nesting:

    Lispy.configure
    class ToDoList
      Lispy.extend

      todo_list do
        item :priority => :high do
          desc 'Take out the trash, it stinks.'
        end
        item :priority => :normal do
          desc 'Walk the dog.'
        end
        item :priority => :normal do
          desc 'Feed the cat.'
        end
      end
      interested_parties do
        person 'Me.'
        person 'You.'
        person '...'
      end
    end
    ToDoList.output

The pretty printed output is this, but before you continue, I ask you to take a deep breath, and remember that you are a programmer and that you have been writing Ruby for too long to be able to look at anything else than ActiveRecord declarations and say something along the lines of "WTF IS THIS, IT IS BAD CODE OMFG I AM TELLING!!!1". Yes, once upon a time you were able to think as a programmer and once you had patience! Now, that output:

    [[:todo_list, []],
     [[:item, {:priority=>:high}],
      [[:desc, "Take out the trash, it stinks."]],
      [:item, {:priority=>:normal}],
      [[:desc, "Walk the dog."]],
      [:item, {:priority=>:normal}],
      [[:desc, "Feed the cat."]]],
     [:interested_parties, []],
     [[:person, "Me."], [:person, "You."], [:person, "..."]]]

That last example, I just wrote off the top of my head. You see how you can start with an API design and worry about implementation later? If you haven't tried to make a 'nice' Ruby library before, this wont be self evident, but for those that have, and have struggled through all the madness, you'll see what I mean. Once you've made up your API, all you have to do is write the translation library that does whatever that needs to be done. If that is piping out to a shell, writing a configuration file or constructing an object graph, then well, you're covered aren't you?

Your crazy so-called 'DSL' is now decoupled from your wonderfully explicitly programmed library, I hope. Because I might have to modify it one day and man, if I see a rats nest of instance_execs and auto-generated classes I might just... write you a nasty letter. With angry faces like this: >:|

## Now what?

If you have any questions about this, or how I'm using it for real-world problems (I am!), please get in touch. Pete won't talk to me about this, and I bought his car and everything!!!

## Why Lispy?

To my mind, this whole API fandangle we've gotten ourselves into is due to Ruby having a nice enough syntax to describe APIs in a way that is easy to understand, but Ruby itself wasn't designed with this usage in mind. When I see lines like `has_one :brain` and `dep 'nginx' do` it reminds me of a feature of LISP, which is code as data. Ruby doesn't have this code as data facility but I reckon if it did, we'd have cleaner library implementations with it's idomatic syntax.

Saying that, I've written about 10 lines of LISP in my life. Pete keeps telling me to go read SICP and I keep meaning to but then I end up at the local bar listening to some rock band and I'm like "crap, it's 3am". And even then, I wont get to use LISP at work because I don't think anyone in our company except for Pete has actually read SICP.

## License.

Released under the MIT license (see MIT-LICENSE). GPL can go fart itself, seriously. I like open source, but I also like money.
