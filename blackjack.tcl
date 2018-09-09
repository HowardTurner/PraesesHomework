#
# to execute install Tcl/Tk  https://www.activestate.com/activetcl/downloads
# at a command line type "wish ./blackjack.tcl
#
# put a title on the window and handle exit conditions if the window is closed

wm protocol . WM_DELETE_WINDOW {terminate }
wm title . "Blackjack Homework"


# dealer's data
namespace eval dealer {
    variable hand "?\n?"
    variable cardsDea\nlt {}
}

# player's data
namespace eval player {
    variable hand "?\n?"
    variable wins 0
    variable losses 0
    variable played 0
    variable cardsDealt {}
 

    # default to a non zero bankroll since there is no Lobby program
    # to provide a bankroll and non zero wager
    variable bankroll 1000
    variable wager 2
}


# everything about the cards
namespace eval cards {
    variable NumDecks 1
    #number of undealt cards that would cause a shuffle of the shoe
    variable shuffleTrigger 12
    variable shuffled {}

    set deck(0)  "King"
    set deck(1)  "Ace"
    set deck(2)  "Deuce"
    set deck(3)  "Trey"
    set deck(4)  "Four"
    set deck(5)  "Five"
    set deck(6)  "Six"
    set deck(7)  "Seven"
    set deck(8)  "Eight"
    set deck(9)  "Nine"
    set deck(10) "Ten"
    set deck(11) "Jack"
    set deck(12) "Queen"


    set value(0)  10
    set value(1)  11
    set value(2)  2
    set value(3)  3
    set value(4)  4
    set value(5)  5
    set value(6)  6
    set value(7)  7
    set value(8)  8
    set value(9)  9
    set value(10) 10
    set value(11) 10
    set value(12) 10
}    


# if a player database existed, here's where we'd update the player
# bankroll, statistics, etc.
proc updatePlayerDatabase { } {

   # connect to database and update player's data
}

# update the player database on exit
proc terminate { } {

    # Update customer's account
    updatePlayerDatabase
    exit 0
}

proc initialize { } {

    # Currently this sets up the GUI and binds the actions to the buttons.  
    # For expansion, we could have a configuration file containing  number of decks
    # how far into the shoe to deal, enable other features such as surrender, splitting 
    # pairs.  Or they could be passed in as startup command line parameters.
    #
    # Connect to the casino database using an argument parameter at startup to access the 
    # customer's bankroll.  Since we are defaulting to a bankroll, there is no reason to 
    # inquire as to how much of it the player wishes to use.  Additionally, there could be 
    # a button to request additional bankroll from the player's account that would 
    # interact with the Lobby program to obtain any available bankroll.  Not implemented.

    # main frame everything goes in
    frame .bj

    # holds the dealer / player cards
    frame .bj.cards -borderwidth 2

    frame .bj.cards.player -borderwidth 5 -relief groove
    label .bj.cards.player.label -text "Player"
    label .bj.cards.player.hand -textvariable player::hand -foreground black -height 12 -width 10
    pack  .bj.cards.player.label -side top
    pack  .bj.cards.player.hand -side left -expand 1

    frame .bj.cards.dealer -borderwidth 5 -relief groove
    label .bj.cards.dealer.label -text "Dealer"
    label .bj.cards.dealer.hand  -textvariable dealer::hand -foreground black -height 12 -width 10
    pack  .bj.cards.dealer.label -side top
    pack  .bj.cards.dealer.hand -side left

    pack .bj.cards.player .bj.cards.dealer -side left
    pack .bj.cards

    # holds the bankroll and wager data
    frame .bj.money -borderwidth 5 -relief groove
    label .bj.money.wagerlabel -text "Wager:"
    label .bj.money.bankrolllabel -text "Bankroll:"
    entry .bj.money.wager -textvariable player::wager -state disabled
    label .bj.money.bankroll -textvariable player::bankroll -state disabled

    pack .bj.money.wagerlabel .bj.money.wager .bj.money.bankrolllabel .bj.money.bankroll -side left
    pack .bj.money

    # holds the player's buttons
    frame  .bj.playerbtns
    button .bj.playerbtns.deal -state normal     -command {deal} -text "New Deal"
    button .bj.playerbtns.hit  -state disabled   -command {hit}  -text "Hit Me"
    button .bj.playerbtns.stay -state disabled   -command {stay} -text "Stay"
    button .bj.playerbtns.quit -state normal     -command {terminate} -text "Cash Out"
    button .bj.playerbtns.reload -state disabled -text "Reload Bankroll"
    pack   .bj.playerbtns.deal .bj.playerbtns.hit .bj.playerbtns.stay .bj.playerbtns.quit -padx 5 -side left
    pack .bj.playerbtns.reload -padx 5 -side left
    pack .bj.playerbtns



    # frame to hold the statistics
    frame .bj.stats
    label .bj.stats.playedlabel -text "Played"
    label .bj.stats.played       -textvariable player::played
    label .bj.stats.wonlabel -text "Won"
    label .bj.stats.won -textvariable player::wins
    label .bj.stats.lostlabel -text "Lost"
    label .bj.stats.lost -textvariable player::losses
    pack  .bj.stats.playedlabel .bj.stats.played .bj.stats.wonlabel -side left
    pack  .bj.stats.won .bj.stats.lostlabel .bj.stats.lost -side left  
    pack  .bj.stats -side bottom

    # make the whole thing visible
    pack  .bj

}   

# create a shuffled shoe with the appropriate number of decks
proc shuffle { } {

   # get the number of cards needed to fill the shoe
   # make a list of the cards by number (later use mod to determine value and suit)
   set len [expr {$cards::NumDecks * 52}]
   set list {}
   for {set i 1} {$i <= $len} {incr i} {

      lappend list $i
   }

    # for the number of cards, generate a random index within the list, 
    # extract it and append it to the shoe we are going to return as a set of 
    # shuffled cards
    #
    while {$len} {
        set n [expr {int($len*rand())}]
        set tmp [lindex $list $n]
        lset list $n [lindex $list [incr len -1]]
        lset list $len $tmp
    }
    return $list
 }

# retrieve the next card in the shoe
proc getNextCard { } {

   # remove the first card from the shoe and return it
   # since there are 13 cards in a suit, modulo 13 results in a card value
   # from 0-12, which we use as an index into value and name tables.  Works for 
   # multiple decks.

   set card [lindex $cards::shuffled 0]
   set cards::shuffled [lreplace $cards::shuffled 0 0]
   return [expr $card % 13]

}

# sum the cards in a hand
proc sumHand { listOfCards } {

   # given a list of cards, sum the hand
   # count the aces so we can determine which might be 1 or 11.
   set total 0
   set ace 0
   for {set i 0} {$i < [llength $listOfCards]} {incr i} { 
      set card $cards::value([lindex $listOfCards $i]) 
      if { $card == 11 } {
      
          incr ace
      }
      set total [expr $total + $card]
   }
   while {$total > 21 && $ace > 0} {
   
      set total [expr $total - 10]
      incr ace -1
   }

   return $total
}

# generate the hand display and its total on the GUI
proc showCards { list } {

    # convert the cards to text form
    set text ""
    foreach card $list {
        set text "$text\n$cards::deck($card)"
    }
    set text "$text\n\n[sumHand $list]"
    return $text   
}

# what to do when the house wins
proc houseWins { } {

    .bj.cards.dealer.hand configure -foreground green
    .bj.cards.player.hand configure -foreground red
    # lower the bankroll by the amount of the wager and reset btns
    set player::bankroll [expr $player::bankroll - $player::wager]
    .bj.playerbtns.deal configure -state normal
    .bj.playerbtns.hit configure -state disabled
    .bj.playerbtns.stay configure -state disabled
    .bj.playerbtns.quit configure -state normal
    incr player::losses
    updatePlayerDatabase
}

# what to do when the player wins
proc playerWins { {blackjack false} } {

    # default the player winning to be NOT a blackjack.  If its a blackjack
    # caller will pass true

    .bj.cards.player.hand configure -foreground green
    .bj.cards.dealer.hand configure -foreground red

    if { [string equal -nocase "true" $blackjack] } {
    
        # its a blackjack
        set player::bankroll [expr $player::bankroll +(double($player::wager) * 1.5)]

    } else {
        set player::bankroll [expr $player::bankroll + $player::wager]
    }
    .bj.playerbtns.deal configure -state normal
    .bj.playerbtns.hit configure -state disabled
    .bj.playerbtns.stay configure -state disabled
    .bj.playerbtns.quit configure -state normal
    incr player::wins
    updatePlayerDatabase
}


# what to do when the hands are tied
proc push { } {

    .bj.playerbtns.deal configure -state normal
    .bj.playerbtns.hit configure -state disabled
    .bj.playerbtns.stay configure -state disabled
    .bj.playerbtns.quit configure -state normal
}

# deal a new hand
proc deal { } {

    # disable the deal and cash out buttons so they're not pressed mid hand.

    .bj.playerbtns.deal configure -state disabled
    .bj.playerbtns.quit configure -state disabled
    .bj.cards.dealer.hand configure -foreground black
    .bj.cards.player.hand configure -foreground black
    # tear down any cards from last hand
    set player::hand ""
    set dealer::hand ""
    # see if we need to shuffle...
    if { $cards::shuffleTrigger >= [llength $cards::shuffled] } {
    
       # should notify player we're shuffling future enhancement
       set cards::shuffled [shuffle]
    }

    incr player::played

    set player::cardsDealt {}
    set dealer::cardsDealt {}

    #deal the cards
    lappend player::cardsDealt [getNextCard]
    lappend dealer::cardsDealt [getNextCard]
    lappend player::cardsDealt [getNextCard]

    #show the player his cards and the dealer's face up card
    set player::hand [showCards $player::cardsDealt]
    set dealer::hand [showCards $dealer::cardsDealt]

    lappend dealer::cardsDealt [getNextCard]

    #check for blackjacks
    set dealerBJ false
    set playerBJ false

    set playerSum [sumHand $player::cardsDealt]
    set dealerSum [sumHand $dealer::cardsDealt]
 

    if { $playerSum == 21 } {
        set dealer::hand [showCards $dealer::cardsDealt]
        if { $dealerSum == 21 } {
            #its a push, both blackjack
            push
        } else {
            # player blackjack, dealer does not
            # expose dealer's hole card
            set dealer::hand [showCards $dealer::cardsDealt]
            playerWins "true"
        }
    } elseif { $dealerSum == 21 } {
            #delaer blackjack, player does not
            set dealer::hand [showCards $dealer::cardsDealt]
            houseWins
    } else {
    
       # play the hand out
       #enable hit and stay buttons
       .bj.playerbtns.hit configure -state normal
       .bj.playerbtns.stay configure -state normal
    }
}  

# player requests another card
proc hit { } {

    lappend player::cardsDealt [getNextCard]
    set player::hand [showCards $player::cardsDealt]
    set handCount [sumHand $player::cardsDealt]
    if {$handCount > 21} {
    
       # hand over, player busts
       # expose dealer's hole card
       set dealer::hand [showCards $dealer::cardsDealt]
       houseWins
    }
    
}

# player is satisfied with their hand  
proc stay { } {

  # no more hits for the player
  .bj.playerbtns.hit configure -state disabled

  # expose the hole card, sum the hand, and see if we need another card.
  set dealer::hand [showCards $dealer::cardsDealt]

  while {[sumHand $dealer::cardsDealt] < 17} {
     lappend dealer::cardsDealt [getNextCard]
     set dealer::hand [showCards $dealer::cardsDealt]
   }
   set playerSum [sumHand $player::cardsDealt]
   set dealerSum [sumHand $dealer::cardsDealt]
   
   if {$dealerSum > 21} {
   
      # player wins, update bankroll
      playerWins

   } elseif {$dealerSum == $playerSum} {
   
      # tie
      push
   } elseif {$dealerSum < $playerSum} {
   
      # player wins
      playerWins

   } else {
   
      #house wins
      houseWins
   }
}  


# build the GUI, bind actions to buttons, initialize bankroll, everything ready to play
initialize 

#shuffle the first shoe
set cards::shuffled [shuffle]  


   
