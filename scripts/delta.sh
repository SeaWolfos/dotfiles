#!/bin/bash

function delta() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
   ORANGE='\033[0;33m'
    NC='\033[0m' # No Color

    lastBlockHash=`stats | head -n 6 | tail -n 1 | awk '{print $2}'`
    lastBlockCount=`stats | head -n 7 | tail -n 1 | awk '{print $2}' | tr -d \"`

    tries=6
    deltaMax=5
    counter=0

    while [[ $counter -le $tries ]]
    do
        shelleyExplorerJson=`curl -X POST -H "Content-Type: application/json" --data '{"query": " query {   allBlocks (last: 3) {    pageInfo { hasNextPage hasPreviousPage startCursor endCursor  }  totalCount  edges {    node {     id  date { slot epoch {  id  firstBlock { id  }  lastBlock { id  }  totalBlocks }  }  transactions { totalCount edges {   node {    id  block { id date {   slot   epoch {    id  firstBlock { id  }  lastBlock { id  }  totalBlocks   } } leader {   __typename   ... on Pool {    id  blocks { totalCount  }  registration { startValidity managementThreshold owners operators rewards {   fixed   ratio {  numerator  denominator   }   maxLimit } rewardAccount {   id }  }   } }  }  inputs { amount address {   id }  }  outputs { amount address {   id }  }   }   cursor }  }  previousBlock { id  }  chainLength  leader { __typename ... on Pool {  id  blocks { totalCount  }  registration { startValidity managementThreshold owners operators rewards {   fixed   ratio {  numerator  denominator   }   maxLimit } rewardAccount {   id }  } }  }    }    cursor  }   } }  "}' https://explorer.incentivized-testnet.iohkdev.io/explorer/graphql 2> /dev/null`
        shelleyLastBlockCount=`echo $shelleyExplorerJson | grep -m 1 -o '"chainLength":"[^"]*' | cut -d'"' -f4 | awk '{print $NF}'`
        shelleyLastBlockCount=`echo $shelleyLastBlockCount|cut -d ' ' -f3`
        deltaBlockCount=`echo $(($shelleyLastBlockCount-$lastBlockCount))`

        if [[ ! -z $shelleyLastBlockCount ]]; then
            break
        fi

        counter=$(($counter+1))
        echo -e ${RED}"INVALID RESULT. RETRYING..."${NC}
        sleep 3
    done

    if [[ -z "$shelleyLastBlockCount" ]]
    then
        echo ""
        echo -e ${RED}"INVALID FORK!"${NC}
        echo ""
    else
        deltaBlockCount=`echo $(($shelleyLastBlockCount-$lastBlockCount))`
    fi

    echo "LastBlockCount: " $lastBlockCount
    echo "LastShelleyBlock: " $shelleyLastBlockCount
    echo "DeltaCount: " $deltaBlockCount

   next

    now=$(date +"%r")

   isNumberRegex='^[0-9]+$'
   if [[  -z $lastBlockCount || ! $lastBlockCount =~ $isNumberRegex ]]; then
       echo -e ${RED}"$now: Your node appears to be starting or not running at all. Execute 'stats' to get more info."${NC}
      return
    fi
    if [[ $deltaBlockCount -lt $deltaMax && $deltaBlockCount -gt 0 ]]; then
       echo -e ${ORANGE}"$now: WARNING: Your node is starting to drift. It could end up on an invalid fork soon."${NC}
      return
    fi
    if [[ $deltaBlockCount -gt $deltaMax ]]; then
       echo -e ${RED}"$now: WARNING: Your node might be forked."${NC}
      return
    fi
    if [[ $deltaBlockCount -le 0 ]]; then
       echo -e ${GREEN}"$now: Your node is running well."${NC}
      return
    fi
 }
