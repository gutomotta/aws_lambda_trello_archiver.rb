# Trello Archiver
This is a ruby script that uses Trello API to find and archive old cards in
a specified list, designed for deploying in AWS Lambda for free.

There are no dependencies, just vanilla Ruby 2.5.7.

## Why?
I got tired of manually archiving old cards in my personal "Done" list. I tried
to find solutions that could automatically archive my cards after a week of
having entered a specific list. There **are** options out there, but I really
wanted to keep things simple - and, most importantly, cheap... Why not free? :-)

## Deploy in AWS Lambda
To deploy on AWS Lambda, just copy the code in `trello_archiver.rb` and set the
required environment variables.

To run it periodically, create a CloudWatch Event trigger and run it in a rate
of your choice. I recommend running it every few hours.

## Required Environment Variables

|variable name|required|default|description|
|-|-|-|-|
|**TRELLO_API_KEY**|yes|-|https://trello.com/app-key|
|**TRELLO_API_TOKEN**|yes|-|In the same page you obtained your API Key, you'll find a link to generate a token.|
|**TRELLO_BOARD_ID**|yes|-|Extract it from the Board URL (`trello.com/b/<THIS_IS_THE_BOARD_ID>`).|
|**TRELLO_LIST_NAME**|yes|-|The name of your list. Note that the name matching is case insensitive.|
|**TRELLO_OLD_CARDS_THRESHOLD_DAYS**|no|2|How many days you want your cards to live on the list before they are archived.|

## Deploy in other setups
Feel free to open an Issue and/or make a Pull Request in order to improve this
script and make it deployable in other setups :-)

Also, I'm not quite familiar with AWS Lambda, so I tried to make the
architecture the simplest. If you're a Lambda expert and have any suggestions,
I'm willing to hear you!