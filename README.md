We are polling a "what is my ip" service of 1&1 (myfritz.net) with a cronjob and update the ip at route 53

## Install AWS CLI

Assuming Ubuntu

* `sudo apt install awscli`
* look up your key in the aws console
* `aws configure`

## Stack

* `git clone https://github.com/tkvogt/fritzbox-route53`
* `cd fritzbox-route53`
* Installing Haskell stack: `curl -sSL https://get.haskellstack.org/ | sh`
* `stack build` in the folder with stack.yaml
* Run the server in the background: `./.stack-work/install/x86_64-linux-tinfo6/dac5e107f9affd1b3b8c1797ae748b09b977ec0bb02929e29cbc7affc5ad4f04/8.6.3/bin/fritzbox-route53 &`

## cronjob
=======
*or*

## Run with Docker

TODO: not working yet, aws configure inside docker. How?

* `git clone https://github.com/tkvogt/fritzbox-route53`
* `cd fritzbox-route53`
* `sudo docker build . -t  updateip`
* `sudo docker run updateip`


## Fritzbox

Then go to Internet -> Freigaben -> Dyndns

![Fritbox Dynamix DNS](dyndns.webp)

and enter your domain name and change the zoneid in the following string that is the Update-URL:

`http://localhost:8090/update?hostname=<domain>&zoneid=Z32NAI0V3I6P4A&ipv4=<ipaddr>`

./.stack-work/install/x86_64-linux-tinfo6/dac5e107f9affd1b3b8c1797ae748b09b977ec0bb02929e29cbc7affc5ad4f04/8.6.3/bin/cronjob-route53 *.autocompletion.io Z32NAI0V3I6P4A $(dig +short wm9fb25lwlihk5jv.myfritz.net)

crontab -e
*/2 * * * * ~/cronjob-route53 *.autocompletion.io Z32NAI0V3I6P4A $(dig +short wm9fb25lwlihk5jv.myfritz.net)
*/2 * * * * ~/cronjob-route53   autocompletion.io Z32NAI0V3I6P4A $(dig +short wm9fb25lwlihk5jv.myfritz.net)
=======
* Ping your domain
* Unplug the cable of the fritzbox, wait until the light switches off
* Plug it in again to get a new ip address
* Ping your domain, and see the new ip

