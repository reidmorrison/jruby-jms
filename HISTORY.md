## 0.11.0 (2011-04-18)

* Compatibility with JRuby 1.6
* I hate doing this, but unfortunately there is a small breaking change in this release:
** We can no longer pass symbols into the following methods:
*** jms_delivery_mode
*** jms_delivery_mode=
** Just rename existing uses of the above methods to:
*** jms_delivery_mode_sym
*** jms_delivery_mode_sym=
* Added Session Pool - requires GenePool as a dependency if used
* Generate warning log entry for any parameters not known to the ConnectionFactory
* Use java_import for all javax.jms classes
** Rename all Java source files to match new names

## 0.10.1 (2011-02-21)

* Fix persistence typo and add message test cases

## 0.10.0 (2011-02-10)

* Refactoring interface

## 0.9.0 (2011-01-23)

* Revised API with cleaner interface
* Publish GEM

## 0.8.0 (2011-01-22)

* Release to the wild for general use

## 2008, 2009, 2010

* Previously known as jms4jruby
* Running in production at an enterprise processing a million messages a day
