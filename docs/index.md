
##Haskell Error fare web scraper development blog

This blog is created to give insights in my attempt to create a web scraper to search for error fares from airlines.
So why would i do this?

##Day 1: Choosing which language
written on 05-03-2020

####Goals
I have 2 goals, to create a serious project in another programming paradigm. 
And to find cheaper fare when an employee of an airline screws up. 
With this i mean that the program detects when a flight is available for an abnormal price.
For example: A flight from AMS to NYC normally costs around 600 euro's return, 
but the application should detect when a flight suddenly lists for 40 euro's and give a warning.
Because ill use it myself it should not need an advanced control panel. 
An ini file should be fine to tell the application for which routes to search.

###So... Why Haskell?
As told before, i want to learn to program in a new programming paradigm. 
After looking to diffrent paradigms I chose haskell over other languages because I found the following Pro's multiple times

* Clean, clear, readable code
* New way of looking at problems
* Decent performance; excellent concurrent performance for stuff like web back-ends (lightweight concurrency)
* Easier to reason about what code is doing
* Lots of libraries

However there should be some cons as well:
* Hard to learn; hence fewer developers
    * Jobs?  What jobs?  (So far, this may well change)
* Libraries are often ill-documented or overly-complicated

In this blog i will delve into the language itself and compare it to diffrent languages such as imperative (Java) against declarative.

##Setting up the project
Written on 06-03-2020

###Build tool, package manager and IDE
I will use Stack as the build tool, this creates a local enviroment with the compiler, a default project structure and so on.
As IDE i used Intellij with the Intellij-haskell plugin. However, 
the goal of this blog is to point out diffrences in the programming language itself. NOt the package manager. Because of that i won't focus on those diffrences.

##Start
To start a project I made sure i had a decent project structure and think about the structure i want my project to get.
I knew i want to have a component that imports my configuration, i knew i had to use some sort of headless browser or API to crawl available data, and i had to find a way to export it into a file.





