ApomorphyTally
==============

ApomorphyTally.pl

Written by Matt Gitzendanner

University of Florida

Department of Biology and Florida Museum of Natural History

This program takes the output from PAUP that descripes the apomorphies along branches of a tree. The user provides this file, along with a file describing the CHARSETs for different genes. The program parses the CHARSET information and uses that to go through the apomorphy file tallying the numbers of apomorphies for each gene at each node.

Use: ApomorphyTally.pl takes 3 inputs in the following format and order:

1. The name of your log file. For best results this shouldn't have much more than the output from the describe trees command. Other stuff could easily throw this program off and cause odd results.
  To generate this file in OS 9 version of PAUP:
    1. Start with dataset executed and trees loaded in memory
    2. File > Log Output to Disk...
    3. Trees > Describe Trees...
    4. Click the "list of apomorphies" checkbox and "Describe"
    5. File > Log output to Disk... 
  
  To generate in comand line version:
     1. Command: describetrees [tree-list] apolist=yes; 
2. The name of a file containing the CHARSETs for your genes. These should be formatted something like:

  `CHARSET atpB = 1 - 1497;` 

  NOTE: This will only work on continuous blocks of characters and starting and ending bases must be specified. This is written thinking about datasets of multiple genes. As it is written, it can't do things like tally 1st, 2nd and 3rd positions or things like that.
  This file shouldn't have anything other than the CHARSET lines.

3. The name of an output file. This should not exist already as it will be overwritten when the program runs. 

example: `$ ./ApomorphyTally.pl infile charfile outfile`


History:

* v. 1.0: 23 Sept. 2007
* v. 1.0.1: 24 Sept. 2007
