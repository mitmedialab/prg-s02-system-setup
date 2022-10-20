#!/usr/bin/env python3

import socket
import os
import time
import signal
import sys
import _thread as thread # in Python3, the module is called _thread
import threading
import concurrent.futures
from multiprocessing import Process
import warnings

""" FireBase """
import firebase_admin
from firebase_admin import credentials, db
import time
import datetime

def init_firebase(nuc, participant="p00"):
    ref = db.reference()
    ref.update({
        nuc : {
            "IP" : "null",
            "Jibo" : "null",
            "Participant" : participant,
            "Tablet" : "null",
            "ValidSessions" : "",
            "StoryCorpus": {
                "Regular" : "False",
            }
        }
    })

nucs = ['s02-n00-nuc-{}'.format(i) for i in [141, 118, 121, 133, 130, 127, 144, 125]]
participants = ['p{:02}'.format(i) for i in [41, 42, 45, 0, 43, 46, 44, 0]]

# Firebase read for the first time
cred = credentials.Certificate("auto-dyadic-controller-firebase.json")
db_url = 'https://auto-dyadic-session-34421-default-rtdb.firebaseio.com'
default_app = firebase_admin.initialize_app(cred, {'databaseURL':db_url})

for nuc, participant in zip(nucs, participants):
    init_firebase(nuc, participant) 

