#!/usr/bin/env python

from ipdata import ipdata
from pprint import pprint
with open('../secrets/geo.key') as key:
    key.readline().strip()
    ipdata = ipdata.IPData(key)
    ipinput = raw_input("Enter IP address: ")
    response = ipdata.lookup(ipinput)
