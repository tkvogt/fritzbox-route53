We are polling a "what is my ip" service of 1&1 (myfritz.net) with a cronjob and update the ip at route 53

## Install AWS CLI

Assuming Ubuntu

* `sudo apt install awscli`
* look up your key in the aws console
* `aws configure`

## Stack

* `git clone https://github.com/tkvogt/fritzbox-route53`
* `cd fritzbox-route53`
* Installing Haskell stack
* `stack build` in the folder with stack.yaml
* `./.stack-work/install/x86_64-linux-tinfo6/dac5e107f9affd1b3b8c1797ae748b09b977ec0bb02929e29cbc7affc5ad4f04/8.6.3/bin/fritzbox-route53`

## cronjob

./.stack-work/install/x86_64-linux-tinfo6/dac5e107f9affd1b3b8c1797ae748b09b977ec0bb02929e29cbc7affc5ad4f04/8.6.3/bin/cronjob-route53 *.autocompletion.io Z32NAI0V3I6P4A $(dig +short wm9fb25lwlihk5jv.myfritz.net)

crontab -e
*/2 * * * * ~/cronjob-route53 *.autocompletion.io Z32NAI0V3I6P4A $(dig +short wm9fb25lwlihk5jv.myfritz.net)
*/2 * * * * ~/cronjob-route53   autocompletion.io Z32NAI0V3I6P4A $(dig +short wm9fb25lwlihk5jv.myfritz.net)
